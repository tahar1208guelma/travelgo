enum BookingType {
  flight,
  hotel,
  flightAndHotel;

  String get displayName {
    switch (this) {
      case BookingType.flight:
        return 'Flight';
      case BookingType.hotel:
        return 'Hotel';
      case BookingType.flightAndHotel:
        return 'Flight + Hotel';
    }
  }
}
