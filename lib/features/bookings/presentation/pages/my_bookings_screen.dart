import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../widgets/booking_card.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allBookings = ref.watch(bookingListProvider);

    final upcoming = allBookings
        .where((b) => b.status == BookingStatus.confirmed || b.status == BookingStatus.pending)
        .where((b) => b.startDate.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    final completed = allBookings
        .where((b) => b.status == BookingStatus.confirmed && b.startDate.isBefore(DateTime.now()))
        .toList();

    final cancelled = allBookings
        .where((b) => b.status == BookingStatus.cancelled || b.status == BookingStatus.failed)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          context.tr('my_bookings_title'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.primaryLight : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.tr('my_bookings_upcoming')),
                  if (upcoming.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${upcoming.length}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: context.tr('my_bookings_completed')),
            Tab(text: context.tr('my_bookings_cancelled')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Upcoming Tab
          _buildBookingList(
            context,
            upcoming,
            emptyTitle: context.tr('my_bookings_empty_title'),
            emptyDesc: context.tr('my_bookings_empty_desc'),
          ),

          // 2. Completed Tab
          _buildBookingList(
            context,
            completed,
            emptyTitle: 'No Completed Trips',
            emptyDesc: 'Your past trips and completed journeys will appear here.',
          ),

          // 3. Cancelled Tab
          _buildBookingList(
            context,
            cancelled,
            emptyTitle: 'No Cancelled Bookings',
            emptyDesc: 'Cancelled or failed reservations will be archived here.',
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    List<Booking> list, {
    required String emptyTitle,
    required String emptyDesc,
  }) {
    if (list.isEmpty) {
      return EmptyStateView(
        title: emptyTitle,
        description: emptyDesc,
        actionText: 'Explore Travel Offers',
        onActionTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (route) => false,
          );
        },
      );
    }

    return ResponsiveWrapper(
      maxWidth: 900,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final booking = list[index];
          return BookingCard(booking: booking);
        },
      ),
    );
  }
}
