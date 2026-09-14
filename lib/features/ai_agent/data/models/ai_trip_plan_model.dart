import '../../domain/entities/ai_trip_plan_entity.dart';

class AITripPlanModel extends AITripPlanEntity {
  const AITripPlanModel({
    required super.id,
    required super.title,
    required super.destination,
    required super.origin,
    required super.durationDays,
    required super.estimatedTotalCostUSD,
    super.recommendedFlightId,
    super.recommendedHotelId,
    required super.summary,
    required super.days,
    super.travelTips,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'destination': destination,
    'origin': origin,
    'durationDays': durationDays,
    'estimatedTotalCostUSD': estimatedTotalCostUSD,
    'recommendedFlightId': recommendedFlightId,
    'recommendedHotelId': recommendedHotelId,
    'summary': summary,
    'days': days.map((d) => d.toJson()).toList(),
    'travelTips': travelTips,
  };

  factory AITripPlanModel.fromJson(Map<String, dynamic> json) => AITripPlanModel(
    id: json['id'] as String? ?? 'plan_${DateTime.now().millisecondsSinceEpoch}',
    title: json['title'] as String? ?? 'AI Trip Itinerary',
    destination: json['destination'] as String? ?? 'Dubai',
    origin: json['origin'] as String? ?? 'ALG',
    durationDays: json['durationDays'] as int? ?? 4,
    estimatedTotalCostUSD: (json['estimatedTotalCostUSD'] as num?)?.toDouble() ?? 500.0,
    recommendedFlightId: json['recommendedFlightId'] as String?,
    recommendedHotelId: json['recommendedHotelId'] as String?,
    summary: json['summary'] as String? ?? '',
    days: (json['days'] as List<dynamic>?)
            ?.map((d) => AITripDayPlan.fromJson(d as Map<String, dynamic>))
            .toList() ??
        [],
    travelTips: (json['travelTips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
  );

  factory AITripPlanModel.fromEntity(AITripPlanEntity entity) => AITripPlanModel(
    id: entity.id,
    title: entity.title,
    destination: entity.destination,
    origin: entity.origin,
    durationDays: entity.durationDays,
    estimatedTotalCostUSD: entity.estimatedTotalCostUSD,
    recommendedFlightId: entity.recommendedFlightId,
    recommendedHotelId: entity.recommendedHotelId,
    summary: entity.summary,
    days: entity.days,
    travelTips: entity.travelTips,
  );
}
