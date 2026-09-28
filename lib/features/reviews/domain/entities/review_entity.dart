class ReviewEntity {
  final String id;
  final String propertyOrTripId;
  final String authorName;
  final String authorCountry;
  final String? authorAvatar;
  final double rating; // 1.0 - 5.0
  final String title;
  final String comment;
  final DateTime date;
  final bool isVerifiedStay;
  final double cleanlinessScore;
  final double locationScore;
  final double serviceScore;
  final double valueScore;
  final int helpfulVotes;

  const ReviewEntity({
    required this.id,
    required this.propertyOrTripId,
    required this.authorName,
    required this.authorCountry,
    this.authorAvatar,
    required this.rating,
    required this.title,
    required this.comment,
    required this.date,
    this.isVerifiedStay = true,
    this.cleanlinessScore = 4.9,
    this.locationScore = 4.8,
    this.serviceScore = 4.9,
    this.valueScore = 4.7,
    this.helpfulVotes = 12,
  });

  static List<ReviewEntity> getSampleReviews(String propertyId) => [
        ReviewEntity(
          id: 'rev_001',
          propertyOrTripId: propertyId,
          authorName: 'Yassine Mansouri',
          authorCountry: 'Algeria',
          rating: 5.0,
          title: 'Unforgettable experience in the Sahara desert!',
          comment: 'The hospitality, traditional dinner under the stars, and camel safari were beyond incredible. Clean facilities and helpful guides.',
          date: DateTime(2026, 2, 18),
          isVerifiedStay: true,
          helpfulVotes: 34,
        ),
        ReviewEntity(
          id: 'rev_002',
          propertyOrTripId: propertyId,
          authorName: 'Elena Rostova',
          authorCountry: 'Switzerland',
          rating: 4.8,
          title: 'Top-tier luxury and breathtaking views',
          comment: 'Impeccable service from the moment we arrived. The rooms were spotless and the breakfast buffet was 5-star quality.',
          date: DateTime(2026, 1, 29),
          isVerifiedStay: true,
          helpfulVotes: 19,
        ),
      ];
}
