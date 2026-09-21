import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/hotel_partner_entity.dart';

class PartnerRoomEditorSheet extends StatefulWidget {
  final PartnerRoomType? initialRoom;
  final String hotelId;
  final Function(PartnerRoomType) onSave;

  const PartnerRoomEditorSheet({
    super.key,
    this.initialRoom,
    required this.hotelId,
    required this.onSave,
  });

  @override
  State<PartnerRoomEditorSheet> createState() => _PartnerRoomEditorSheetState();
}

class _PartnerRoomEditorSheetState extends State<PartnerRoomEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameEnCtrl;
  late TextEditingController _nameArCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _bedTypeCtrl;
  late TextEditingController _perksCtrl;

  int _maxGuests = 2;
  int _totalUnits = 5;
  bool _breakfastIncluded = true;
  bool _freeCancellation = true;

  @override
  void initState() {
    super.initState();
    final r = widget.initialRoom;
    _nameEnCtrl = TextEditingController(text: r?.nameEn ?? '');
    _nameArCtrl = TextEditingController(text: r?.nameAr ?? '');
    _priceCtrl = TextEditingController(text: r != null ? r.pricePerNightUSD.toStringAsFixed(0) : '120');
    _bedTypeCtrl = TextEditingController(text: r?.bedType ?? '1 King Bed');
    _perksCtrl = TextEditingController(text: r?.perks.join(', ') ?? 'City View, Free WiFi, Balcony');
    _maxGuests = r?.maxGuests ?? 2;
    _totalUnits = r?.totalUnits ?? 5;
    _breakfastIncluded = r?.breakfastIncluded ?? true;
    _freeCancellation = r?.freeCancellation ?? true;
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameArCtrl.dispose();
    _priceCtrl.dispose();
    _bedTypeCtrl.dispose();
    _perksCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final perks = _perksCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final room = PartnerRoomType(
      id: widget.initialRoom?.id ?? 'rm_${DateTime.now().millisecondsSinceEpoch}',
      hotelId: widget.hotelId,
      nameEn: _nameEnCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim().isNotEmpty ? _nameArCtrl.text.trim() : _nameEnCtrl.text.trim(),
      pricePerNightUSD: double.tryParse(_priceCtrl.text) ?? 100.0,
      maxGuests: _maxGuests,
      bedType: _bedTypeCtrl.text.trim(),
      breakfastIncluded: _breakfastIncluded,
      freeCancellation: _freeCancellation,
      totalUnits: _totalUnits,
      availableUnits: _totalUnits,
      perks: perks,
      photos: widget.initialRoom?.photos ?? const [],
    );

    widget.onSave(room);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialRoom != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.hotel_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? context.tr('partner.edit_room') : context.tr('partner.add_room'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Room Name English
              TextFormField(
                controller: _nameEnCtrl,
                decoration: InputDecoration(
                  labelText: '${context.tr('partner.room_name')} (English)',
                  hintText: 'e.g. Deluxe Sea View Suite',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Room Name Arabic
              TextFormField(
                controller: _nameArCtrl,
                decoration: InputDecoration(
                  labelText: '${context.tr('partner.room_name')} (العربية)',
                  hintText: 'مثال: جناح ديلوكس بإطلالة بحرية',
                  prefixIcon: const Icon(Icons.translate),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Price & Bed Type in Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: '${context.tr('partner.price_per_night')} (\$ USD)',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) {
                        if (val == null || double.tryParse(val) == null) return 'Invalid price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bedTypeCtrl,
                      decoration: InputDecoration(
                        labelText: context.tr('partner.bed_type'),
                        hintText: '1 King Bed',
                        prefixIcon: const Icon(Icons.bed_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Guests & Total Inventory Counter
              Row(
                children: [
                  // Max Guests
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('partner.max_guests'), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                                onPressed: _maxGuests > 1 ? () => setState(() => _maxGuests--) : null,
                              ),
                              Text('$_maxGuests', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                onPressed: _maxGuests < 10 ? () => setState(() => _maxGuests++) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Total Units
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('partner.total_units'), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                                onPressed: _totalUnits > 1 ? () => setState(() => _totalUnits--) : null,
                              ),
                              Text('$_totalUnits', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                onPressed: _totalUnits < 50 ? () => setState(() => _totalUnits++) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Perks / Features text input
              TextFormField(
                controller: _perksCtrl,
                decoration: InputDecoration(
                  labelText: context.tr('partner.perks_label'),
                  hintText: 'Comma separated, e.g. Jacuzzi, City View, Balcony',
                  prefixIcon: const Icon(Icons.star_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Switches: Breakfast & Cancellation
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text(context.tr('hotels.amenities.breakfast'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(context.tr('partner.free_breakfast_desc'), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                value: _breakfastIncluded,
                onChanged: (val) => setState(() => _breakfastIncluded = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text(context.tr('hotels.amenities.free_cancellation'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(context.tr('partner.free_cancellation_desc'), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                value: _freeCancellation,
                onChanged: (val) => setState(() => _freeCancellation = val),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _submit,
                  child: Text(
                    isEditing ? context.tr('common.save') : context.tr('partner.save_room'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
