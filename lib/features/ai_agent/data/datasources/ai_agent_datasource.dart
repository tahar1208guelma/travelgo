import 'package:uuid/uuid.dart';
import '../../domain/entities/ai_budget_breakdown.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_trip_plan_entity.dart';
import '../../../flights/data/repositories/flight_repository_impl.dart';
import '../../../flights/domain/entities/flight_entity.dart';
import '../../../flights/domain/entities/flight_search_params.dart';
import '../../../hotels/data/repositories/hotel_repository_impl.dart';
import '../../../hotels/domain/entities/hotel_entity.dart';
import '../../../hotels/domain/entities/hotel_search_params.dart';

abstract class AIAgentDataSource {
  Future<AIMessageEntity> processUserQuery({
    required String query,
    required List<AIMessageEntity> history,
    bool isArabic = false,
  });

  Future<AITripPlanEntity> generateTripPlan({
    required String destination,
    required String origin,
    required int days,
    required double budgetUSD,
    bool isArabic = false,
  });

  AIBudgetBreakdown calculateBudgetOptimization({
    required double totalBudgetUSD,
    required int durationDays,
    required int travelers,
  });
}

class AIAgentDataSourceImpl implements AIAgentDataSource {
  final FlightRepositoryImpl _flightRepository;
  final HotelRepositoryImpl _hotelRepository;
  final _uuid = const Uuid();

  AIAgentDataSourceImpl(this._flightRepository, this._hotelRepository);

  @override
  AIBudgetBreakdown calculateBudgetOptimization({
    required double totalBudgetUSD,
    required int durationDays,
    required int travelers,
  }) {
    // 40% Flights, 45% Accommodation, 10% Activities & Dining, 5% Safety Buffer
    final flightBudget = totalBudgetUSD * 0.40;
    final hotelBudget = totalBudgetUSD * 0.45;
    final activitiesBudget = totalBudgetUSD * 0.10;
    final buffer = totalBudgetUSD * 0.05;

    return AIBudgetBreakdown(
      totalBudgetUSD: totalBudgetUSD,
      flightBudgetUSD: flightBudget,
      hotelBudgetUSD: hotelBudget,
      activitiesBudgetUSD: activitiesBudget,
      bufferUSD: buffer,
      durationDays: durationDays,
      travelers: travelers,
    );
  }

