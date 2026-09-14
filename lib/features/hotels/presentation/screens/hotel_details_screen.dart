import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/presentation/controllers/booking_controller.dart';
import '../../../booking/presentation/screens/booking_summary_screen.dart';
import '../../../favorites/domain/entities/favorite_item_entity.dart';
import '../../../favorites/presentation/controllers/favorites_controller.dart';
import '../../domain/entities/hotel_entity.dart';
import '../widgets/hotel_amenities_grid.dart';

class HotelDetailsScreen extends ConsumerStatefulWidget {
  final HotelEntity hotel;

  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  ConsumerState<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends ConsumerState<HotelDetailsScreen> {
  int _selectedImageIndex = 0;
  int _selectedRoomIndex = 0;

  void _handleBooking() async {
    final user = ref.read(authStateProvider).value;
    final userId = user?.id ?? 'guest_usr';
    final hotel = widget.hotel;

    if (hotel.isAffiliate) {
      final targetUrl = hotel.affiliateUrl ?? 'https://www.booking.com/';
      await ref.read(bookingControllerProvider.notifier).trackAffiliateRedirect(
        userId: userId,
        productType: 'hotel',
        productId: hotel.id,
        rawTargetUrl: targetUrl,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.tr('booking_redirecting_partner')),
            content: Text(context.tr('booking_redirecting_desc')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final uri = Uri.parse(targetUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(context.tr('booking_open_partner_site')),
              ),
            ],
          ),
        );
      }
    } else {
      // Direct Booking
      final selectedRoom = hotel.rooms.isNotEmpty ? hotel.rooms[_selectedRoomIndex] : null;
      final roomName = selectedRoom != null ? ' - ${selectedRoom.getName(isArabic: ref.read(languageProvider.notifier).isArabic)}' : '';
      final price = selectedRoom != null ? selectedRoom.pricePerNightUSD : hotel.pricePerNightUSD;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookingSummaryScreen(
            bookingType: BookingType.hotel,
            itemId: hotel.id,
            itemName: '${hotel.getName(isArabic: ref.read(languageProvider.notifier).isArabic)}$roomName',
            itemSubtitle: '${hotel.getCity(isArabic: ref.read(languageProvider.notifier).isArabic)}, ${hotel.getCountry(isArabic: ref.read(languageProvider.notifier).isArabic)}',
            itemImageUrl: hotel.mainImageUrl,
            startDate: DateTime.now().add(const Duration(days: 5)),
            endDate: DateTime.now().add(const Duration(days: 9)),
            basePriceUSD: price * 4, // 4 nights default
            taxesUSD: hotel.taxesPerNightUSD * 4,
            isAffiliate: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final hotel = widget.hotel;
    final isFav = ref.watch(favoritesControllerProvider.notifier).isFavorite(hotel.id);
    final images = hotel.galleryImages.isNotEmpty ? hotel.galleryImages : [hotel.mainImageUrl];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Collapsible App Bar with Image Gallery Slider
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (idx) => setState(() => _selectedImageIndex = idx),
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primaryContainer,
                          child: const Icon(Icons.hotel, size: 64, color: AppColors.primary),
                        ),
                      );
                    },
                  ),
                  // Image Dots
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (idx) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedImageIndex == idx ? AppColors.primary : Colors.white70,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.error : Colors.white,
                ),
                onPressed: () {
                  ref.read(favoritesControllerProvider.notifier).toggleFavorite(
                    FavoriteItemEntity(
                      id: hotel.id,
                      title: hotel.getName(isArabic: isArabic),
                      subtitle: '${hotel.getCity(isArabic: isArabic)}, ${hotel.getCountry(isArabic: isArabic)}',
                      imageUrl: hotel.mainImageUrl,
                      priceUSD: hotel.pricePerNightUSD,
                      type: 'hotel',
                      rating: hotel.userRating,
                      createdAt: DateTime.now(),
                    ),
                  );
                },
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),

          // Hotel Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title, Stars & Partner Channel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingStars(rating: hotel.starRating.toDouble(), size: 16),
                      if (hotel.isAffiliate)
                        BadgeChip(
                          label: context.tr('affiliate_booking'),
                          backgroundColor: AppColors.warningLight,
                          textColor: AppColors.warning,
                        )
                      else
                        BadgeChip(
                          label: context.tr('direct_booking'),
                          backgroundColor: AppColors.successLight,
                          textColor: AppColors.success,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    hotel.getName(isArabic: isArabic),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Address & Score
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          '★ ${hotel.userRating}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Overview / Description
                  Text(
                    context.tr('hotel_overview'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    hotel.getDescription(isArabic: isArabic),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amenities Grid
                  Text(
                    context.tr('hotel_amenities'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  HotelAmenitiesGrid(amenities: hotel.amenities),
                  const SizedBox(height: AppSpacing.lg),

                  // Room Options
                  if (hotel.rooms.isNotEmpty) ...[
                    Text(
                      context.tr('hotel_room_options'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...List.generate(hotel.rooms.length, (idx) {
                      final room = hotel.rooms[idx];
                      final isSelected = _selectedRoomIndex == idx;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          onTap: () => setState(() => _selectedRoomIndex = idx),
                          customBorder: isSelected
                              ? const BorderSide(color: AppColors.primary, width: 2)
                              : null,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: idx,
                                groupValue: _selectedRoomIndex,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() => _selectedRoomIndex = val ?? 0),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      room.getName(isArabic: isArabic),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      '${room.bedType} • Max ${room.maxGuests} Guests',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                    if (room.perks.isNotEmpty)
                                      Text(
                                        room.perks.join(' • '),
                                        style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w500),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                AppCurrencyFormatter.format(room.pricePerNightUSD, currency, locale: isArabic ? 'ar' : 'en'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Check-in / Out & Cancellation Policy
                  CustomCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${context.tr('hotel_check_in_time')} ${hotel.checkInTime}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${context.tr('hotel_check_out_time')} ${hotel.checkOutTime}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hotel.getCancellationPolicy(isArabic: isArabic),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('hotel_per_night'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  Text(
                    AppCurrencyFormatter.format(hotel.pricePerNightUSD, currency, locale: isArabic ? 'ar' : 'en'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: CustomButton(
                  text: hotel.isAffiliate ? context.tr('affiliate_booking') : context.tr('book_now'),
                  icon: hotel.isAffiliate ? Icons.open_in_new_rounded : Icons.check_circle_outline_rounded,
                  onPressed: _handleBooking,
                  type: hotel.isAffiliate ? ButtonType.secondary : ButtonType.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
