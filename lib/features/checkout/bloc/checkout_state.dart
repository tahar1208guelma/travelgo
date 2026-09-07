import '../../bookings/models/booking.dart';
import '../../flights/models/flight_offer.dart';
import '../../hotels/models/hotel_offer.dart';
import '../models/passenger_input.dart';
import '../models/payment_intent.dart';
import '../models/payment_method.dart';

abstract class CheckoutState {
  const CheckoutState();
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutPassengerEntry extends CheckoutState {
  final FlightOffer? flightOffer;
  final HotelOffer? hotelOffer;
  final List<PassengerInput> passengers;
  final String contactEmail;
  final String contactPhone;

  const CheckoutPassengerEntry({
    this.flightOffer,
    this.hotelOffer,
    required this.passengers,
    required this.contactEmail,
    required this.contactPhone,
  });
}

class CheckoutPaymentReady extends CheckoutState {
  final FlightOffer? flightOffer;
  final HotelOffer? hotelOffer;
  final List<PassengerInput> passengers;
  final String contactEmail;
  final String contactPhone;
  final PaymentIntent paymentIntent;

  const CheckoutPaymentReady({
    this.flightOffer,
    this.hotelOffer,
    required this.passengers,
    required this.contactEmail,
    required this.contactPhone,
    required this.paymentIntent,
  });
}

class CheckoutProcessingPayment extends CheckoutState {
  final String statusMessage;
  const CheckoutProcessingPayment([this.statusMessage = 'Authorizing secure payment with bank...']);
}

class Checkout3DSChallengeRequired extends CheckoutState {
  final PaymentIntent paymentIntent;
  final TokenizedPaymentMethod paymentMethod;

  const Checkout3DSChallengeRequired({
    required this.paymentIntent,
    required this.paymentMethod,
  });
}

class CheckoutBookingSuccess extends CheckoutState {
  final Booking confirmedBooking;
  final String eTicketOrVoucherNumber;

  const CheckoutBookingSuccess({
    required this.confirmedBooking,
    required this.eTicketOrVoucherNumber,
  });
}

class CheckoutFailure extends CheckoutState {
  final String errorMessage;
  const CheckoutFailure(this.errorMessage);
}
