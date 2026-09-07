class HotelSearchQuery {
  final String destination;
  final String city;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int adults;
  final int children;
  final int rooms;
  final double? maxPrice;
  final int? minStarRating;

  const HotelSearchQuery({
    required this.destination,
    required this.city,
    required this.checkInDate,
    required this.checkOutDate,
    this.adults = 2,
    this.children = 0,
    this.rooms = 1,
    this.maxPrice,
    this.minStarRating,
  });

  int get totalNights => checkOutDate.difference(checkInDate).inDays > 0
      ? checkOutDate.difference(checkInDate).inDays
      : 1;

  int get totalGuests => adults + children;

  Map<String, dynamic> toQueryParams() {
    return {
      'destination': destination,
      'city': city,
      'checkIn': checkInDate.toIso8601String().split('T').first,
      'checkOut': checkOutDate.toIso8601String().split('T').first,
      'adults': adults,
      'children': children,
      'rooms': rooms,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (minStarRating != null) 'minStars': minStarRating,
    };
  }
}
