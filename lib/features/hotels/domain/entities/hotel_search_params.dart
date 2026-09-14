class HotelSearchParams {
  final String destination;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int adults;
  final int children;
  final int rooms;
  final double? minPrice;
  final double? maxPrice;
  final int? minRating;

  const HotelSearchParams({
    required this.destination,
    required this.checkInDate,
    required this.checkOutDate,
    this.adults = 2,
    this.children = 0,
    this.rooms = 1,
    this.minPrice,
    this.maxPrice,
    this.minRating,
  });

  int get totalGuests => adults + children;

  int get nights {
    final start = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    final end = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
    final diff = end.difference(start).inDays;
    return diff > 0 ? diff : 1;
  }

  HotelSearchParams copyWith({
    String? destination,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? adults,
    int? children,
    int? rooms,
    double? minPrice,
    double? maxPrice,
    int? minRating,
  }) {
    return HotelSearchParams(
      destination: destination ?? this.destination,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      rooms: rooms ?? this.rooms,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'adults': adults,
      'children': children,
      'rooms': rooms,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRating': minRating,
    };
  }

  factory HotelSearchParams.fromJson(Map<String, dynamic> json) {
    return HotelSearchParams(
      destination: json['destination'] as String? ?? 'Dubai',
      checkInDate: json['checkInDate'] != null ? DateTime.parse(json['checkInDate']) : DateTime.now().add(const Duration(days: 5)),
      checkOutDate: json['checkOutDate'] != null ? DateTime.parse(json['checkOutDate']) : DateTime.now().add(const Duration(days: 9)),
      adults: json['adults'] as int? ?? 2,
      children: json['children'] as int? ?? 0,
      rooms: json['rooms'] as int? ?? 1,
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      minRating: json['minRating'] as int?,
    );
  }
}
