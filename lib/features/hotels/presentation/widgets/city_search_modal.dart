import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/cities_data.dart';

class CitySearchModal extends StatefulWidget {
  final String title;
  final String? initialCity;
  final ValueChanged<CityDestinationInfo> onSelected;

  const CitySearchModal({
    super.key,
    required this.title,
    this.initialCity,
    required this.onSelected,
  });

  static Future<CityDestinationInfo?> show(
    BuildContext context, {
    required String title,
    String? initialCity,
  }) {
    return showModalBottomSheet<CityDestinationInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CitySearchModal(
        title: title,
        initialCity: initialCity,
        onSelected: (city) => Navigator.of(ctx).pop(city),
      ),
    );
  }

  @override
  State<CitySearchModal> createState() => _CitySearchModalState();
}

class _CitySearchModalState extends State<CitySearchModal> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'All';
  List<CityDestinationInfo> _filteredCities = CitiesData.globalCities;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.trim();
    setState(() {
      _filteredCities = CitiesData.globalCities.where((city) {
        final matchesQuery = city.matches(query);
        final matchesRegion = _selectedRegion == 'All' ||
            (_selectedRegion == 'Popular' && city.isPopular) ||
            city.region.contains(_selectedRegion);
        return matchesQuery && matchesRegion;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search city or landmark (e.g. Istanbul, Paris, Taksim...)',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppTheme.accentBlue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.slateBackground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildRegionChip('All'),
                const SizedBox(width: 8),
                _buildRegionChip('Popular'),
                const SizedBox(width: 8),
                _buildRegionChip('MENA'),
                const SizedBox(width: 8),
                _buildRegionChip('Europe'),
                const SizedBox(width: 8),
                _buildRegionChip('Americas'),
                const SizedBox(width: 8),
                _buildRegionChip('Asia'),
              ],
            ),
          ),
          const Divider(height: 16, color: AppTheme.cardBorder),

          // Cities List
          Expanded(
            child: _filteredCities.isNotEmpty
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filteredCities.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.cardBorder),
                    itemBuilder: (context, index) {
                      final city = _filteredCities[index];
                      final isSelected = widget.initialCity == city.city;

                      return ListTile(
                        onTap: () => widget.onSelected(city),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accentBlue
                                : AppTheme.accentBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_city,
                            color: isSelected ? Colors.white : AppTheme.accentBlue,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              city.city,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${city.country}',
                              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${city.propertyCount}+ Hotels • Landmarks: ${city.popularLandmark}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppTheme.accentBlue)
                            : const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.hotel, size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No listed city found for "${_searchController.text}".',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              final customCity = CityDestinationInfo(
                                city: _searchController.text.trim(),
                                country: 'Custom Destination',
                                region: 'Global',
                                propertyCount: 100,
                                popularLandmark: 'City Center',
                              );
                              widget.onSelected(customCity);
                            },
                            child: Text('Search Hotels in "${_searchController.text}"'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildRegionChip(String region) {
    final isSelected = _selectedRegion == region;
    return FilterChip(
      label: Text(region),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedRegion = region;
          _applyFilter();
        });
      },
      selectedColor: AppTheme.accentBlue.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppTheme.accentBlue : AppTheme.textDark,
      ),
    );
  }
}
