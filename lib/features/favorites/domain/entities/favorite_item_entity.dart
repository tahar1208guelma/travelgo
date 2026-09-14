class FavoriteItemEntity {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double priceUSD;
  final String type; // "flight" or "hotel"
  final double rating;
  final DateTime createdAt;

  const FavoriteItemEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.priceUSD,
    required this.type,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'priceUSD': priceUSD,
      'type': type,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FavoriteItemEntity.fromJson(Map<String, dynamic> json) {
    return FavoriteItemEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['imageUrl'] as String,
      priceUSD: (json['priceUSD'] as num).toDouble(),
      type: json['type'] as String,
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
