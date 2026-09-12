import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// Service responsible for managing direct official redirects for Flights and Hotels,
/// implementing the TravelGo Meta-Search and Fare Comparison architecture.
class ProviderRedirectService {
  ProviderRedirectService._();

  // Registry of verified official airline booking portals
  static final Map<String, String> _airlineUrls = {
    'air algerie': 'https://airalgerie.dz',
    'air algérie': 'https://airalgerie.dz',
    'ah': 'https://airalgerie.dz',
    'air france': 'https://www.airfrance.com',
    'af': 'https://www.airfrance.com',
    'turkish airlines': 'https://www.turkishairlines.com',
    'tk': 'https://www.turkishairlines.com',
    'emirates': 'https://www.emirates.com',
    'ek': 'https://www.emirates.com',
    'qatar airways': 'https://www.qatarairways.com',
    'qr': 'https://www.qatarairways.com',
    'saudia': 'https://www.saudia.com',
    'saudi arabian airlines': 'https://www.saudia.com',
    'sv': 'https://www.saudia.com',
    'lufthansa': 'https://www.lufthansa.com',
    'lh': 'https://www.lufthansa.com',
    'transavia': 'https://www.transavia.com',
    'to': 'https://www.transavia.com',
    'hv': 'https://www.transavia.com',
    'british airways': 'https://www.ba.com',
    'ba': 'https://www.ba.com',
    'pegasus airlines': 'https://www.flypgs.com',
    'pegasus': 'https://www.flypgs.com',
    'pc': 'https://www.flypgs.com',
    'royal air maroc': 'https://www.royalairmaroc.com',
    'ram': 'https://www.royalairmaroc.com',
    'at': 'https://www.royalairmaroc.com',
    'tunisair': 'https://www.tunisair.com',
    'tu': 'https://www.tunisair.com',
    'ita airways': 'https://www.ita-airways.com',
    'az': 'https://www.ita-airways.com',
    'egyptair': 'https://www.egyptair.com',
    'ms': 'https://www.egyptair.com',
    'iberia': 'https://www.iberia.com',
    'ib': 'https://www.iberia.com',
    'vueling': 'https://www.vueling.com',
    'vy': 'https://www.vueling.com',
    'flydubai': 'https://www.flydubai.com',
    'fz': 'https://www.flydubai.com',
  };

  /// Resolves the verified official booking portal for an airline
  static String getAirlineOfficialUrl(String airlineNameOrCode) {
    final key = airlineNameOrCode.trim().toLowerCase();
    if (_airlineUrls.containsKey(key)) {
      return _airlineUrls[key]!;
    }
    // Check partial matches
    for (final entry in _airlineUrls.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    // Clean fallback to official portal query
    final encoded = Uri.encodeComponent('$airlineNameOrCode official airline booking');
    return 'https://www.google.com/search?q=$encoded';
  }

  /// Resolves the verified official booking portal for a hotel property
  static String getHotelOfficialUrl({required String hotelName, required String city, String? explicitUrl}) {
    if (explicitUrl != null && explicitUrl.trim().isNotEmpty && explicitUrl.startsWith('http')) {
      return explicitUrl.trim();
    }
    // High-profile hotel chain direct mappings
    final lowerName = hotelName.toLowerCase();
    if (lowerName.contains('marriott') || lowerName.contains('sheraton') || lowerName.contains('ritz-carlton') || lowerName.contains('westin') || lowerName.contains('le meridien')) {
      return 'https://www.marriott.com';
    }
    if (lowerName.contains('hilton') || lowerName.contains('waldorf') || lowerName.contains('doubletree')) {
      return 'https://www.hilton.com';
    }
    if (lowerName.contains('accor') || lowerName.contains('sofitel') || lowerName.contains('novotel') || lowerName.contains('ibis') || lowerName.contains('mercure') || lowerName.contains('pullman')) {
      return 'https://all.accor.com';
    }
    if (lowerName.contains('hyatt') || lowerName.contains('park hyatt') || lowerName.contains('grand hyatt')) {
      return 'https://www.hyatt.com';
    }
    if (lowerName.contains('aurassi')) {
      return 'https://el-aurassi.com';
    }
    if (lowerName.contains('algeria') || lowerName.contains('algiers') || lowerName.contains('oran') || lowerName.contains('constantine')) {
      return 'https://www.booking.com/searchresults.html?ss=${Uri.encodeComponent('$hotelName $city')}';
    }

    final query = Uri.encodeComponent('$hotelName $city official booking');
    return 'https://www.google.com/search?q=$query';
  }

  /// Opens the external official URL cleanly using url_launcher
  static Future<bool> launchOfficialUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  /// Displays the official carrier redirect confirmation dialog
  static Future<void> showFlightRedirectDialog({
    required BuildContext context,
    required String airlineName,
    required String flightNumber,
    required String routeSummary,
    required String priceText,
    String? officialUrl,
  }) async {
    final targetUrl = officialUrl ?? getAirlineOfficialUrl(airlineName);
    final domain = Uri.tryParse(targetUrl)?.host ?? targetUrl;

    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flight_takeoff, color: AppTheme.accentBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airlineName,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    const Text(
                      'الموقع الرسمي لشركة الطيران',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الرحلة / Flight:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        Text(flightNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المسار / Route:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        Text(routeSummary, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('أفضل سعر متوفر:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        Text(priceText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentBlue)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Trust & Meta-Search Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'حجز مباشر من شركة الطيران • 0% عمولة أو رسوم إضافية',
                        style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.language, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      domain,
                      style: const TextStyle(fontSize: 12, color: AppTheme.accentBlue, decoration: TextDecoration.underline),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'سيتم تحويلك مباشرة للموقع الرسمي للشركة لإتمام الحجز واختيار المقاعد بأمان.',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء / Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                launchOfficialUrl(targetUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('احجز من الموقع الرسمي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        );
      },
    );
  }

  /// Displays the official hotel redirect confirmation dialog
  static Future<void> showHotelRedirectDialog({
    required BuildContext context,
    required String hotelName,
    required String city,
    required String priceText,
    String? address,
    String? explicitUrl,
  }) async {
    final targetUrl = getHotelOfficialUrl(hotelName: hotelName, city: city, explicitUrl: explicitUrl);
    final domain = Uri.tryParse(targetUrl)?.host ?? targetUrl;

    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hotel, color: AppTheme.accentBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotelName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    Text(
                      city,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (address != null) ...[
                Text(address, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 10),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('السعر المعروض:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    Text(priceText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.accentBlue)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Trust badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'حجز مباشر وموثوق • بدون رسوم وسيط أو عمولات إضافية',
                        style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.language, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      domain,
                      style: const TextStyle(fontSize: 12, color: AppTheme.accentBlue, decoration: TextDecoration.underline),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'سيتم توجيهك إلى صفحة الحجز الرسمية للفندق لمطالعة الغرف المتاحة وتأكيد إقامتك بأفضل سعر.',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء / Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                launchOfficialUrl(targetUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('احجز من الفندق مباشرة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        );
      },
    );
  }
}
