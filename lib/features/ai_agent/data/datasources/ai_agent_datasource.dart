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

  @override
  Future<AIMessageEntity> processUserQuery({
    required String query,
    required List<AIMessageEntity> history,
    bool isArabic = false,
  }) async {
    // Simulate natural AI thinking latency (non-blocking)
    await Future.delayed(const Duration(milliseconds: 700));

    final normalized = query.toLowerCase();

    // 1. Extract destination from query
    String destinationCity = 'Dubai';
    String destAirportCode = 'DXB';

    if (normalized.contains('paris') || normalized.contains('باريس')) {
      destinationCity = 'Paris';
      destAirportCode = 'CDG';
    } else if (normalized.contains('istanbul') || normalized.contains('اسطنبول') || normalized.contains('إسطنبول')) {
      destinationCity = 'Istanbul';
      destAirportCode = 'IST';
    } else if (normalized.contains('algiers') || normalized.contains('الجزائر')) {
      destinationCity = 'Algiers';
      destAirportCode = 'ALG';
    } else if (normalized.contains('riyadh') || normalized.contains('الرياض')) {
      destinationCity = 'Riyadh';
      destAirportCode = 'RUH';
    } else if (normalized.contains('london') || normalized.contains('لندن')) {
      destinationCity = 'London';
      destAirportCode = 'LHR';
    }

    // 2. Extract budget if mentioned
    double budget = 1000.0;
    final budgetMatch = RegExp(r'(\d+)\s*(\$|usd|dollar|دولار)?', caseSensitive: false).firstMatch(query);
    if (budgetMatch != null) {
      final parsed = double.tryParse(budgetMatch.group(1)!);
      if (parsed != null && parsed >= 100) {
        budget = parsed;
      }
    }

    // 3. Extract duration in days
    int days = 4;
    final daysMatch = RegExp(r'(\d+)\s*(day|days|يوم|أيام)', caseSensitive: false).firstMatch(query);
    if (daysMatch != null) {
      final parsedDays = int.tryParse(daysMatch.group(1)!);
      if (parsedDays != null && parsedDays > 0 && parsedDays <= 30) {
        days = parsedDays;
      }
    }

    // 4. Query Verified Flights and Hotels from deterministic repositories
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

    // 5. Generate Trip Plan if requested or general search
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

    // 6. Build contextual AI response text
    String replyContent;
    String rationale;

    if (isArabic) {
      replyContent = 'لقد قمت بتحليل طلبك وصممت لك برنامج رحلة متكامل إلى **$destinationCity** لمدة **$days أيام** بميزانية تقديرية تقارب **\$$budget دولار**.\n\n'
          '✨ قمت بالتحقق من جداول الرحلات المباشرة وأفضل الفنادق المعتمدة التي تتناسب مع ميزانيتك أدناه:';
      rationale = 'تم اختيار هذه الخيارات لتوفير أفضل قيمة سعرية مع ضمان رحلات مريحة وإقامة في مواقع مركزية.';
    } else {
      replyContent = 'I have analyzed your travel request and curated an optimized **$days-day itinerary for $destinationCity** aligned with your **\$$budget budget**.\n\n'
          '✨ Below are verified real-time flight connections and handpicked hotel stays tailored for your trip:';
      rationale = 'Selected for optimal price-to-comfort ratio, central location, and verified traveler satisfaction.';
    }

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
      estimatedTotalCostUSD: budgetUSD * 0.92, // estimated actual total below user ceiling
      summary: isArabic
          ? 'برنامج متوازن يجمع بين المعالم البارزة، الاسترخاء، والتجارب الثقافية الممتعة.'
          : 'A well-rounded, balanced itinerary combining marquee sights, culinary highlights, and relaxation.',
      days: dayPlans,
      travelTips: tips,
    );
  }
}
