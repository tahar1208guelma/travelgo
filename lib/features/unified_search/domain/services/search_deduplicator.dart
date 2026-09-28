import '../entities/unified_search_result_entity.dart';

class SearchDeduplicator {
  /// Deduplicates items across multiple sources based on normalized name and GPS proximity (< 250 meters)
  static List<UnifiedSearchResultEntity> deduplicate(List<UnifiedSearchResultEntity> items) {
    final List<UnifiedSearchResultEntity> uniqueResults = [];

    for (final candidate in items) {
      final normalizedCandidateName = _normalizeTitle(candidate.title);

      int duplicateIndex = -1;
      for (int i = 0; i < uniqueResults.length; i++) {
        final existing = uniqueResults[i];
        final normalizedExistingName = _normalizeTitle(existing.title);

        // Check 1: Exact or substring name match
        final bool nameMatch = normalizedCandidateName == normalizedExistingName ||
            normalizedCandidateName.contains(normalizedExistingName) ||
            normalizedExistingName.contains(normalizedCandidateName);

        // Check 2: GPS coordinate proximity within 250 meters
        final double distanceMeters = candidate.coordinates.distanceTo(existing.coordinates);
        final bool locationMatch = distanceMeters <= 250.0;

        if (nameMatch && (locationMatch || candidate.coordinates.latitude == 0)) {
          duplicateIndex = i;
          break;
        }
      }

      if (duplicateIndex != -1) {
        // Resolve duplicate: Choose local/partner direct over affiliate, or cheaper price
        final existing = uniqueResults[duplicateIndex];
        final winner = _pickBestDuplicate(existing, candidate);
        uniqueResults[duplicateIndex] = winner;
      } else {
        uniqueResults.add(candidate);
      }
    }

    return uniqueResults;
  }

  static String _normalizeTitle(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'\b(hotel|resort|spa|suites|apartments|camp|palace|grand|the|and|&)\b'), '')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static UnifiedSearchResultEntity _pickBestDuplicate(
    UnifiedSearchResultEntity a,
    UnifiedSearchResultEntity b,
  ) {
    // Priority 1: Partner verified direct
    if (a.isPartnerVerified && !b.isPartnerVerified) return a;
    if (b.isPartnerVerified && !a.isPartnerVerified) return b;

    // Priority 2: Direct local database
    if (a.source == 'local_database' && b.source != 'local_database') return a;
    if (b.source == 'local_database' && a.source != 'local_database') return b;

    // Priority 3: Lowest price for traveler
    if (a.price < b.price) return a;
    return b;
  }
}
