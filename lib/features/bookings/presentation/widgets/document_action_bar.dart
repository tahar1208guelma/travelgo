import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/share_service.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../pages/pdf_preview_screen.dart';

class DocumentActionBar extends ConsumerWidget {
  final Booking booking;
  final bool isVertical;

  const DocumentActionBar({
    super.key,
    required this.booking,
    this.isVertical = false,
  });

  void _showFeedback(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        action: isError
            ? null
            : SnackBarAction(
                label: 'DISMISS',
                textColor: Colors.white,
                onPressed: () {},
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentOperationProvider(booking.bookingReference));
    final notifier = ref.read(documentOperationProvider(booking.bookingReference).notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. View / Preview PDF Button (Primary)
          ElevatedButton.icon(
            onPressed: state.isGenerating
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PdfPreviewScreen(booking: booking),
                      ),
                    );
                  },
            icon: state.isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.picture_as_pdf_rounded, size: 20),
            label: Text(state.isGenerating ? 'Generating PDF...' : 'View PDF Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 2. Save PDF Button
          OutlinedButton.icon(
            onPressed: state.isSaving
                ? null
                : () async {
                    final path = await notifier.saveDocument();
                    if (context.mounted) {
                      if (path != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Document saved successfully!\n$path'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 4),
                            action: SnackBarAction(
                              label: 'OPEN',
                              textColor: Colors.white,
                              onPressed: () {
                                ref.read(shareServiceProvider).openSavedFile(path);
                              },
                            ),
                          ),
                        );
                      } else {
                        _showFeedback(
                          context,
                          state.errorMessage ?? 'Failed to save document. Please try again.',
                          isError: true,
                        );
                      }
                    }
                  },
            icon: state.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.download_rounded, size: 20),
            label: Text(state.isSaving ? 'Saving...' : 'Save PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.6)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 3. Print and Share row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isPrinting
                      ? null
                      : () async {
                          final success = await notifier.printDocument();
                          if (context.mounted && !success && state.errorMessage != null) {
                            _showFeedback(context, state.errorMessage!, isError: true);
                          }
                        },
                  icon: state.isPrinting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.print_rounded, size: 18),
                  label: Text(state.isPrinting ? 'Printing...' : 'Print'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isSharing
                      ? null
                      : () async {
                          final success = await notifier.shareDocument();
                          if (context.mounted && !success && state.errorMessage != null) {
                            _showFeedback(context, state.errorMessage!, isError: true);
                          }
                        },
                  icon: state.isSharing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share_rounded, size: 18),
                  label: Text(state.isSharing ? 'Sharing...' : 'Share'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Horizontal action bar
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionIconButton(
          context,
          icon: Icons.picture_as_pdf_rounded,
          label: 'View PDF',
          isLoading: state.isGenerating,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PdfPreviewScreen(booking: booking)),
            );
          },
        ),
        _buildActionIconButton(
          context,
          icon: Icons.download_rounded,
          label: 'Save PDF',
          isLoading: state.isSaving,
          onTap: () async {
            final path = await notifier.saveDocument();
            if (context.mounted) {
              if (path != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Document saved to:\n$path'),
                    backgroundColor: AppColors.success,
                    action: SnackBarAction(
                      label: 'OPEN',
                      textColor: Colors.white,
                      onPressed: () {
                        ref.read(shareServiceProvider).openSavedFile(path);
                      },
                    ),
                  ),
                );
              } else {
                _showFeedback(context, state.errorMessage ?? 'Failed to save PDF.', isError: true);
              }
            }
          },
        ),
        _buildActionIconButton(
          context,
          icon: Icons.print_rounded,
          label: 'Print',
          isLoading: state.isPrinting,
          onTap: () async {
            final success = await notifier.printDocument();
            if (context.mounted && !success && state.errorMessage != null) {
              _showFeedback(context, state.errorMessage!, isError: true);
            }
          },
        ),
        _buildActionIconButton(
          context,
          icon: Icons.share_rounded,
          label: 'Share',
          isLoading: state.isSharing,
          onTap: () async {
            final success = await notifier.shareDocument();
            if (context.mounted && !success && state.errorMessage != null) {
              _showFeedback(context, state.errorMessage!, isError: true);
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionIconButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, size: 22, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
