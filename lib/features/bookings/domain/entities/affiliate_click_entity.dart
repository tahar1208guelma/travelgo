class AffiliateClickEntity {
  final String id;
  final String userId;
  final String provider; // "Booking.com", "Skyscanner", etc.
  final String productType; // "flight" or "hotel"
  final String productId;
  final String trackingId;
  final String targetUrl;
  final DateTime clickedAt;

  const AffiliateClickEntity({
    required this.id,
    required this.userId,
    required this.provider,
    required this.productType,
    required this.productId,
    required this.trackingId,
    required this.targetUrl,
    required this.clickedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'provider': provider,
      'productType': productType,
      'productId': productId,
      'trackingId': trackingId,
      'targetUrl': targetUrl,
      'clickedAt': clickedAt.toIso8601String(),
    };
  }

  factory AffiliateClickEntity.fromJson(Map<String, dynamic> json) {
    return AffiliateClickEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      provider: json['provider'] as String,
      productType: json['productType'] as String,
      productId: json['productId'] as String,
      trackingId: json['trackingId'] as String,
      targetUrl: json['targetUrl'] as String,
      clickedAt: DateTime.parse(json['clickedAt'] as String),
    );
  }
}
