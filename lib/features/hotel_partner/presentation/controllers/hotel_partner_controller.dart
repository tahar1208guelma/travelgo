import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/hotel_partner_repository.dart';
import '../../domain/entities/hotel_partner_entity.dart';

class HotelPartnerState {
  final HotelPartnerProfile? profile;
  final List<PartnerHotelListing> hotels;
  final List<PartnerReservation> reservations;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final PartnerReservation? scannedReservation;
  final String? scanSuccessMessage;

  const HotelPartnerState({
    this.profile,
    this.hotels = const [],
    this.reservations = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.scannedReservation,
    this.scanSuccessMessage,
  });

  int get totalActiveHotels => hotels.where((h) => h.status == PartnerListingStatus.active).length;
  int get totalRooms => hotels.fold(0, (sum, h) => sum + h.rooms.fold(0, (rSum, r) => rSum + r.totalUnits));
  double get totalRevenue => profile?.totalEarningsUSD ?? 0.0;
  double get pendingPayout => profile?.pendingPayoutUSD ?? 0.0;
  int get activeReservationsCount => reservations.where((r) => r.status == PartnerReservationStatus.confirmed || r.status == PartnerReservationStatus.checkedIn).length;

  HotelPartnerState copyWith({
    HotelPartnerProfile? profile,
    List<PartnerHotelListing>? hotels,
    List<PartnerReservation>? reservations,
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
      state = state.copyWith(
        profile: profile,
        hotels: hotels,
        reservations: reservations,
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

  Future<bool> verifyCheckInCode(String reference) async {
    state = state.copyWith(isSaving: true, errorMessage: null, clearScanMessage: true, clearScannedReservation: true);
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

  Future<void> requestPayout() async {
    if (state.profile == null || state.profile!.pendingPayoutUSD <= 0) return;
    state = state.copyWith(isSaving: true);
    try {
      final updatedProfile = HotelPartnerProfile(
        id: state.profile!.id,
        ownerName: state.profile!.ownerName,
        businessName: state.profile!.businessName,
        email: state.profile!.email,
        phone: state.profile!.phone,
        isVerified: state.profile!.isVerified,
        totalEarningsUSD: state.profile!.totalEarningsUSD,
        pendingPayoutUSD: 0.0,
        joinedAt: state.profile!.joinedAt,
      );
      await _repository.saveProfile(updatedProfile);
      state = state.copyWith(profile: updatedProfile, isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }
}
