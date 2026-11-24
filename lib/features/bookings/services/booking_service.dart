import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/search/domain/revalidation_result.dart';
import '../../../core/search/services/offer_revalidation_service.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/print_service.dart';
import '../../../core/services/share_service.dart';
import '../data/booking_repository_impl.dart';
import '../data/mock_booking_data.dart';
import '../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

final bookingListProvider =
    StateNotifierProvider<BookingListNotifier, List<Booking>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingListNotifier(repository);
});

class BookingListNotifier extends StateNotifier<List<Booking>> {
  final BookingRepository _repository;

  BookingListNotifier(this._repository)
      : super(List.from(MockBookingData.defaultBookings));

  Future<void> loadBookings(String userId) async {
    final list = await _repository.getUserBookings(userId);
    state = list;
  }

  void addBooking(Booking booking) {
    // Avoid duplicate booking entries
    state = [
      booking,
      ...state.where((b) =>
          b.bookingId != booking.bookingId &&
          b.bookingReference != booking.bookingReference),
    ];
  }

  void updateBooking(Booking updatedBooking) {
    state = state.map((b) {
      if (b.bookingId == updatedBooking.bookingId ||
          b.bookingReference == updatedBooking.bookingReference ||
          b.id == updatedBooking.id) {
        return updatedBooking;
      }
      return b;
    }).toList();
  }

  Future<void> cancelBooking(
    String bookingId, {
    String? reason,
    double? refundAmount,
  }) async {
    await _repository.cancelBooking(
      bookingId,
      reason: reason,
      refundAmount: refundAmount,
    );

    final updated = await _repository.getBookingByReference(bookingId);

    state = state.map((b) {
      if (b.bookingId == bookingId ||
          b.id == bookingId ||
          b.bookingReference == bookingId) {
        if (updated != null) return updated;

        final amount = refundAmount ?? b.priceBreakdown.totalAmount;
        return b.copyWith(
          status: BookingStatus.cancelled,
          paymentStatus: PaymentStatus.refunded,
          cancellationReason: reason ?? 'Cancelled by customer',
          updatedAt: DateTime.now(),
          refundDetails: RefundDetails(
            status: RefundStatus.refunded,
            refundAmount: amount,
            currency: b.priceBreakdown.currency,
            refundTransactionId:
                'RFND-TRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
            reason: reason ?? 'Cancelled by customer',
            requestedAt: DateTime.now(),
            processedAt: DateTime.now(),
            notes: 'Refund processed to original payment method.',
          ),
        );
      }
      return b;
    }).toList();
  }

  Future<RefundDetails?> requestRefund(
    String bookingId, {
    required String reason,
    double? refundAmount,
  }) async {
    final refund = await _repository.requestRefund(
      bookingId,
      reason: reason,
      amount: refundAmount,
    );

    final updated = await _repository.getBookingByReference(bookingId);
    if (updated != null) {
      updateBooking(updated);
    }
    return refund;
  }

  Booking? findByReference(String reference) {
    try {
      return state.firstWhere(
        (b) =>
            b.bookingReference == reference ||
            b.bookingId == reference ||
            b.id == reference,
      );
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

final documentOperationProvider = StateNotifierProvider.autoDispose
    .family<DocumentOperationNotifier, DocumentOperationState, String>(
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
        errorMessage:
            'We could not generate your booking document. Please try again.',
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
      final result = await _shareService.savePdfToFile(
          pdfBytes: bytes, fileName: fileName);

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
      final result = await _printService.printDocument(
          pdfBytes: bytes, documentName: docName);

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
        body:
            'Booking confirmation for ${booking.itemName} (Reference: ${booking.bookingReference}).',
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
