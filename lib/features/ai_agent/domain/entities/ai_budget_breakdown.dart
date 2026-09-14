class AIBudgetBreakdown {
  final double totalBudgetUSD;
  final double flightBudgetUSD;
  final double hotelBudgetUSD;
  final double activitiesBudgetUSD;
  final double bufferUSD;
  final int durationDays;
  final int travelers;

  const AIBudgetBreakdown({
    required this.totalBudgetUSD,
    required this.flightBudgetUSD,
    required this.hotelBudgetUSD,
    required this.activitiesBudgetUSD,
    required this.bufferUSD,
    required this.durationDays,
    required this.travelers,
  });

  double get flightPercentage => totalBudgetUSD > 0 ? (flightBudgetUSD / totalBudgetUSD) * 100 : 0;
  double get hotelPercentage => totalBudgetUSD > 0 ? (hotelBudgetUSD / totalBudgetUSD) * 100 : 0;
  double get activitiesPercentage => totalBudgetUSD > 0 ? (activitiesBudgetUSD / totalBudgetUSD) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'totalBudgetUSD': totalBudgetUSD,
      'flightBudgetUSD': flightBudgetUSD,
      'hotelBudgetUSD': hotelBudgetUSD,
      'activitiesBudgetUSD': activitiesBudgetUSD,
      'bufferUSD': bufferUSD,
      'durationDays': durationDays,
      'travelers': travelers,
    };
  }

  factory AIBudgetBreakdown.fromJson(Map<String, dynamic> json) {
    return AIBudgetBreakdown(
      totalBudgetUSD: (json['totalBudgetUSD'] as num).toDouble(),
      flightBudgetUSD: (json['flightBudgetUSD'] as num).toDouble(),
      hotelBudgetUSD: (json['hotelBudgetUSD'] as num).toDouble(),
      activitiesBudgetUSD: (json['activitiesBudgetUSD'] as num).toDouble(),
      bufferUSD: (json['bufferUSD'] as num).toDouble(),
      durationDays: json['durationDays'] as int? ?? 1,
      travelers: json['travelers'] as int? ?? 1,
    );
  }
}
