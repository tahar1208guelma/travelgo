import '../../flights/models/flight_offer.dart';
import '../../hotels/models/hotel_offer.dart';
import '../models/passenger_input.dart';
import '../models/payment_method.dart';

abstract class CheckoutEvent {
  const CheckoutEvent();
}

class StartFlightCheckout extends CheckoutEvent {
  final FlightOffer offer;
  const StartFlightCheckout(this.offer);
}

class StartHotelCheckout extends CheckoutEvent {
  final HotelOffer hotel;
  final String leadGuestName;
  final String leadGuestEmail;
  const StartHotelCheckout({
    required this.hotel,
    required this.leadGuestName,
    required this.leadGuestEmail,
  });
}

class SubmitTravelerDetails extends CheckoutEvent {
  final List<PassengerInput> passengers;
  final String contactEmail;
  final String contactPhone;
  const SubmitTravelerDetails({
    required this.passengers,
    required this.contactEmail,
    required this.contactPhone,
  });
}

class ProcessTokenizedPayment extends CheckoutEvent {
  final TokenizedPaymentMethod paymentMethod;
  const ProcessTokenizedPayment(this.paymentMethod);
}

class Complete3DSChallenge extends CheckoutEvent {
  const Complete3DSChallenge();
}

class ResetCheckout extends CheckoutEvent {
  const ResetCheckout();
}