  static const Map<String, Map<String, String>> _destInfo = {
    'paris': {'nameEn': 'Paris', 'nameAr': 'باريس', 'code': 'CDG'},
    'باريس': {'nameEn': 'Paris', 'nameAr': 'باريس', 'code': 'CDG'},
    'istanbul': {'nameEn': 'Istanbul', 'nameAr': 'إسطنبول', 'code': 'IST'},
    'إسطنبول': {'nameEn': 'Istanbul', 'nameAr': 'إسطنبول', 'code': 'IST'},
    'اسطنبول': {'nameEn': 'Istanbul', 'nameAr': 'إسطنبول', 'code': 'IST'},
    'dubai': {'nameEn': 'Dubai', 'nameAr': 'دبي', 'code': 'DXB'},
    'دبي': {'nameEn': 'Dubai', 'nameAr': 'دبي', 'code': 'DXB'},
    'antalya': {'nameEn': 'Antalya', 'nameAr': 'أنطاليا', 'code': 'AYT'},
    'أنطاليا': {'nameEn': 'Antalya', 'nameAr': 'أنطاليا', 'code': 'AYT'},
    'انطاليا': {'nameEn': 'Antalya', 'nameAr': 'أنطاليا', 'code': 'AYT'},
    'riyadh': {'nameEn': 'Riyadh', 'nameAr': 'الرياض', 'code': 'RUH'},
    'الرياض': {'nameEn': 'Riyadh', 'nameAr': 'الرياض', 'code': 'RUH'},
    'jeddah': {'nameEn': 'Jeddah', 'nameAr': 'جدة', 'code': 'JED'},
    'جدة': {'nameEn': 'Jeddah', 'nameAr': 'جدة', 'code': 'JED'},
    'madinah': {'nameEn': 'Madinah', 'nameAr': 'المدينة المنورة', 'code': 'MED'},
    'المدينة': {'nameEn': 'Madinah', 'nameAr': 'المدينة المنورة', 'code': 'MED'},
    'london': {'nameEn': 'London', 'nameAr': 'لندن', 'code': 'LHR'},
    'لندن': {'nameEn': 'London', 'nameAr': 'لندن', 'code': 'LHR'},
    'cairo': {'nameEn': 'Cairo', 'nameAr': 'القاهرة', 'code': 'CAI'},
    'القاهرة': {'nameEn': 'Cairo', 'nameAr': 'القاهرة', 'code': 'CAI'},
    'sharm': {'nameEn': 'Sharm El Sheikh', 'nameAr': 'شرم الشيخ', 'code': 'SSH'},
    'شرم الشيخ': {'nameEn': 'Sharm El Sheikh', 'nameAr': 'شرم الشيخ', 'code': 'SSH'},
    'algiers': {'nameEn': 'Algiers', 'nameAr': 'الجزائر العاصمة', 'code': 'ALG'},
    'الجزائر': {'nameEn': 'Algiers', 'nameAr': 'الجزائر العاصمة', 'code': 'ALG'},
    'oran': {'nameEn': 'Oran', 'nameAr': 'وهران', 'code': 'ORN'},
    'وهران': {'nameEn': 'Oran', 'nameAr': 'وهران', 'code': 'ORN'},
    'tunis': {'nameEn': 'Tunis', 'nameAr': 'تونس', 'code': 'TUN'},
    'تونس': {'nameEn': 'Tunis', 'nameAr': 'تونس', 'code': 'TUN'},
    'casablanca': {'nameEn': 'Casablanca', 'nameAr': 'الدار البيضاء', 'code': 'CMN'},
    'الدار البيضاء': {'nameEn': 'Casablanca', 'nameAr': 'الدار البيضاء', 'code': 'CMN'},
    'rome': {'nameEn': 'Rome', 'nameAr': 'روما', 'code': 'FCO'},
    'روما': {'nameEn': 'Rome', 'nameAr': 'روما', 'code': 'FCO'},
    'milan': {'nameEn': 'Milan', 'nameAr': 'ميلانو', 'code': 'MXP'},
    'ميلانو': {'nameEn': 'Milan', 'nameAr': 'ميلانو', 'code': 'MXP'},
    'madrid': {'nameEn': 'Madrid', 'nameAr': 'مدريد', 'code': 'MAD'},
    'مدريد': {'nameEn': 'Madrid', 'nameAr': 'مدريد', 'code': 'MAD'},
    'barcelona': {'nameEn': 'Barcelona', 'nameAr': 'برشلونة', 'code': 'BCN'},
    'برشلونة': {'nameEn': 'Barcelona', 'nameAr': 'برشلونة', 'code': 'BCN'},
    'kuala lumpur': {'nameEn': 'Kuala Lumpur', 'nameAr': 'كوالالمبور', 'code': 'KUL'},
    'كوالالمبور': {'nameEn': 'Kuala Lumpur', 'nameAr': 'كوالالمبور', 'code': 'KUL'},
    'bangkok': {'nameEn': 'Bangkok', 'nameAr': 'بانكوك', 'code': 'BKK'},
    'بانكوك': {'nameEn': 'Bangkok', 'nameAr': 'بانكوك', 'code': 'BKK'},
    'bali': {'nameEn': 'Bali', 'nameAr': 'بالي', 'code': 'DPS'},
    'بالي': {'nameEn': 'Bali', 'nameAr': 'بالي', 'code': 'DPS'},
    'maldives': {'nameEn': 'Maldives', 'nameAr': 'المالديف', 'code': 'MLE'},
    'المالديف': {'nameEn': 'Maldives', 'nameAr': 'المالديف', 'code': 'MLE'},
    'tokyo': {'nameEn': 'Tokyo', 'nameAr': 'طوكيو', 'code': 'HND'},
    'طوكيو': {'nameEn': 'Tokyo', 'nameAr': 'طوكيو', 'code': 'HND'},
    'doha': {'nameEn': 'Doha', 'nameAr': 'الدوحة', 'code': 'DOH'},
    'الدوحة': {'nameEn': 'Doha', 'nameAr': 'الدوحة', 'code': 'DOH'},
  };

