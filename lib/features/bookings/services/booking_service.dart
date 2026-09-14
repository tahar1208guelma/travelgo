import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/print_service.dart';
import '../../../core/services/share_service.dart';
import '../data/booking_repository_impl.dart';
import '../data/mock_booking_data.dart';
import '../models/booking_model.dart';

final bookingListProvider = StateNotifierProvider<BookingListNotifier, List<Booking>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingListNotifier(repository);
});

class BookingListNotifier extends StateNotifier<List<Booking>> {
  final BookingRepository _repository;

  BookingListNotifier(this._repository) : super(List.from(MockBookingData.defaultBookings));

  Future<void> loadBookings(String userId) async {
    final list = await _repository.getUserBookings(userId);
    state = list;
  }

  void addBooking(Booking booking) {
    state = [booking, ...state];
  }

  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    await _repository.cancelBooking(bookingId, reason: reason);
    state = state.map((b) {
      if (b.bookingId == bookingId || b.id == bookingId) {
        return b.copyWith(
          status: BookingStatus.cancelled,
          cancellationReason: reason ?? 'Cancelled by user',
        );
      }
      return b;
    }).toList();
  }

  Booking? findByReference(String reference) {
    try {
      return state.firstWhere((b) => b.bookingReference == reference);
    } catch (_) {
      return null;
    }
  }
}

class DocumentOperationState {
  final bool isGenerating;
  final bool isSaving;
  final bool isPrinting;
  final bool isSharing;
  final String? savedFilePath;
  final String? errorMessage;
  final Uint8List? generatedPdfBytes;

  const DocumentOperationState({
    this.isGenerating = false,
    this.isSaving = false,
    this.isPrinting = false,
    this.isSharing = false,
    this.savedFilePath,
    this.errorMessage,
    this.generatedPdfBytes,
  });

  DocumentOperationState copyWith({
    bool? isGenerating,
    bool? isSaving,
    bool? isPrinting,
    bool? isSharing,
    String? savedFilePath,
    String? errorMessage,
    Uint8List? generatedPdfBytes,
  }) {
    return DocumentOperationState(
      isGenerating: isGenerating ?? this.isGenerating,
      isSaving: isSaving ?? this.isSaving,
      isPrinting: isPrinting ?? this.isPrinting,
      isSharing: isSharing ?? this.isSharing,
      savedFilePath: savedFilePath ?? this.savedFilePath,
      errorMessage: errorMessage,
      generatedPdfBytes: generatedPdfBytes ?? this.generatedPdfBytes,
    );
  }
}

final documentOperationProvider =
    StateNotifierProvider.autoDispose.family<DocumentOperationNotifier, DocumentOperationState, String>(
        (ref, bookingRef) {
  final pdfService = ref.watch(pdfServiceProvider);
  final printService = ref.watch(printServiceProvider);
  final shareService = ref.watch(shareServiceProvider);
  final bookings = ref.watch(bookingListProvider);
  final booking = bookings.firstWhere(
    (b) => b.bookingReference == bookingRef,
    orElse: () => MockBookingData.flightBooking,
  );

  return DocumentOperationNotifier(
    booking: booking,
    pdfService: pdfService,
    printService: printService,
    shareService: shareService,
  );
});

class DocumentOperationNotifier extends StateNotifier<DocumentOperationState> {
  final Booking booking;
  final PdfService _pdfService;
  final PrintService _printService;
  final ShareService _shareService;

  DocumentOperationNotifier({
    required this.booking,
    required PdfService pdfService,
    required PrintService printService,
    required ShareService shareService,
  })  : _pdfService = pdfService,
        _printService = printService,
        _shareService = shareService,
        super(const DocumentOperationState());

  /// Generate or retrieve cached PDF bytes for this booking
  Future<Uint8List?> getOrGeneratePdf() async {
    if (state.generatedPdfBytes != null) {
      return state.generatedPdfBytes;
    }

    state = state.copyWith(isGenerating: true, errorMessage: null);
    try {
      final bytes = await _pdfService.generateBookingPdf(booking);
      state = state.copyWith(isGenerating: false, generatedPdfBytes: bytes);
      return bytes;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: 'We could not generate your booking document. Please try again.',
      );
      return null;
    }
  }

  /// Save PDF file to storage
  Future<String?> saveDocument() async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final bytes = await getOrGeneratePdf();
      if (bytes == null) {
        state = state.copyWith(isSaving: false);
        return null;
      }

      final fileName = booking.suggestedPdfFileName;
      final result = await _shareService.savePdfToFile(pdfBytes: bytes, fileName: fileName);

      if (result.isSuccess) {
        state = state.copyWith(isSaving: false, savedFilePath: result.filePath);
        return result.filePath;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: result.errorMessage ?? 'Unable to save PDF file.',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'An unexpected error occurred while saving the document.',
      );
      return null;
    }
  }

  /// Print the document
  Future<bool> printDocument() async {
    state = state.copyWith(isPrinting: true, errorMessage: null);
    try {
      final bytes = await getOrGeneratePdf();
      if (bytes == null) {
        state = state.copyWith(isPrinting: false);
        return false;
      }

      final docName = 'TRAVELGO_${booking.bookingReference}';
      final result = await _printService.printDocument(pdfBytes: bytes, documentName: docName);

      state = state.copyWith(
        isPrinting: false,
        errorMessage: result.isSuccess ? null : result.errorMessage,
      );
      return result.isSuccess;
    } catch (e) {
      state = state.copyWith(
        isPrinting: false,
        errorMessage: 'Could not initiate printing workflow.',
      );
      return false;
    }
  }

  /// Share the document
  Future<bool> shareDocument() async {
    state = state.copyWith(isSharing: true, errorMessage: null);
    try {
      final bytes = await getOrGeneratePdf();
      if (bytes == null) {
        state = state.copyWith(isSharing: false);
        return false;
      }

      final fileName = booking.suggestedPdfFileName;
      final success = await _shareService.sharePdf(
        pdfBytes: bytes,
        fileName: fileName,
        subject: 'TRAVELGO Confirmation - ${booking.bookingReference}',
        body: 'Booking confirmation for ${booking.itemName} (Reference: ${booking.bookingReference}).',
      );

      state = state.copyWith(isSharing: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isSharing: false,
        errorMessage: 'Unable to share document.',
      );
      return false;
    }
  }
}
