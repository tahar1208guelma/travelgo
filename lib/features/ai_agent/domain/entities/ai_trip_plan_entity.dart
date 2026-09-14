class AITripDayActivity {
  final String time; // e.g. "09:00 AM", "02:30 PM", "Evening"
  final String title;
  final String description;
  final String? icon;

  const AITripDayActivity({
    required this.time,
    required this.title,
    required this.description,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
    'time': time,
    'title': title,
    'description': description,
    'icon': icon,
  };

  factory AITripDayActivity.fromJson(Map<String, dynamic> json) => AITripDayActivity(
    time: json['time'] as String? ?? 'Daytime',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    icon: json['icon'] as String?,
  );
}

class AITripDayPlan {
  final int dayNumber;
  final String title;
  final String theme; // e.g. "Historical & Cultural Exploration"
  final List<AITripDayActivity> activities;

  const AITripDayPlan({
    required this.dayNumber,
    required this.title,
    required this.theme,
    required this.activities,
  });

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'title': title,
    'theme': theme,
    'activities': activities.map((a) => a.toJson()).toList(),
  };

  factory AITripDayPlan.fromJson(Map<String, dynamic> json) => AITripDayPlan(
    dayNumber: json['dayNumber'] as int? ?? 1,
    title: json['title'] as String? ?? '',
    theme: json['theme'] as String? ?? '',
    activities: (json['activities'] as List<dynamic>?)
            ?.map((a) => AITripDayActivity.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

class AITripPlanEntity {
  final String id;
  final String title;
  final String destination;
  final String origin;
  final int durationDays;
  final double estimatedTotalCostUSD;
  final String? recommendedFlightId;
  final String? recommendedHotelId;
  final String summary;
  final List<AITripDayPlan> days;
  final List<String> travelTips;

  const AITripPlanEntity({
    required this.id,
    required this.title,
    required this.destination,
    required this.origin,
    required this.durationDays,
    required this.estimatedTotalCostUSD,
    this.recommendedFlightId,
    this.recommendedHotelId,
    required this.summary,
    required this.days,
    this.travelTips = const [],
  });
}
