import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../hotel_partner/data/repositories/hotel_partner_repository.dart';
import '../../../hotel_partner/domain/entities/hotel_partner_entity.dart';
import '../../../hotel_partner/presentation/controllers/hotel_partner_controller.dart';
import '../../domain/entities/partner_entity.dart';
import '../controllers/partner_controller.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRejectDialog(String hotelId, String hotelTitle) {
    final reasonCtrl = TextEditingController(text: 'Missing or expired tourism classification document.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Listing: $hotelTitle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a constructive feedback reason for the partner so they can update and resubmit.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason / Feedback Note',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              await ref.read(hotelPartnerControllerProvider.notifier).rejectHotelByAdmin(hotelId, reason);
              await ref.read(partnerRepositoryProvider).rejectListing(hotelId, reason: reason);
              ref.invalidate(adminPendingListingsProvider);
              ref.invalidate(allAdminListingsProvider);
              if (mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Listing "$hotelTitle" rejected.')),
                );
              }
            },
            child: const Text('Confirm Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHotelDetailsDialog(PartnerHotelListing hotel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(hotel.nameEn),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(hotel.mainCoverImageUrl, height: 140, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              Text('Location: ${hotel.address}, ${hotel.cityEn}, ${hotel.countryEn}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Star Rating: ${hotel.starRating} Stars • Base Rate: \$${hotel.pricePerNightUSD.toStringAsFixed(0)}/night'),
              const Divider(height: 16),
              const Text('Verification Documents:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              if (hotel.documents.isEmpty)
                const Text('No documents uploaded', style: TextStyle(color: Colors.grey, fontSize: 12))
              else
                ...hotel.documents.map((d) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${d.getDocumentTitle()}: ${d.documentNumber}', style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
              const Divider(height: 16),
              const Text('Room Inventory:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ...hotel.rooms.map((r) => Text('• ${r.nameEn} (${r.category.name}): ${r.totalUnits} units @ \$${r.pricePerNightUSD.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12))),
              if (hotel.seasonalRules.isNotEmpty) ...[
                const Divider(height: 16),
                const Text('Seasonal Pricing Rules:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ...hotel.seasonalRules.map((s) => Text('• ${s.nameEn}: ${(s.priceMultiplier * 100).round()}% rate multiplier', style: const TextStyle(fontSize: 12))),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final hotelPartnerState = ref.watch(hotelPartnerControllerProvider);
    final pendingPortalListingsAsync = ref.watch(adminPendingListingsProvider);

    final pendingHotels = hotelPartnerState.hotels.where((h) => h.isPendingReview).toList();
    final approvedHotels = hotelPartnerState.hotels.where((h) => h.isActive).toList();
    final rejectedHotels = hotelPartnerState.hotels.where((h) => h.isRejected).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_rounded, color: AppColors.secondary, size: 22),
            const SizedBox(width: 8),
            Text(
              isArabic ? 'لوحة تحكم المشرف (Admin)' : 'Super Admin Approval Panel',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.secondaryLight : AppColors.primary,
          indicatorColor: isDark ? AppColors.secondaryLight : AppColors.primary,
          tabs: [
            Tab(text: 'Pending (${pendingHotels.length + (pendingPortalListingsAsync.value?.length ?? 0)})'),
            Tab(text: 'Live / Approved (${approvedHotels.length})'),
            Tab(text: 'Rejected (${rejectedHotels.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Pending Approvals Tab
          _buildPendingTab(isDark, isArabic, pendingHotels, pendingPortalListingsAsync),

          // 2. Approved / Live in Search Tab
          _buildApprovedTab(isDark, isArabic, approvedHotels),

          // 3. Rejected Tab
          _buildRejectedTab(isDark, isArabic, rejectedHotels),
        ],
      ),
    );
  }

  Widget _buildPendingTab(
    bool isDark,
    bool isArabic,
    List<PartnerHotelListing> pendingHotels,
    AsyncValue<List<PartnerListingEntity>> pendingPortalListingsAsync,
  ) {
    final portalItems = pendingPortalListingsAsync.value ?? [];

    if (pendingHotels.isEmpty && portalItems.isEmpty) {
      return const Center(
        child: EmptyStateView(
          icon: Icons.verified_rounded,
          title: 'All Caught Up! 🎉',
          subtitle: 'No partner properties waiting for admin verification.',
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Notice
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded, color: AppColors.warning, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Partner Listing Quality & Governance Queue',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Review submitted legal documents, room inventory, and seasonal rates. Approved listings are published live to Search Aggregator.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Hotel Partner Wizard Submissions
          if (pendingHotels.isNotEmpty) ...[
            Text('Hotel Partner Submissions (${pendingHotels.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingHotels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final hotel = pendingHotels[idx];
                return CustomCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              hotel.mainCoverImageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey.shade300),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(hotel.nameEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text('📍 ${hotel.address}, ${hotel.cityEn}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('\$${hotel.pricePerNightUSD.toStringAsFixed(0)}/night • ${hotel.rooms.length} Rooms • ${hotel.documents.length} Docs', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => _showHotelDetailsDialog(hotel),
                            icon: const Icon(Icons.visibility_outlined, size: 16),
                            label: const Text('Inspect Details', style: TextStyle(fontSize: 12)),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () => _showRejectDialog(hotel.id, hotel.nameEn),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            child: const Text('Reject', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await ref.read(hotelPartnerControllerProvider.notifier).approveHotelByAdmin(hotel.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Listing "${hotel.nameEn}" APPROVED & published to live search! 🚀'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                            label: const Text('Approve & Publish', style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Partner Portal Submissions
          if (portalItems.isNotEmpty) ...[
            Text('Partner Portal Submissions (${portalItems.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: portalItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final item = portalItems[idx];
                return CustomCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(imageUrl: item.mainImageUrl, width: 80, height: 80, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text('📍 ${item.address}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('\$${item.pricePerNightUSD.toStringAsFixed(0)}/night • Category: ${item.category}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => _showRejectDialog(item.id, item.title),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            child: const Text('Reject', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await ref.read(partnerRepositoryProvider).approveListing(item.id);
                              ref.invalidate(adminPendingListingsProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Listing "${item.title}" APPROVED & published! 🚀'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                            label: const Text('Approve & Publish', style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApprovedTab(bool isDark, bool isArabic, List<PartnerHotelListing> approvedHotels) {
    if (approvedHotels.isEmpty) {
      return const Center(child: Text('No approved live properties yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: approvedHotels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final hotel = approvedHotels[idx];
        return CustomCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(hotel.mainCoverImageUrl, width: 70, height: 70, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hotel.nameEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${hotel.cityEn}, ${hotel.countryEn}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    const BadgeChip(label: 'LIVE IN SEARCH', backgroundColor: AppColors.successLight, textColor: AppColors.success, fontSize: 10),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showHotelDetailsDialog(hotel),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRejectedTab(bool isDark, bool isArabic, List<PartnerHotelListing> rejectedHotels) {
    if (rejectedHotels.isEmpty) {
      return const Center(child: Text('No rejected properties.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: rejectedHotels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final hotel = rejectedHotels[idx];
        return CustomCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(hotel.mainCoverImageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hotel.nameEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${hotel.cityEn}, ${hotel.countryEn}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const BadgeChip(label: 'REJECTED', backgroundColor: Color(0xFFFFEBEE), textColor: AppColors.error, fontSize: 10),
                      ],
                    ),
                  ),
                ],
              ),
              if (hotel.adminFeedback != null) ...[
                const SizedBox(height: 8),
                Text('Feedback: ${hotel.adminFeedback}', style: const TextStyle(fontSize: 12, color: AppColors.error)),
              ],
            ],
          ),
        );
      },
    );
  }
}
