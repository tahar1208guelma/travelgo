import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/hotel_partner_repository.dart';
import '../../domain/entities/hotel_partner_entity.dart';

class HotelPartnerState {
  final HotelPartnerProfile? profile;
  final List<PartnerHotelListing> hotels;
  final List<PartnerReservation> reservations;
  final List<PartnerPayoutRecord> payoutHistory;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final PartnerReservation? scannedReservation;
  final String? scanSuccessMessage;

  const HotelPartnerState({
    this.profile,
    this.hotels = const [],
    this.reservations = const [],
    this.payoutHistory = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.scannedReservation,
    this.scanSuccessMessage,
  });

  int get totalActiveHotels => hotels.where((h) => h.status == PartnerListingStatus.active).length;
  int get totalPendingHotels => hotels.where((h) => h.status == PartnerListingStatus.pendingReview).length;
  int get totalRooms => hotels.fold(0, (sum, h) => sum + h.rooms.fold(0, (rSum, r) => rSum + r.totalUnits));
  int get totalBookedUnits => hotels.fold(0, (sum, h) => sum + h.rooms.fold(0, (rSum, r) => rSum + r.bookedUnits));
  double get totalRevenue => profile?.totalEarningsUSD ?? 0.0;
  double get pendingPayout => profile?.pendingPayoutUSD ?? 0.0;
  int get pendingReservationsCount => reservations.where((r) => r.isPending).length;
  int get activeReservationsCount => reservations.where((r) => r.isConfirmed || r.isCheckedIn).length;

  HotelPartnerState copyWith({
    HotelPartnerProfile? profile,
    List<PartnerHotelListing>? hotels,
    List<PartnerReservation>? reservations,
    List<PartnerPayoutRecord>? payoutHistory,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    PartnerReservation? scannedReservation,
    bool clearScannedReservation = false,
    String? scanSuccessMessage,
    bool clearScanMessage = false,
  }) {
    return HotelPartnerState(
      profile: profile ?? this.profile,
      hotels: hotels ?? this.hotels,
      reservations: reservations ?? this.reservations,
      payoutHistory: payoutHistory ?? this.payoutHistory,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      scannedReservation: clearScannedReservation ? null : (scannedReservation ?? this.scannedReservation),
      scanSuccessMessage: clearScanMessage ? null : (scanSuccessMessage ?? this.scanSuccessMessage),
    );
  }
}

final hotelPartnerControllerProvider = StateNotifierProvider<HotelPartnerController, HotelPartnerState>((ref) {
  final repository = ref.watch(hotelPartnerRepositoryProvider);
  return HotelPartnerController(repository);
});

class HotelPartnerController extends StateNotifier<HotelPartnerState> {
  final HotelPartnerRepository _repository;

  HotelPartnerController(this._repository) : super(const HotelPartnerState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _repository.getProfile();
      final hotels = await _repository.getPartnerHotels();
      final reservations = await _repository.getReservations();
      final payoutHistory = await _repository.getPayoutHistory();
      state = state.copyWith(
        profile: profile,
        hotels: hotels,
        reservations: reservations,
        payoutHistory: payoutHistory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> saveHotelListing(PartnerHotelListing hotel) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.saveHotel(hotel);
      final hotels = await _repository.getPartnerHotels();
      state = state.copyWith(hotels: hotels, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> toggleHotelStatus(String hotelId) async {
    try {
      await _repository.toggleHotelStatus(hotelId);
      final hotels = await _repository.getPartnerHotels();
      state = state.copyWith(hotels: hotels);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> deleteHotel(String hotelId) async {
    try {
      await _repository.deleteHotel(hotelId);
      final hotels = await _repository.getPartnerHotels();
      state = state.copyWith(hotels: hotels);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Reservation Workflows: Accept, Reject, Complete
  Future<bool> acceptReservation(String reservationId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.acceptReservation(reservationId);
      final reservations = await _repository.getReservations();
      state = state.copyWith(reservations: reservations, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> rejectReservation(String reservationId, String reason) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.rejectReservation(reservationId, reason);
      final reservations = await _repository.getReservations();
      state = state.copyWith(reservations: reservations, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> completeReservation(String reservationId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.completeReservation(reservationId);
      final reservations = await _repository.getReservations();
      final profile = await _repository.getProfile();
      state = state.copyWith(
        reservations: reservations,
        profile: profile,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  // Check-In QR Verification
  Future<bool> verifyCheckInCode(String reference) async {
    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      clearScanMessage: true,
      clearScannedReservation: true,
    );
    try {
      final reservation = await _repository.verifyCheckInCode(reference);
      if (reservation != null) {
        final reservations = await _repository.getReservations();
        state = state.copyWith(
          reservations: reservations,
          scannedReservation: reservation,
          scanSuccessMessage: 'Check-In Verified for ${reservation.guestName} (${reservation.bookingReference})',
          isSaving: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Invalid or not found booking reference: $reference',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  // Seasonal Pricing Rules
  Future<void> saveSeasonalRule(String hotelId, SeasonalPriceRule rule) async {
    state = state.copyWith(isSaving: true);
    try {
      await _repository.saveSeasonalRule(hotelId, rule);
      final hotels = await _repository.getPartnerHotels();
      state = state.copyWith(hotels: hotels, isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteSeasonalRule(String hotelId, String ruleId) async {
    state = state.copyWith(isSaving: true);
    try {
      await _repository.deleteSeasonalRule(hotelId, ruleId);
      final hotels = await _repository.getPartnerHotels();
      state = state.copyWith(hotels: hotels, isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }

  // Document Verification
  Future<void> submitDocument(String hotelId, PartnerVerificationDocument doc) async {
    state = state.copyWith(isSaving: true);
    try {
      await _repository.submitDocument(hotelId, doc);
      final hotels = await _repository.getPartnerHotels();
      state = state.copyWith(hotels: hotels, isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }

  // Payout Management
  Future<bool> requestPayout({
    required double amountUSD,
    required PartnerPayoutAccount account,
  }) async {
    if (amountUSD <= 0 || (state.profile != null && amountUSD > state.profile!.pendingPayoutUSD)) {
      state = state.copyWith(errorMessage: 'Invalid payout amount');
      return false;
    }
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.requestPayout(amountUSD: amountUSD, account: account);
      final profile = await _repository.getProfile();
      final payoutHistory = await _repository.getPayoutHistory();
      state = state.copyWith(
        profile: profile,
        payoutHistory: payoutHistory,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  // Admin Approval & Verification
  Future<bool> approveHotelByAdmin(String hotelId) async {
    state = state.copyWith(isSaving: true);
    try {
      await _repository.approveHotel(hotelId);
      final hotels = await _repository.getPartnerHotels();
      state = state.copyWith(hotels: hotels, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> rejectHotelByAdmin(String hotelId, String feedback) async {
    state = state.copyWith(isSaving: true);
    try {
      await _repository.rejectHotel(hotelId, feedback);
      final hotels = await _repository.getPartnerHotels();
      state = state.copyWith(hotels: hotels, isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }
}
