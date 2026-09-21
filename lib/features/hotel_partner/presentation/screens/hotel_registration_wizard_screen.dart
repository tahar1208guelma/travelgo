import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../domain/entities/hotel_partner_entity.dart';
import '../controllers/hotel_partner_controller.dart';
import '../widgets/partner_room_editor_sheet.dart';

class HotelRegistrationWizardScreen extends ConsumerStatefulWidget {
  final PartnerHotelListing? editHotel;

  const HotelRegistrationWizardScreen({super.key, this.editHotel});

  @override
  ConsumerState<HotelRegistrationWizardScreen> createState() => _HotelRegistrationWizardScreenState();
}

class _HotelRegistrationWizardScreenState extends ConsumerState<HotelRegistrationWizardScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Form Keys
  final _step0FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  // Controllers - Step 0: Basic Info
  late TextEditingController _nameEnCtrl;
  late TextEditingController _nameArCtrl;
  late TextEditingController _cityEnCtrl;
  late TextEditingController _cityArCtrl;
  late TextEditingController _countryEnCtrl;
  late TextEditingController _countryArCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _taxesCtrl;
  int _starRating = 5;

  // Step 1: Amenities
  final Set<String> _selectedAmenities = {};

  // Step 2: Rooms
  final List<PartnerRoomType> _rooms = [];

  // Step 3: Photos
  late TextEditingController _coverUrlCtrl;
  final List<String> _galleryPhotos = [];

  // Step 4: Policies & Description
  late TextEditingController _descEnCtrl;
  late TextEditingController _descArCtrl;
  late TextEditingController _checkInCtrl;
  late TextEditingController _checkOutCtrl;
  late TextEditingController _cancellationEnCtrl;
  late TextEditingController _cancellationArCtrl;

  // Curated Preset Hotel Images
  final List<String> _presetCovers = [
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?q=80&w=1000&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.editHotel;

    _nameEnCtrl = TextEditingController(text: h?.nameEn ?? '');
    _nameArCtrl = TextEditingController(text: h?.nameAr ?? '');
    _cityEnCtrl = TextEditingController(text: h?.cityEn ?? 'Algiers');
    _cityArCtrl = TextEditingController(text: h?.cityAr ?? 'الجزائر العاصمة');
    _countryEnCtrl = TextEditingController(text: h?.countryEn ?? 'Algeria');
    _countryArCtrl = TextEditingController(text: h?.countryAr ?? 'الجزائر');
    _addressCtrl = TextEditingController(text: h?.address ?? 'Center District');
    _priceCtrl = TextEditingController(text: h != null ? h.pricePerNightUSD.toStringAsFixed(0) : '150');
    _taxesCtrl = TextEditingController(text: h != null ? h.taxesPerNightUSD.toStringAsFixed(0) : '10');
    _starRating = h?.starRating ?? 5;

    if (h != null) {
      _selectedAmenities.addAll(h.amenities);
      _rooms.addAll(h.rooms);
      _galleryPhotos.addAll(h.galleryImages);
    } else {
      _selectedAmenities.addAll(['wifi', 'pool', 'breakfast', 'parking', 'ac']);
      _rooms.add(
        const PartnerRoomType(
          id: 'rm_init_1',
          hotelId: '',
          nameEn: 'Deluxe Room',
          nameAr: 'غرفة ديلوكس فاخرة',
          pricePerNightUSD: 150.0,
          maxGuests: 2,
          bedType: '1 King Bed',
          breakfastIncluded: true,
          freeCancellation: true,
          totalUnits: 5,
          availableUnits: 5,
          perks: ['City View', 'Free WiFi'],
        ),
      );
    }

    _coverUrlCtrl = TextEditingController(
      text: h?.mainCoverImageUrl ?? _presetCovers.first,
    );

    _descEnCtrl = TextEditingController(
      text: h?.descriptionEn ?? 'Experience luxury accommodation with direct booking guarantee, world-class amenities, and personalized hospitality.',
    );
    _descArCtrl = TextEditingController(
      text: h?.descriptionAr ?? 'استمتع بإقامة فاخرة مع ضمان الحجز المباشر، وأرقى الخدمات الفندقية مع إطلالات ساحرة.',
    );
    _checkInCtrl = TextEditingController(text: h?.checkInTime ?? '14:00');
    _checkOutCtrl = TextEditingController(text: h?.checkOutTime ?? '12:00');
    _cancellationEnCtrl = TextEditingController(
      text: h?.cancellationPolicyEn ?? 'Free cancellation up to 24h prior to check-in.',
    );
    _cancellationArCtrl = TextEditingController(
      text: h?.cancellationPolicyAr ?? 'إلغاء مجاني حتى 24 ساعة قبل موعد الوصول.',
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameEnCtrl.dispose();
    _nameArCtrl.dispose();
    _cityEnCtrl.dispose();
    _cityArCtrl.dispose();
    _countryEnCtrl.dispose();
    _countryArCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
    _taxesCtrl.dispose();
    _coverUrlCtrl.dispose();
    _descEnCtrl.dispose();
    _descArCtrl.dispose();
    _checkInCtrl.dispose();
    _checkOutCtrl.dispose();
    _cancellationEnCtrl.dispose();
    _cancellationArCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_step0FormKey.currentState!.validate()) return;
    }
    if (_currentStep == 2 && _rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('partner.add_at_least_one_room')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _publishHotel();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _publishHotel() async {
    if (!_step4FormKey.currentState!.validate()) return;

    final hotelId = widget.editHotel?.id ?? 'partner_ht_${DateTime.now().millisecondsSinceEpoch}';
    final price = double.tryParse(_priceCtrl.text) ?? 120.0;
    final taxes = double.tryParse(_taxesCtrl.text) ?? 10.0;

    final updatedRooms = _rooms.map((r) => PartnerRoomType(
      id: r.id,
      hotelId: hotelId,
      nameEn: r.nameEn,
      nameAr: r.nameAr,
      pricePerNightUSD: r.pricePerNightUSD,
      maxGuests: r.maxGuests,
      bedType: r.bedType,
      breakfastIncluded: r.breakfastIncluded,
      freeCancellation: r.freeCancellation,
      totalUnits: r.totalUnits,
      availableUnits: r.availableUnits,
      perks: r.perks,
      photos: r.photos,
    )).toList();

    final listing = PartnerHotelListing(
      id: hotelId,
      ownerPartnerId: widget.editHotel?.ownerPartnerId ?? 'host_braknia_001',
      nameEn: _nameEnCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim().isNotEmpty ? _nameArCtrl.text.trim() : _nameEnCtrl.text.trim(),
      cityEn: _cityEnCtrl.text.trim(),
      cityAr: _cityArCtrl.text.trim().isNotEmpty ? _cityArCtrl.text.trim() : _cityEnCtrl.text.trim(),
      countryEn: _countryEnCtrl.text.trim(),
      countryAr: _countryArCtrl.text.trim().isNotEmpty ? _countryArCtrl.text.trim() : _countryEnCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      starRating: _starRating,
      userRating: widget.editHotel?.userRating ?? 9.5,
      reviewCount: widget.editHotel?.reviewCount ?? 1,
      distanceToCenter: widget.editHotel?.distanceToCenter ?? '0.5 km from center',
      pricePerNightUSD: price,
      taxesPerNightUSD: taxes,
      mainCoverImageUrl: _coverUrlCtrl.text.trim(),
      galleryImages: _galleryPhotos.isNotEmpty ? _galleryPhotos : [_coverUrlCtrl.text.trim()],
      amenities: _selectedAmenities.toList(),
      descriptionEn: _descEnCtrl.text.trim(),
      descriptionAr: _descArCtrl.text.trim(),
      checkInTime: _checkInCtrl.text.trim(),
      checkOutTime: _checkOutCtrl.text.trim(),
      cancellationPolicyEn: _cancellationEnCtrl.text.trim(),
      cancellationPolicyAr: _cancellationArCtrl.text.trim(),
      latitude: widget.editHotel?.latitude ?? 36.7538,
      longitude: widget.editHotel?.longitude ?? 3.0588,
      rooms: updatedRooms,
      status: PartnerListingStatus.active,
      createdAt: widget.editHotel?.createdAt ?? DateTime.now(),
    );

    final success = await ref.read(hotelPartnerControllerProvider.notifier).saveHotelListing(listing);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(context.tr('partner.hotel_published_success')),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  void _openRoomEditor([PartnerRoomType? room]) {
    final hotelId = widget.editHotel?.id ?? 'temp_hotel';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PartnerRoomEditorSheet(
        initialRoom: room,
        hotelId: hotelId,
        onSave: (savedRoom) {
          setState(() {
            final index = _rooms.indexWhere((r) => r.id == savedRoom.id);
            if (index >= 0) {
              _rooms[index] = savedRoom;
            } else {
              _rooms.add(savedRoom);
            }
          });
        },
      ),
    );
  }

  IconData _getAmenityIcon(String iconName) {
    switch (iconName) {
      case 'wifi': return Icons.wifi;
      case 'pool': return Icons.pool;
      case 'restaurant': return Icons.restaurant;
      case 'local_parking': return Icons.local_parking;
      case 'fitness_center': return Icons.fitness_center;
      case 'spa': return Icons.spa;
      case 'waves': return Icons.waves;
      case 'airport_shuttle': return Icons.airport_shuttle;
      case 'restaurant_menu': return Icons.restaurant_menu;
      case 'ac_unit': return Icons.ac_unit;
      case 'room_service': return Icons.room_service;
      case 'beach_access': return Icons.beach_access;
      case 'business_center': return Icons.business_center;
      case 'child_care': return Icons.child_care;
      case 'pets': return Icons.pets;
      case 'ev_station': return Icons.ev_station;
      default: return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(languageProvider.notifier).isArabic;
    final state = ref.watch(hotelPartnerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editHotel != null ? context.tr('partner.edit_hotel') : context.tr('partner.register_hotel_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentStep + 1) / 5.0,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${context.tr('partner.step')} ${_currentStep + 1} / 5',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                    ),
                    Text(
                      _getStepTitle(_currentStep),
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep0BasicInfo(),
          _buildStep1Amenities(isArabic),
          _buildStep2Rooms(),
          _buildStep3Photos(),
          _buildStep4PoliciesAndPublish(isArabic),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, -3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isSaving ? null : _prevStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(context.tr('back')),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: state.isSaving ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStep == 4 ? AppColors.success : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: state.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 4 ? context.tr('partner.publish_hotel_btn') : context.tr('next'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentStep == 4 ? Icons.rocket_launch_rounded : (isArabic ? Icons.arrow_back : Icons.arrow_forward),
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return context.tr('partner.step_basic_info');
      case 1: return context.tr('partner.step_amenities');
      case 2: return context.tr('partner.step_rooms');
      case 3: return context.tr('partner.step_photos');
      case 4: return context.tr('partner.step_publish');
      default: return '';
    }
  }

  // Step 0: Basic Property Info
  Widget _buildStep0BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _step0FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context.tr('partner.property_details'), Icons.apartment_rounded),
            const SizedBox(height: 16),

            // Name English
            TextFormField(
              controller: _nameEnCtrl,
              decoration: InputDecoration(
                labelText: '${context.tr('partner.hotel_name')} (English)',
                hintText: 'e.g. Royal Mediterranean Palace',
                prefixIcon: const Icon(Icons.hotel),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            // Name Arabic
            TextFormField(
              controller: _nameArCtrl,
              decoration: InputDecoration(
                labelText: '${context.tr('partner.hotel_name')} (العربية)',
                hintText: 'مثال: قصر البحر المتوسط الملكي',
                prefixIcon: const Icon(Icons.translate),
              ),
            ),
            const SizedBox(height: 14),

            // City Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityEnCtrl,
                    decoration: InputDecoration(
                      labelText: '${context.tr('partner.city')} (EN)',
                      hintText: 'Algiers',
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cityArCtrl,
                    decoration: InputDecoration(
                      labelText: '${context.tr('partner.city')} (AR)',
                      hintText: 'الجزائر',
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Country & Address
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _countryEnCtrl,
                    decoration: InputDecoration(
                      labelText: '${context.tr('partner.country')} (EN)',
                      hintText: 'Algeria',
                      prefixIcon: const Icon(Icons.public),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _countryArCtrl,
                    decoration: InputDecoration(
                      labelText: '${context.tr('partner.country')} (AR)',
                      hintText: 'الجزائر',
                      prefixIcon: const Icon(Icons.public),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                labelText: context.tr('partner.address'),
                hintText: 'e.g. 15 Waterfront Boulevard',
                prefixIcon: const Icon(Icons.pin_drop_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Star Rating Selector (1 to 5 Stars)
            Text(context.tr('partner.star_rating'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final starVal = index + 1;
                final isSelected = starVal <= _starRating;
                return IconButton(
                  icon: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isSelected ? Colors.amber : Colors.grey.shade400,
                    size: 34,
                  ),
                  onPressed: () => setState(() => _starRating = starVal),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Base Price & Nightly Taxes
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: '${context.tr('partner.base_price_night')} (\$ USD)',
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _taxesCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: '${context.tr('partner.taxes_night')} (\$ USD)',
                      prefixIcon: const Icon(Icons.receipt_long_outlined),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: 16+ Amenities Selection Grid
  Widget _buildStep1Amenities(bool isArabic) {
    final catalog = PartnerAmenity.defaultCatalog;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context.tr('partner.select_amenities_desc'), Icons.checklist_rounded),
          const SizedBox(height: 8),
          Text(
            context.tr('partner.amenities_subtext'),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Grid of amenities
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemCount: catalog.length,
            itemBuilder: (ctx, idx) {
              final item = catalog[idx];
              final isSelected = _selectedAmenities.contains(item.id);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAmenities.remove(item.id);
                    } else {
                      _selectedAmenities.add(item.id);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryContainer : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getAmenityIcon(item.iconName),
                        color: isSelected ? AppColors.primary : Colors.grey.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.getName(isArabic: isArabic),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primaryDark : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Step 2: Room Types & Inventory
  Widget _buildStep2Rooms() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(context.tr('partner.rooms_inventory'), Icons.meeting_room_outlined),
              ElevatedButton.icon(
                onPressed: () => _openRoomEditor(),
                icon: const Icon(Icons.add, size: 18),
                label: Text(context.tr('partner.add_room')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_rooms.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.bedroom_parent_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('partner.no_rooms_yet'),
                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('partner.no_rooms_desc'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final room = _rooms[idx];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.king_bed_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.nameEn,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${room.bedType} • Max ${room.maxGuests} Guests • ${room.totalUnits} Units',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${room.pricePerNightUSD.toStringAsFixed(0)} / night',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                        onPressed: () => _openRoomEditor(room),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        onPressed: () {
                          setState(() => _rooms.removeAt(idx));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Step 3: Photo Gallery Manager
  Widget _buildStep3Photos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context.tr('partner.photos_gallery'), Icons.photo_library_outlined),
          const SizedBox(height: 8),
          Text(context.tr('partner.photos_desc'), style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),

          // Main Cover Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.network(
                  _coverUrlCtrl.text.trim(),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🌟 Main Cover Photo',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cover URL input
          TextFormField(
            controller: _coverUrlCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: context.tr('partner.cover_photo_url'),
              prefixIcon: const Icon(Icons.link),
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Preset Image Palette
          Text(context.tr('partner.quick_preset_photos'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presetCovers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, idx) {
                final url = _presetCovers[idx];
                final isSelected = _coverUrlCtrl.text == url;
                return InkWell(
                  onTap: () => setState(() => _coverUrlCtrl.text = url),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Step 4: Policies, Descriptions & Final Summary
  Widget _buildStep4PoliciesAndPublish(bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _step4FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context.tr('partner.policies_and_desc'), Icons.policy_outlined),
            const SizedBox(height: 16),

            // Check In / Check Out Times
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _checkInCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr('hotel_check_in'),
                      hintText: '14:00',
                      prefixIcon: const Icon(Icons.login),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _checkOutCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr('hotel_check_out'),
                      hintText: '12:00',
                      prefixIcon: const Icon(Icons.logout),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Cancellation Policy English
            TextFormField(
              controller: _cancellationEnCtrl,
              decoration: InputDecoration(
                labelText: '${context.tr('partner.cancellation_policy')} (EN)',
                prefixIcon: const Icon(Icons.cancel_outlined),
              ),
            ),
            const SizedBox(height: 14),

            // Description English
            TextFormField(
              controller: _descEnCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: '${context.tr('partner.property_description')} (EN)',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            // Description Arabic
            TextFormField(
              controller: _descArCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: '${context.tr('partner.property_description')} (العربية)',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.translate),
              ),
            ),
            const SizedBox(height: 20),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('partner.instant_direct_booking_enabled'),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('partner.publish_guarantee_notice'),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.tr('partner.total_rooms_configured'), style: const TextStyle(fontSize: 13)),
                      Text('${_rooms.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.tr('partner.active_amenities_count'), style: const TextStyle(fontSize: 13)),
                      Text('${_selectedAmenities.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
