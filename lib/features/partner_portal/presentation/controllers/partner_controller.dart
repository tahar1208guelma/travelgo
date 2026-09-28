import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/partner_repository_impl.dart';
import '../../domain/entities/partner_entity.dart';

final partnerRepositoryProvider = Provider<PartnerRepository>((ref) {
  return PartnerRepositoryImpl();
});

final currentPartnerUserProvider = StateProvider<PartnerUser?>((ref) => PartnerUser(
      id: 'prt_001',
      businessName: 'Sahara Luxury Expeditions & Stays',
      contactName: 'Karim Benali',
      email: 'karim@saharatours.dz',
      phone: '+213 555 123 456',
      type: PartnerType.hotelOwner,
      isApprovedByAdmin: true,
      joinedAt: DateTime(2026, 1, 15),
    ));

final partnerListingsProvider = FutureProvider.autoDispose<List<PartnerListingEntity>>((ref) async {
  final repo = ref.watch(partnerRepositoryProvider);
  final user = ref.watch(currentPartnerUserProvider);
  if (user == null) return [];
  return repo.getPartnerListings(user.id);
});

final partnerBookingsProvider = FutureProvider.autoDispose<List<PartnerBookingRequest>>((ref) async {
  final repo = ref.watch(partnerRepositoryProvider);
  final user = ref.watch(currentPartnerUserProvider);
  if (user == null) return [];
  return repo.getPartnerBookings(user.id);
});

final adminPendingListingsProvider = FutureProvider.autoDispose<List<PartnerListingEntity>>((ref) async {
  final repo = ref.watch(partnerRepositoryProvider);
  return repo.getAllPendingAdminListings();
});
