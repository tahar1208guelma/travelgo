class HotelRoom {
  final String roomType;
  final int numberOfGuests;
  final String? bedType;
  final String? description;

  const HotelRoom({
    required this.roomType,
    required this.numberOfGuests,
    this.bedType,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomType': roomType,
      'numberOfGuests': numberOfGuests,
      'bedType': bedType,
      'description': description,
    };
  }

  factory HotelRoom.fromMap(Map<String, dynamic> map) {
    return HotelRoom(
      roomType: map['roomType'] as String,
      numberOfGuests: map['numberOfGuests'] as int? ?? 1,
      bedType: map['bedType'] as String?,
      description: map['description'] as String?,
    );
  }
}

class HotelBookingDetails {
  final String hotelName;
  final String hotelAddress;
  final String? hotelCity;
  final String? hotelCountry;
  final String? hotelPhone;
  final String? hotelEmail;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfNights;
  final int numberOfGuests;
  final List<HotelRoom> rooms;
  final String mealPlan;
  final String cancellationPolicy;
  final String guestName;
  final String? hotelConfirmationNumber;
  final String? specialRequests;

  const HotelBookingDetails({
    required this.hotelName,
    required this.hotelAddress,
    this.hotelCity,
    this.hotelCountry,
    this.hotelPhone,
    this.hotelEmail,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.numberOfGuests,
    required this.rooms,
    required this.mealPlan,
    required this.cancellationPolicy,
    required this.guestName,
    this.hotelConfirmationNumber,
    this.specialRequests,
  });

  Map<String, dynamic> toMap() {
    return {
      'hotelName': hotelName,
      'hotelAddress': hotelAddress,
      'hotelCity': hotelCity,
      'hotelCountry': hotelCountry,
      'hotelPhone': hotelPhone,
      'hotelEmail': hotelEmail,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfNights': numberOfNights,
      'numberOfGuests': numberOfGuests,
      'rooms': rooms.map((r) => r.toMap()).toList(),
      'mealPlan': mealPlan,
      'cancellationPolicy': cancellationPolicy,
      'guestName': guestName,
      'hotelConfirmationNumber': hotelConfirmationNumber,
      'specialRequests': specialRequests,
    };
  }

  factory HotelBookingDetails.fromMap(Map<String, dynamic> map) {
    return HotelBookingDetails(
      hotelName: map['hotelName'] as String,
      hotelAddress: map['hotelAddress'] as String,
      hotelCity: map['hotelCity'] as String?,
      hotelCountry: map['hotelCountry'] as String?,
      hotelPhone: map['hotelPhone'] as String?,
      hotelEmail: map['hotelEmail'] as String?,
      checkInDate: DateTime.parse(map['checkInDate'] as String),
      checkOutDate: DateTime.parse(map['checkOutDate'] as String),
      numberOfNights: map['numberOfNights'] as int? ?? 1,
      numberOfGuests: map['numberOfGuests'] as int? ?? 1,
      rooms: (map['rooms'] as List<dynamic>)
          .map((r) => HotelRoom.fromMap(r as Map<String, dynamic>))
          .toList(),
      mealPlan: map['mealPlan'] as String? ?? 'Room Only',
      cancellationPolicy: map['cancellationPolicy'] as String? ?? 'Non-refundable',
      guestName: map['guestName'] as String,
      hotelConfirmationNumber: map['hotelConfirmationNumber'] as String?,
      specialRequests: map['specialRequests'] as String?,
    );
  }
}
