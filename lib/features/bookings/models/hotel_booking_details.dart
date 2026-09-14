import 'customer_info.dart';

class HotelRoomDetails {
  final String roomType;
  final String? description;
  final int numberOfGuests;
  final String? bedType;
  final String? mealPlan;
  final double? pricePerNightUSD;

  const HotelRoomDetails({
    required this.roomType,
    this.description,
    this.numberOfGuests = 2,
    this.bedType,
    this.mealPlan,
    this.pricePerNightUSD,
  });

  HotelRoomDetails copyWith({
    String? roomType,
    String? description,
    int? numberOfGuests,
    String? bedType,
    String? mealPlan,
    double? pricePerNightUSD,
  }) {
    return HotelRoomDetails(
      roomType: roomType ?? this.roomType,
      description: description ?? this.description,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      bedType: bedType ?? this.bedType,
      mealPlan: mealPlan ?? this.mealPlan,
      pricePerNightUSD: pricePerNightUSD ?? this.pricePerNightUSD,
    );
  }

  factory HotelRoomDetails.fromJson(Map<String, dynamic> json) {
    return HotelRoomDetails(
      roomType: json['roomType'] as String? ?? 'Standard Room',
      description: json['description'] as String?,
      numberOfGuests: (json['numberOfGuests'] as num?)?.toInt() ?? 2,
      bedType: json['bedType'] as String?,
      mealPlan: json['mealPlan'] as String?,
      pricePerNightUSD: (json['pricePerNightUSD'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomType': roomType,
      'description': description,
      'numberOfGuests': numberOfGuests,
      'bedType': bedType,
      'mealPlan': mealPlan,
      'pricePerNightUSD': pricePerNightUSD,
    };
  }
}

class HotelBookingDetails {
  final String hotelConfirmationNumber;
  final String hotelName;
  final String hotelAddress;
  final String? hotelCity;
  final String? hotelCountry;
  final double? hotelRating;
  final String? hotelPhone;
  final String? hotelEmail;
  final DateTime checkInDate;
  final String checkInTime;
  final DateTime checkOutDate;
  final String checkOutTime;
  final int numberOfNights;
  final int numberOfGuests;
  final int numberOfRooms;
  final String roomType;
  final String mealPlan;
  final String cancellationPolicy;
  final List<HotelRoomDetails> rooms;
  final List<CustomerInfo> guests;
  final String? specialRequests;

  const HotelBookingDetails({
    required this.hotelConfirmationNumber,
    required this.hotelName,
    required this.hotelAddress,
    this.hotelCity,
    this.hotelCountry,
    this.hotelRating,
    this.hotelPhone,
    this.hotelEmail,
    required this.checkInDate,
    this.checkInTime = '14:00',
    required this.checkOutDate,
    this.checkOutTime = '12:00',
    required this.numberOfNights,
    required this.numberOfGuests,
    this.numberOfRooms = 1,
    required this.roomType,
    required this.mealPlan,
    required this.cancellationPolicy,
    this.rooms = const [],
    this.guests = const [],
    this.specialRequests,
  });

  HotelBookingDetails copyWith({
    String? hotelConfirmationNumber,
    String? hotelName,
    String? hotelAddress,
    String? hotelCity,
    String? hotelCountry,
    double? hotelRating,
    String? hotelPhone,
    String? hotelEmail,
    DateTime? checkInDate,
    String? checkInTime,
    DateTime? checkOutDate,
    String? checkOutTime,
    int? numberOfNights,
    int? numberOfGuests,
    int? numberOfRooms,
    String? roomType,
    String? mealPlan,
    String? cancellationPolicy,
    List<HotelRoomDetails>? rooms,
    List<CustomerInfo>? guests,
    String? specialRequests,
  }) {
    return HotelBookingDetails(
      hotelConfirmationNumber: hotelConfirmationNumber ?? this.hotelConfirmationNumber,
      hotelName: hotelName ?? this.hotelName,
      hotelAddress: hotelAddress ?? this.hotelAddress,
      hotelCity: hotelCity ?? this.hotelCity,
      hotelCountry: hotelCountry ?? this.hotelCountry,
      hotelRating: hotelRating ?? this.hotelRating,
      hotelPhone: hotelPhone ?? this.hotelPhone,
      hotelEmail: hotelEmail ?? this.hotelEmail,
      checkInDate: checkInDate ?? this.checkInDate,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      numberOfNights: numberOfNights ?? this.numberOfNights,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      roomType: roomType ?? this.roomType,
      mealPlan: mealPlan ?? this.mealPlan,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      rooms: rooms ?? this.rooms,
      guests: guests ?? this.guests,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }

  factory HotelBookingDetails.fromJson(Map<String, dynamic> json) {
    return HotelBookingDetails(
      hotelConfirmationNumber: json['hotelConfirmationNumber'] as String? ?? 'HTL-CONF',
      hotelName: json['hotelName'] as String? ?? 'Hotel',
      hotelAddress: json['hotelAddress'] as String? ?? 'Hotel Address',
      hotelCity: json['hotelCity'] as String?,
      hotelCountry: json['hotelCountry'] as String?,
      hotelRating: (json['hotelRating'] as num?)?.toDouble(),
      hotelPhone: json['hotelPhone'] as String?,
      hotelEmail: json['hotelEmail'] as String?,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      checkInTime: json['checkInTime'] as String? ?? '14:00',
      checkOutDate: DateTime.parse(json['checkOutDate'] as String),
      checkOutTime: json['checkOutTime'] as String? ?? '12:00',
      numberOfNights: (json['numberOfNights'] as num?)?.toInt() ?? 1,
      numberOfGuests: (json['numberOfGuests'] as num?)?.toInt() ?? 1,
      numberOfRooms: (json['numberOfRooms'] as num?)?.toInt() ?? 1,
      roomType: json['roomType'] as String? ?? 'Standard Room',
      mealPlan: json['mealPlan'] as String? ?? 'Room Only',
      cancellationPolicy: json['cancellationPolicy'] as String? ?? 'Non-refundable',
      rooms: (json['rooms'] as List<dynamic>?)
              ?.map((e) => HotelRoomDetails.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      guests: (json['guests'] as List<dynamic>?)
              ?.map((e) => CustomerInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      specialRequests: json['specialRequests'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotelConfirmationNumber': hotelConfirmationNumber,
      'hotelName': hotelName,
      'hotelAddress': hotelAddress,
      'hotelCity': hotelCity,
      'hotelCountry': hotelCountry,
      'hotelRating': hotelRating,
      'hotelPhone': hotelPhone,
      'hotelEmail': hotelEmail,
      'checkInDate': checkInDate.toIso8601String(),
      'checkInTime': checkInTime,
      'checkOutDate': checkOutDate.toIso8601String(),
      'checkOutTime': checkOutTime,
      'numberOfNights': numberOfNights,
      'numberOfGuests': numberOfGuests,
      'numberOfRooms': numberOfRooms,
      'roomType': roomType,
      'mealPlan': mealPlan,
      'cancellationPolicy': cancellationPolicy,
      'rooms': rooms.map((r) => r.toJson()).toList(),
      'guests': guests.map((g) => g.toJson()).toList(),
      'specialRequests': specialRequests,
    };
  }
}
