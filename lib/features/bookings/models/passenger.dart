enum PassengerType {
  adult,
  child,
  infant;

  String get displayName {
    switch (this) {
      case PassengerType.adult:
        return 'Adult';
      case PassengerType.child:
        return 'Child';
      case PassengerType.infant:
        return 'Infant';
    }
  }
}

class Passenger {
  final String id;
  final String fullName;
  final PassengerType passengerType;
  final String? passportNumberMasked;
  final String? nationality;
  final String? seatNumber;

  const Passenger({
    required this.id,
    required this.fullName,
    this.passengerType = PassengerType.adult,
    this.passportNumberMasked,
    this.nationality,
    this.seatNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'passengerType': passengerType.name,
      'passportNumberMasked': passportNumberMasked,
      'nationality': nationality,
      'seatNumber': seatNumber,
    };
  }

  factory Passenger.fromMap(Map<String, dynamic> map) {
    return Passenger(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      passengerType: PassengerType.values.firstWhere(
        (e) => e.name == map['passengerType'],
        orElse: () => PassengerType.adult,
      ),
      passportNumberMasked: map['passportNumberMasked'] as String?,
      nationality: map['nationality'] as String?,
      seatNumber: map['seatNumber'] as String?,
    );
  }
}
