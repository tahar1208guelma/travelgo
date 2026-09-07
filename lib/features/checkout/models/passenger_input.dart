import '../../bookings/models/passenger.dart';

class PassengerInput {
  String firstName;
  String lastName;
  String email;
  String phone;
  String passportNumber;
  DateTime dateOfBirth;
  String nationality;
  PassengerType passengerType;
  String? seatPreference;
  String? mealPreference;

  PassengerInput({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.passportNumber,
    required this.dateOfBirth,
    this.nationality = 'Algerian',
    this.passengerType = PassengerType.adult,
    this.seatPreference,
    this.mealPreference,
  });

  String get fullName => '$firstName $lastName'.trim();

  Passenger toPassenger(String id, {String? seatNumber}) {
    return Passenger(
      id: id,
      fullName: fullName,
      passengerType: passengerType,
      seatNumber: seatNumber ?? seatPreference,
    );
  }
}
