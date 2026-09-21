import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../domain/entities/hotel_partner_entity.dart';
import '../controllers/hotel_partner_controller.dart';
import 'hotel_registration_wizard_screen.dart';

class HotelPartnerDashboardScreen extends ConsumerStatefulWidget {
  const HotelPartnerDashboardScreen({super.key});

  @override
  ConsumerState<HotelPartnerDashboardScreen> createState() => _HotelPartnerDashboardScreenState();
}

class _HotelPartnerDashboardScreenState extends ConsumerState<HotelPartnerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _qrCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qrCodeController.dispose();
    super.dispose();
  }

  void _openAddHotel() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HotelRegistrationWizardScreen()),
    );
  }

  void _openEditHotel(PartnerHotelListing hotel) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HotelRegistrationWizardScreen(editHotel: hotel)),
    );
  }

  void _verifyCode() async {
    final code = _qrCodeController.text.trim();
    if (code.isEmpty) return;

    final success = await ref.read(hotelPartnerControllerProvider.notifier).verifyCheckInCode(code);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('partner.check_in_verified')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _qrCodeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('partner.invalid_booking_code')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final state = ref.watch(hotelPartnerControllerProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          context.tr('partner.portal_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(hotelPartnerControllerProvider.notifier).loadData(),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _openAddHotel,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_business_rounded, color: Colors.white),
              label: Text(context.tr('partner.add_hotel'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(hotelPartnerControllerProvider.notifier).loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Host Profile Header Banner
                    _buildHostHeaderCard(profile, isArabic),

                    // Top KPI Metrics
                    _buildKpiMetrics(state),

                    // Tab Bar
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 16),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        tabs: [
                          Tab(icon: const Icon(Icons.apartment_rounded, size: 20), text: context.tr('partner.tabs.my_hotels')),
                          Tab(icon: const Icon(Icons.event_note_rounded, size: 20), text: context.tr('partner.tabs.reservations')),
                          Tab(icon: const Icon(Icons.qr_code_scanner_rounded, size: 20), text: context.tr('partner.tabs.qr_scanner')),
                          Tab(icon: const Icon(Icons.account_balance_wallet_rounded, size: 20), text: context.tr('partner.tabs.earnings')),
                        ],
                        onTap: (_) => setState(() {}),
                      ),
                    ),

                    // Tab Views Container
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildHotelsTab(state, isArabic),
                          _buildReservationsTab(state),
                          _buildQrScannerTab(state),
                          _buildEarningsTab(state),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHostHeaderCard(HotelPartnerProfile? profile, bool isArabic) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile?.businessName ?? 'Braknia Hospitality Group',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Colors.amberAccent, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.ownerName ?? 'Tahar Braknia',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: minAxisSize(),
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      context.tr('partner.verified_host'),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  MainAxisSize minAxisSize() => MainAxisSize.min;

  Widget _buildKpiMetrics(HotelPartnerState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildKpiCard(
              title: context.tr('partner.kpi_total_earnings'),
              value: '\$${state.totalRevenue.toStringAsFixed(0)}',
              icon: Icons.payments_rounded,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildKpiCard(
              title: context.tr('partner.kpi_active_hotels'),
              value: '${state.totalActiveHotels}',
              icon: Icons.hotel_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildKpiCard(
              title: context.tr('partner.kpi_bookings'),
              value: '${state.reservations.length}',
              icon: Icons.book_online_rounded,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Tab 1: My Hotels
  Widget _buildHotelsTab(HotelPartnerState state, bool isArabic) {
    if (state.hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apartment_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(context.tr('partner.no_hotels_registered'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _openAddHotel,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(context.tr('partner.add_hotel'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.hotels.length,
      itemBuilder: (ctx, idx) {
        final hotel = state.hotels[idx];
        final isActive = hotel.status == PartnerListingStatus.active;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image with Badges
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.network(
                      hotel.mainCoverImageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 140, color: Colors.grey.shade200),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.success : Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive ? context.tr('partner.status_active') : context.tr('partner.status_paused'),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${hotel.userRating}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Hotel Info
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hotel.getName(isArabic: isArabic),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${hotel.pricePerNightUSD.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        Text(' ${context.tr('hotel_per_night')}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hotel.getCity(isArabic: isArabic)}, ${hotel.getCountry(isArabic: isArabic)} • ${hotel.rooms.length} ${context.tr('hotel_rooms')}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        // Toggle Status Switch
                        Text(
                          isActive ? context.tr('partner.listing_online') : context.tr('partner.listing_offline'),
                          style: TextStyle(fontSize: 12, color: isActive ? AppColors.success : Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                        Switch(
                          value: isActive,
                          activeColor: AppColors.success,
                          onChanged: (_) => ref.read(hotelPartnerControllerProvider.notifier).toggleHotelStatus(hotel.id),
                        ),
                        const Spacer(),
                        // Edit Button
                        OutlinedButton.icon(
                          onPressed: () => _openEditHotel(hotel),
                          icon: const Icon(Icons.edit, size: 15),
                          label: Text(context.tr('common.edit'), style: const TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () => _confirmDeleteHotel(hotel.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteHotel(String hotelId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('partner.delete_hotel_title')),
        content: Text(context.tr('partner.delete_hotel_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(context.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(hotelPartnerControllerProvider.notifier).deleteHotel(hotelId);
              Navigator.of(ctx).pop();
            },
            child: Text(context.tr('delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Tab 2: Reservations Feed
  Widget _buildReservationsTab(HotelPartnerState state) {
    if (state.reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(context.tr('partner.no_reservations_yet'), style: const TextStyle(fontSize: 15, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.reservations.length,
      itemBuilder: (ctx, idx) {
        final res = state.reservations[idx];
        final isCheckedIn = res.status == PartnerReservationStatus.checkedIn;
        final isConfirmed = res.status == PartnerReservationStatus.confirmed;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    res.bookingReference,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCheckedIn
                          ? AppColors.primaryContainer
                          : isConfirmed
                              ? AppColors.successLight
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      res.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCheckedIn ? AppColors.primaryDark : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                res.guestName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                '${res.hotelName} • ${res.roomName}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.date_range, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('MMM dd').format(res.checkInDate)} - ${DateFormat('MMM dd, yyyy').format(res.checkOutDate)} (${res.numberOfNights} nights)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Payout: \$${res.netHostPayoutUSD.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 14),
                  ),
                  Text(
                    'Fee: \$${res.platformFeeUSD.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Tab 3: QR Scanner & Check-In Verification Terminal
  Widget _buildQrScannerTab(HotelPartnerState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, size: 50, color: AppColors.primary),
                ),
                const SizedBox(height: 14),
                Text(
                  context.tr('partner.qr_scan_instruction'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('partner.qr_scan_subtext'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // Code Input Field
                TextField(
                  controller: _qrCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: context.tr('partner.enter_booking_ref'),
                    hintText: 'e.g. TRV-ALG-8891',
                    prefixIcon: const Icon(Icons.qr_code),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle, color: AppColors.primary),
                      onPressed: _verifyCode,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Fast Verification Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _verifyCode,
                    child: Text(
                      context.tr('partner.verify_check_in_btn'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Scanned Result Card
          if (state.scannedReservation != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('partner.verified_checked_in'),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Text('Guest: ${state.scannedReservation!.guestName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Hotel: ${state.scannedReservation!.hotelName}'),
                  Text('Room: ${state.scannedReservation!.roomName}'),
                  Text('Ref: ${state.scannedReservation!.bookingReference}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Tab 4: Earnings & Commission Wallet
  Widget _buildEarningsTab(HotelPartnerState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('partner.available_payout'),
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${state.pendingPayout.toStringAsFixed(2)} USD',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: state.pendingPayout > 0
                        ? () async {
                            await ref.read(hotelPartnerControllerProvider.notifier).requestPayout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.tr('partner.payout_requested_success')),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text(
                      context.tr('partner.withdraw_funds_btn'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Commission Transparent Policy Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.handshake_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('partner.commission_model_title'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('partner.commission_model_desc'),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
