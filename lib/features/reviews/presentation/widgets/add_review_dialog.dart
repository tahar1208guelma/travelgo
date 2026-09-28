import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/review_entity.dart';

class AddReviewDialog extends StatefulWidget {
  final String propertyId;
  final void Function(ReviewEntity review) onSubmit;

  const AddReviewDialog({
    super.key,
    required this.propertyId,
    required this.onSubmit,
  });

  static Future<void> show(BuildContext context, {required String propertyId, required void Function(ReviewEntity) onSubmit}) {
    return showDialog(
      context: context,
      builder: (_) => AddReviewDialog(propertyId: propertyId, onSubmit: onSubmit),
    );
  }

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  double _rating = 5.0;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final review = ReviewEntity(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      propertyOrTripId: widget.propertyId,
      authorName: 'Verified Traveler',
      authorCountry: 'Traveler',
      rating: _rating,
      title: _titleController.text.trim(),
      comment: _commentController.text.trim(),
      date: DateTime.now(),
      isVerifiedStay: true,
    );

    widget.onSubmit(review);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      title: Row(
        children: [
          const Icon(Icons.rate_review_rounded, color: AppColors.secondary, size: 24),
          const SizedBox(width: 8),
          const Text('Write a Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rate your overall experience:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Interactive Star Rating Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      starVal <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.accentGold,
                      size: 32,
                    ),
                    onPressed: () => setState(() => _rating = starVal),
                  );
                }),
              ),
              Center(
                child: Text(
                  '$_rating / 5.0 - ${_getRatingLabel(_rating)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGold, fontSize: 13),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _titleController,
                label: 'Review Title (e.g. Wonderful Stay!)',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _commentController,
                label: 'Share details of your experience...',
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Publish Review'),
        ),
      ],
    );
  }

  String _getRatingLabel(double r) {
    if (r >= 4.8) return 'Exceptional';
    if (r >= 4.0) return 'Wonderful';
    if (r >= 3.0) return 'Good';
    return 'Fair';
  }
}
