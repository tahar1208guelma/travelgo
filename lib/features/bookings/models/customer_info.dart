enum PassengerType {
  adult,
  child,
  infant,
}

class PassengerInfo {
  final String fullName;
  final PassengerType passengerType;
  final String? passportOrIdNumber;
  final String? nationality;
  final String? seatNumber;
  final String? ticketNumber;
  final String? specialRequests;

  const PassengerInfo({
    required this.fullName,
    this.passengerType = PassengerType.adult,
    this.passportOrIdNumber,
    this.nationality,
    this.seatNumber,
    this.ticketNumber,
    this.specialRequests,
  });

  String get typeLabel {
    switch (passengerType) {
      case PassengerType.adult:
        return 'Adult';
      case PassengerType.child:
        return 'Child';
      case PassengerType.infant:
        return 'Infant';
    }
  }

  PassengerInfo copyWith({
    String? fullName,
    PassengerType? passengerType,
    String? passportOrIdNumber,
    String? nationality,
    String? seatNumber,
    String? ticketNumber,
    String? specialRequests,
  }) {
    return PassengerInfo(
      fullName: fullName ?? this.fullName,
      passengerType: passengerType ?? this.passengerType,
      passportOrIdNumber: passportOrIdNumber ?? this.passportOrIdNumber,
      nationality: nationality ?? this.nationality,
      seatNumber: seatNumber ?? this.seatNumber,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }

  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      fullName: json['fullName'] as String? ?? '',
      passengerType: PassengerType.values.firstWhere(
        (e) => e.name == json['passengerType'],
        orElse: () => PassengerType.adult,
      ),
      passportOrIdNumber: json['passportOrIdNumber'] as String?,
      nationality: json['nationality'] as String?,
      seatNumber: json['seatNumber'] as String?,
      ticketNumber: json['ticketNumber'] as String?,
      specialRequests: json['specialRequests'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'passengerType': passengerType.name,
      'passportOrIdNumber': passportOrIdNumber,
      'nationality': nationality,
      'seatNumber': seatNumber,
      'ticketNumber': ticketNumber,
      'specialRequests': specialRequests,
    };
  }
}

class CustomerInfo {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final List<PassengerInfo> passengers;

  const CustomerInfo({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.passengers = const [],
  });

  CustomerInfo copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    List<PassengerInfo>? passengers,
  }) {
    return CustomerInfo(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passengers: passengers ?? this.passengers,
    );
  }

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      passengers: (json['passengers'] as List<dynamic>?)
              ?.map((e) => PassengerInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'passengers': passengers.map((p) => p.toJson()).toList(),
    };
  }
}
