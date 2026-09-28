import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/partner_entity.dart';
import '../controllers/partner_controller.dart';

class PartnerAddPropertyScreen extends ConsumerStatefulWidget {
  const PartnerAddPropertyScreen({super.key});

  @override
  ConsumerState<PartnerAddPropertyScreen> createState() => _PartnerAddPropertyScreenState();
}

class _PartnerAddPropertyScreenState extends ConsumerState<PartnerAddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController(text: '36.7538');
  final _lngController = TextEditingController(text: '3.0588');
  final _imageUrlController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
  );

  String _selectedCategory = 'Desert Camp';
  final List<String> _categories = ['Hotel', 'Apartment', 'Desert Camp', 'Luxury Villa', 'Tour Package'];
  final List<String> _selectedAmenities = ['WiFi', 'Free Breakfast', 'Air Conditioning'];
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final user = ref.read(currentPartnerUserProvider);
    final partnerId = user?.id ?? 'prt_001';

    final listing = PartnerListingEntity(
      id: 'lst_${DateTime.now().millisecondsSinceEpoch}',
      partnerId: partnerId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      mainImageUrl: _imageUrlController.text.trim(),
      pricePerNightUSD: double.tryParse(_priceController.text.trim()) ?? 100.0,
      latitude: double.tryParse(_latController.text.trim()) ?? 36.7538,
      longitude: double.tryParse(_lngController.text.trim()) ?? 3.0588,
      address: _addressController.text.trim(),
      amenities: _selectedAmenities,
      status: ListingStatus.pendingApproval, // Enforces Admin Review Workflow
      createdAt: DateTime.now(),
    );

    await ref.read(partnerRepositoryProvider).addListing(listing);
    ref.invalidate(partnerListingsProvider);
    ref.invalidate(adminPendingListingsProvider);

    if (mounted) {
      setState(() => _isSaving = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success),
              SizedBox(width: 8),
              Text('Submitted for Review!'),
            ],
          ),
          content: const Text(
            'Your property has been submitted and sent to the TRAVELGO Admin Approval Queue. Once approved by our team, it will immediately appear in the live Unified Search Aggregator.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isArabic ? 'إضافة عقار / رحلة سياحية' : 'Register New Property / Tour',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Basic Details Card
              CustomCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'البيانات الأساسية' : 'Property & Tour Details',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      controller: _titleController,
                      label: isArabic ? 'اسم الفندق أو المخيم أو الرحلة' : 'Property / Tour Title',
                      prefixIcon: const Icon(Icons.title_rounded),
                      validator: (v) => AppValidators.requiredField(v, 'Title'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'نوع مكان الإقامة / الرحلة' : 'Category',
                        prefixIcon: const Icon(Icons.category_rounded),
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      controller: _descController,
                      label: isArabic ? 'الوصف المميز' : 'Description & Experience',
                      maxLines: 3,
                      prefixIcon: const Icon(Icons.description_outlined),
                      validator: (v) => AppValidators.requiredField(v, 'Description'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      controller: _priceController,
                      label: isArabic ? 'السعر لليلة أو الفرد (USD)' : 'Price Per Night / Person (USD)',
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      keyboardType: TextInputType.number,
                      validator: (v) => AppValidators.requiredField(v, 'Price'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 2. Location & Map Coordinates
              CustomCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'الموقع والإحداثيات الجغرافية' : 'Location & Map Coordinates',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      controller: _addressController,
                      label: isArabic ? 'العنوان والمدينة' : 'Full Address & City',
                      prefixIcon: const Icon(Icons.location_city_rounded),
                      validator: (v) => AppValidators.requiredField(v, 'Address'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _latController,
                            label: 'Latitude (GPS)',
                            prefixIcon: const Icon(Icons.pin_drop_outlined),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: CustomTextField(
                            controller: _lngController,
                            label: 'Longitude (GPS)',
                            prefixIcon: const Icon(Icons.pin_drop_outlined),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 3. Photos & Image URL
              CustomCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'صور العقار / الرحلة' : 'High-Resolution Photos',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      controller: _imageUrlController,
                      label: 'Cover Image URL',
                      prefixIcon: const Icon(Icons.image_outlined),
                      validator: (v) => AppValidators.requiredField(v, 'Cover Image'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 4. Submit for Admin Review Button
              CustomButton(
                text: _isSaving
                    ? 'Submitting...'
                    : (isArabic ? 'إرسال للمراجعة والاعتماد' : 'Submit Listing for Admin Approval'),
                icon: Icons.send_rounded,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _submitProperty,
                type: ButtonType.gradient,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