  @override
  Future<AIMessageEntity> processUserQuery({
    required String query,
    required List<AIMessageEntity> history,
    bool isArabic = false,
  }) async {
    // Simulate non-blocking natural thinking latency
    await Future.delayed(const Duration(milliseconds: 600));

    final normalized = query.toLowerCase().trim();

    // 1. Detect Destination
    String destinationCity = 'Dubai';
    String destAirportCode = 'DXB';
    String destCityAr = 'دبي';
    bool destMatched = false;

    for (final entry in _destInfo.entries) {
      if (normalized.contains(entry.key)) {
        destinationCity = entry.value['nameEn']!;
        destCityAr = entry.value['nameAr']!;
        destAirportCode = entry.value['code']!;
        destMatched = true;
        break;
      }
    }

    final displayDest = isArabic ? destCityAr : destinationCity;

    // 2. Handle FAQs / Broad questions
    if (normalized.contains('أفضل وقت') || normalized.contains('best time')) {
      final reply = isArabic
          ? '🌟 **أفضل وقت لزيارة $displayDest:**\n\n'
              'الفترة المثالية تمتد من **أكتوبر إلى أبريل** حيث تكون درجات الحرارة معتدلة ومناسبة للأنشطة السياحية والاستجمام.\n\n'
              'هل ترغب في أن أخطط لك رحلة مفصلة تشمل الطيران وحجز الفندق؟'
          : '🌟 **Best Time to Visit $displayDest:**\n\n'
              'The prime travel season runs from **October through April**, offering pleasant weather ideal for sightseeing and outdoor activities.\n\n'
              'Would you like me to curate a full travel itinerary for you?';

      return AIMessageEntity(
        id: 'ai_msg_${_uuid.v4().substring(0, 8)}',
        sender: AIMessageSender.assistant,
        content: reply,
        timestamp: DateTime.now(),
        quickReplies: isArabic
            ? ['خطط رحلة 4 أيام في $displayDest', 'أرخص الرحلات إلى $displayDest', 'أفضل الفنادق في $displayDest']
            : ['Plan 4 days in $destinationCity', 'Cheapest flights to $destinationCity', 'Best hotels in $destinationCity'],
      );
    }

    if (normalized.contains('تأشيرة') || normalized.contains('فيزا') || normalized.contains('visa')) {
      final reply = isArabic
          ? '🛂 **معلومات التأشيرة والسفر إلى $displayDest:**\n\n'
              '• تختلف متطلبات التأشيرة بحسب جنسيتك وجواز سفرك.\n'
              '• العديد من الوجهات توفر تأشيرة إلكترونية سريعة (eVisa) أو تأشيرة عند الوصول.\n'
              '• تأكد من صلاحية جواز سفرك لمدة 6 أشهر على الأقل قبل موعد السفر.\n\n'
              'اختر أحد الخيارات التالية لمتابعة التخطيط:'
          : '🛂 **Visa & Entry Requirements for $displayDest:**\n\n'
              '• Requirements vary based on your nationality and passport.\n'
              '• Many destinations provide convenient eVisas or Visa upon Arrival.\n'
              '• Ensure your passport is valid for at least 6 months before your departure date.\n\n'
              'Choose an option below to proceed:';

      return AIMessageEntity(
        id: 'ai_msg_${_uuid.v4().substring(0, 8)}',
        sender: AIMessageSender.assistant,
        content: reply,
        timestamp: DateTime.now(),
        quickReplies: isArabic
            ? ['حجز طيران إلى $displayDest', 'حجز فندق مع إلغاء مجاني', 'توزيع الميزانية']
            : ['Book flights to $destinationCity', 'Hotels with free cancellation', 'Budget optimization'],
      );
    }

    // 3. Handle Greetings or General Prompts without explicit destination
    if (!destMatched && (normalized.contains('مرحبا') || normalized.contains('hello') || normalized.contains('hi') || normalized.length < 10)) {
      final reply = isArabic
          ? 'مرحباً بك في **ترافل جو (TRAVELGO)**! 🌍✈️\n\n'
              'أنا مساعدك الذكي لتخطيط الرحلات وحجز الطيران والفنادق بأفضل الأسعار. إلى أين ترغب بالسفر؟'
          : 'Welcome to **TRAVELGO**! 🌍✈️\n\n'
              'I am your AI Travel Companion ready to plan trips, compare flights, and find hotels at the best rates. Where would you like to explore?';

      return AIMessageEntity(
        id: 'ai_msg_${_uuid.v4().substring(0, 8)}',
        sender: AIMessageSender.assistant,
        content: reply,
        timestamp: DateTime.now(),
        quickReplies: isArabic
            ? ['إسطنبول 🇹🇷', 'دبي 🇦🇪', 'باريس 🇫🇷', 'المالديف 🏝️', 'رحلة عائلية 👨‍👩‍👧', 'رحلة اقتصادية 🎒']
            : ['Istanbul 🇹🇷', 'Dubai 🇦🇪', 'Paris 🇫🇷', 'Maldives 🏝️', 'Family Trip 👨‍👩‍👧', 'Budget Trip 🎒'],
      );
    }

    // 4. Extract Budget
    double budget = 1000.0;
    final budgetMatch = RegExp(
      r'(?:\$|usd|dollar|دولار|ميزانية|under|بميزانية)\s*(\d+)|(\d+)\s*(?:\$|usd|dollar|dollars|دولار)',
      caseSensitive: false,
    ).firstMatch(query);
    if (budgetMatch != null) {
      final valStr = budgetMatch.group(1) ?? budgetMatch.group(2);
      if (valStr != null) {
        final parsed = double.tryParse(valStr);
        if (parsed != null && parsed > 0) {
          budget = parsed;
        }
      }
    }

    // 5. Extract duration in days
    int days = 4;
    final daysMatch = RegExp(r'(\d+)[-\s]*(day|days|يوم|أيام|night|nights|ليال|ليالي|ليلة)', caseSensitive: false).firstMatch(query);
    if (daysMatch != null) {
      final parsedDays = int.tryParse(daysMatch.group(1)!);
      if (parsedDays != null && parsedDays > 0 && parsedDays <= 30) {
        days = parsedDays;
      }
    }

    // 6. Query Verified Flights and Hotels
    final flightSearchParams = FlightSearchParams(
      originCode: 'ALG',
      originCity: 'Algiers',
      destinationCode: destAirportCode,
      destinationCity: destinationCity,
      departureDate: DateTime.now().add(const Duration(days: 7)),
      returnDate: DateTime.now().add(Duration(days: 7 + days)),
    );

    final hotelSearchParams = HotelSearchParams(
      destination: destinationCity,
      checkInDate: DateTime.now().add(const Duration(days: 7)),
      checkOutDate: DateTime.now().add(Duration(days: 7 + days)),
    );

    List<FlightEntity> matchingFlights = [];
    List<HotelEntity> matchingHotels = [];

    try {
      final allFlights = await _flightRepository.searchFlights(flightSearchParams);
      matchingFlights = allFlights.take(2).toList();
    } catch (_) {}

    try {
      final allHotels = await _hotelRepository.searchHotels(hotelSearchParams);
      matchingHotels = allHotels.take(2).toList();
    } catch (_) {}

    // 7. Generate Trip Plan
    final tripPlan = await generateTripPlan(
      destination: destinationCity,
      origin: 'Algiers',
      days: days,
      budgetUSD: budget,
      isArabic: isArabic,
    );

    final budgetBreakdown = calculateBudgetOptimization(
      totalBudgetUSD: budget,
      durationDays: days,
      travelers: 1,
    );

    String replyContent;
    String rationale;

    if (isArabic) {
      replyContent = 'لقد قمت بتحليل طلبك وصممت لك برنامج رحلة متكامل إلى **$displayDest** لمدة **$days أيام** بميزانية تقديرية تقارب **\$$budget دولار**.\n\n'
          '✨ قمت بالتحقق من جداول الرحلات المباشرة وأفضل الفنادق المعتمدة التي تتناسب مع ميزانيتك أدناه:';
      rationale = 'تم اختيار هذه الخيارات لتوفير أفضل قيمة سعرية مع ضمان رحلات مريحة وإقامة في مواقع مركزية.';
    } else {
      replyContent = 'I have analyzed your travel request and curated an optimized **$days-day itinerary for $destinationCity** aligned with your **\$$budget budget**.\n\n'
          '✨ Below are verified real-time flight connections and handpicked hotel stays tailored for your trip:';
      rationale = 'Selected for optimal price-to-comfort ratio, central location, and verified traveler satisfaction.';
    }

    final followUpReplies = isArabic
        ? [
            'تعديل الميزانية إلى \$${(budget * 1.5).toInt()}',
            'إضافة أنشطة عائلية إلى $displayDest',
            'أرخص فنادق في $displayDest',
            'خطط رحلة 7 أيام',
          ]
        : [
            'Adjust budget to \$${(budget * 1.5).toInt()}',
            'Add family activities in $destinationCity',
            'Cheapest hotels in $destinationCity',
            'Plan a 7-day trip',
          ];

    return AIMessageEntity(
      id: 'ai_msg_${_uuid.v4().substring(0, 8)}',
      sender: AIMessageSender.assistant,
      content: replyContent,
      timestamp: DateTime.now(),
      extractedIntent: AIExtractedIntent(
        destination: destinationCity,
        origin: 'ALG',
        durationDays: days,
        budgetUSD: budget,
      ),
      recommendedFlights: matchingFlights,
      recommendedHotels: matchingHotels,
      tripPlan: tripPlan,
      budgetBreakdown: budgetBreakdown,
      aiRationale: rationale,
      quickReplies: followUpReplies,
    );
  }

