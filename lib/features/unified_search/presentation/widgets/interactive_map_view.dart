import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/unified_search_result_entity.dart';
import '../controllers/unified_search_controller.dart';
import 'unified_search_card.dart';

/// Interactive Travel Map View with Airbnb/Leaflet-style Price Pin Markers,
/// Zoom Controls, Interactive Selection, and Bottom Spotlight Carousel
class InteractiveMapView extends ConsumerStatefulWidget {
  final List<UnifiedSearchResultEntity> items;
  final void Function(UnifiedSearchResultEntity item) onItemTap;

  const InteractiveMapView({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  ConsumerState<InteractiveMapView> createState() => _InteractiveMapViewState();
}

class _InteractiveMapViewState extends ConsumerState<InteractiveMapView> {
  final TransformationController _transformController = TransformationController();
  double _currentScale = 1.0;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _currentScale = min(_currentScale + 0.3, 3.0);
      _transformController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = max(_currentScale - 0.3, 0.6);
      _transformController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _resetMap() {
    setState(() {
      _currentScale = 1.0;
      _transformController.value = Matrix4.identity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final currency = ref.watch(currencyProvider);
    final selectedItem = ref.watch(selectedMapItemProvider);

    return Stack(
      children: [
        // 1. Interactive Vector/Stylized Map Canvas (Pan & Zoomable)
        InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.5,
          maxScale: 3.5,
          boundaryMargin: const EdgeInsets.all(300),
          child: SizedBox(
            width: 1400,
            height: 1000,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Stylized Leaflet / Mapbox Cartographic Canvas
                CustomPaint(
                  painter: _MapCanvasPainter(isDark: isDark),
                ),

                // Geo Markers with Price Tags on Map
                ...widget.items.map((item) {
                  // Map coordinates to 2D canvas space (Normalized Mercator Projection Simulation)
                  final double x = _projectLongitude(item.coordinates.longitude, 1400);
                  final double y = _projectLatitude(item.coordinates.latitude, 1000);
                  final bool isSelected = selectedItem?.id == item.id;

                  return Positioned(
                    left: x - 40,
                    top: y - 24,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedMapItemProvider.notifier).state = item;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 12 : 8,
                          vertical: isSelected ? 8 : 5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.cardDarkElevated : Colors.white),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.secondary : AppColors.primary),
                            width: isSelected ? 2.0 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.4)
                                  : Colors.black.withValues(alpha: 0.2),
                              blurRadius: isSelected ? 12 : 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.type == AccommodationType.desertCamp
                                  ? Icons.terrain_rounded
                                  : (item.type == AccommodationType.apartment
                                      ? Icons.apartment_rounded
                                      : Icons.hotel_rounded),
                              size: 13,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.secondaryLight : AppColors.primary),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppCurrencyFormatter.format(item.price, currency, locale: isArabic ? 'ar' : 'en'),
                              style: TextStyle(
                                fontSize: isSelected ? 13 : 11,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // 2. Map Floating Controls (Zoom In, Zoom Out, Recenter)
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapControlBtn(
                icon: Icons.add_rounded,
                tooltip: 'Zoom In',
                onTap: _zoomIn,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildMapControlBtn(
                icon: Icons.remove_rounded,
                tooltip: 'Zoom Out',
                onTap: _zoomOut,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildMapControlBtn(
                icon: Icons.my_location_rounded,
                tooltip: 'Reset Center',
                onTap: _resetMap,
                isDark: isDark,
              ),
            ],
          ),
        ),

        // 3. Leaflet / OpenStreetMap Provider Attribution Pill
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.cardDark : Colors.white).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.map_rounded, size: 14, color: AppColors.secondary),
                const SizedBox(width: 5),
                Text(
                  'Leaflet Engine • Live Coordinates',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Bottom Spotlight Selected Card Carousel
        if (selectedItem != null)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Stack(
                  children: [
                    UnifiedSearchCard(
                      item: selectedItem,
                      onTap: () => widget.onItemTap(selectedItem),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => ref.read(selectedMapItemProvider.notifier).state = null,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMapControlBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: isDark ? AppColors.secondaryLight : AppColors.primary),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  double _projectLongitude(double lng, double width) {
    // Map longitudes [-10, 60] -> [50, 1350]
    final normalized = (lng + 15) / 75;
    return (normalized.clamp(0.05, 0.95)) * width;
  }

  double _projectLatitude(double lat, double height) {
    // Map latitudes [15, 55] -> [950, 50] (inverted y)
    final normalized = 1.0 - ((lat - 15) / 40);
    return (normalized.clamp(0.05, 0.95)) * height;
  }
}

/// Custom Leaflet/Mapbox Cartographic Vector Painter
class _MapCanvasPainter extends CustomPainter {
  final bool isDark;

  _MapCanvasPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Landmass / Island shapes
    final landPaint = Paint()..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final coastlinePaint = Paint()
      ..color = (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw Mediterranean & Saharan Landmass curves
    final path = Path();
    path.moveTo(0, size.height * 0.25);
    path.cubicTo(size.width * 0.3, size.height * 0.15, size.width * 0.6, size.height * 0.35, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, coastlinePaint);

    // Water ripple lines
    final waterLinePaint = Paint()
      ..color = (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFBAE6FD)).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 6; i++) {
      final y = size.height * 0.05 + i * 35;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), waterLinePaint);
    }

    // Grid Coordinates Lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) => oldDelegate.isDark != isDark;
}