  @override
  Future<AITripPlanEntity> generateTripPlan({
    required String destination,
    required String origin,
    required int days,
    required double budgetUSD,
    bool isArabic = false,
  }) async {
    final List<AITripDayPlan> dayPlans = [];

    for (int i = 1; i <= days; i++) {
      if (i == 1) {
        dayPlans.add(
          AITripDayPlan(
            dayNumber: 1,
            title: isArabic ? 'الوصول واستكشاف المدينة' : 'Arrival & City Orientation',
            theme: isArabic ? 'تسجيل الوصول وجولة مسائية' : 'Check-in & Evening Stroll',
            activities: [
              AITripDayActivity(
                time: '02:00 PM',
                title: isArabic ? 'تسجيل الوصول بالفندق' : 'Hotel Check-in & Refresh',
                description: isArabic ? 'استلام الغرفة وأخذ قسط من الراحة' : 'Check in and unpack at your hotel.',
              ),
              AITripDayActivity(
                time: '05:30 PM',
                title: isArabic ? 'جولة في وسط المدينة' : 'Downtown Exploration & Dinner',
                description: isArabic ? 'استكشاف المعالم القريبة وتناول عشاء محلي' : 'Stroll through the historic center and enjoy local cuisine.',
              ),
            ],
          ),
        );
      } else if (i == days) {
        dayPlans.add(
          AITripDayPlan(
            dayNumber: i,
            title: isArabic ? 'التسوق والاستعداد للمغادرة' : 'Souvenirs & Departure',
            theme: isArabic ? 'شراء التذكارات والمطار' : 'Last-minute Shopping & Flight',
            activities: [
              AITripDayActivity(
                time: '10:00 AM',
                title: isArabic ? 'جولة تسوق وشراء تذكارات' : 'Boutique & Souvenir Shopping',
                description: isArabic ? 'زيارة الأسواق الشهيرة لشراء الهدايا' : 'Pick up authentic local gifts and crafts.',
              ),
              AITripDayActivity(
                time: '04:00 PM',
                title: isArabic ? 'التوجه إلى المطار' : 'Airport Transfer & Departure',
                description: isArabic ? 'إنهاء إجراءات السفر والعودة بسلام' : 'Head to the airport for your return flight.',
              ),
            ],
          ),
        );
      } else {
        dayPlans.add(
          AITripDayPlan(
            dayNumber: i,
            title: isArabic ? 'معالم $destination وأبرز الأنشطة' : 'Exploring Top Highlights of $destination',
            theme: isArabic ? 'ثقافة ومغامرة' : 'Culture, Sights & Adventure',
            activities: [
              AITripDayActivity(
                time: '09:30 AM',
                title: isArabic ? 'زيارة المعالم التاريخية الشهيرة' : 'Iconic Landmarks Tour',
                description: isArabic ? 'جولة مصحوبة بمرشد سياحي في أشهر المعالم' : 'Visit world-famous architectural and cultural sites.',
              ),
              AITripDayActivity(
                time: '01:00 PM',
                title: isArabic ? 'غداء في مطعم مميز' : 'Culinary Tasting Lunch',
                description: isArabic ? 'تجربة الأطباق التقليدية الشهية' : 'Sample authentic regional specialties.',
              ),
              AITripDayActivity(
                time: '04:00 PM',
                title: isArabic ? 'نشاط ترفيهي وإطلالة بانورامية' : 'Scenic Viewpoint & Sunset',
                description: isArabic ? 'التقاط صور تذكارية عند غروب الشمس' : 'Catch panoramic sunset views over the city skyline.',
              ),
            ],
          ),
        );
      }
    }

    final tips = isArabic
        ? [
            'احرص على حجز التذاكر مسبقاً لتفادي طوابير الانتظار.',
            'استخدم وسائل النقل العامة أو تطبيقات التنقل لتوفير الميزانية.',
            'احتفظ بنسخة رقمية من وثائق الحجز في تطبيق ترافل جو.',
          ]
        : [
            'Book museum and landmark passes ahead of time to skip queues.',
            'Use metro and public transit passes for efficient inner-city travel.',
            'Save your offline booking vouchers in TRAVELGO for seamless access.',
          ];

    return AITripPlanEntity(
      id: 'plan_${_uuid.v4().substring(0, 8)}',
      title: isArabic ? 'رحلة $days أيام إلى $destination' : '$days-Day $destination Getaway',
      destination: destination,
      origin: origin,
      durationDays: days,
      estimatedTotalCostUSD: budgetUSD * 0.92,
      summary: isArabic
          ? 'برنامج متوازن يجمع بين المعالم البارزة، الاسترخاء، والتجارب الثقافية الممتعة.'
          : 'A well-rounded, balanced itinerary combining marquee sights, culinary highlights, and relaxation.',
      days: dayPlans,
      travelTips: tips,
    );
  }
}
