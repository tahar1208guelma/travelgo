import 'dart:math';
import '../../../core/architecture/bloc_base.dart';
import '../../bookings/data/mock_bookings_data.dart';
import '../../bookings/models/booking.dart';
import '../../bookings/models/booking_status.dart';
import '../../bookings/models/booking_type.dart';
import '../../bookings/models/flight_booking_details.dart';
import '../../bookings/models/hotel_booking_details.dart';
import '../../flights/models/flight_offer.dart';
import '../../hotels/models/hotel_offer.dart';
import '../models/passenger_input.dart';
import '../models/payment_intent.dart';
import '../models/payment_method.dart';
import '../services/payment_gateway_service.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final PaymentGatewayService paymentService;

  FlightOffer? _currentFlightOffer;
  HotelOffer? _currentHotelOffer;
  List<PassengerInput> _currentPassengers = [];
  String _contactEmail = '';
  String _contactPhone = '';
  PaymentIntent? _currentPaymentIntent;
  TokenizedPaymentMethod? _currentPaymentMethod;

  TokenizedPaymentMethod? get currentPaymentMethod => _currentPaymentMethod;

  CheckoutBloc({required this.paymentService}) : super(const CheckoutInitial());

  @override
  void onEvent(CheckoutEvent event) async {
    if (event is StartFlightCheckout) {
      _currentFlightOffer = event.offer;
      _currentHotelOffer = null;
      _currentPassengers = [
        PassengerInput(
          firstName: 'Tahar',
          lastName: 'Braknia',
          email: 'tahar.braknia@example.com',
          phone: '+213-550-123456',
          passportNumber: 'N10984728',
          dateOfBirth: DateTime(1992, 5, 14),
        ),
      ];
      _contactEmail = 'tahar.braknia@example.com';
      _contactPhone = '+213-550-123456';

      emit(CheckoutPassengerEntry(
        flightOffer: _currentFlightOffer,
        passengers: _currentPassengers,
        contactEmail: _contactEmail,
        contactPhone: _contactPhone,
      ));
    } else if (event is StartHotelCheckout) {
      _currentFlightOffer = null;
      _currentHotelOffer = event.hotel;
      _currentPassengers = [
        PassengerInput(
          firstName: event.leadGuestName.split(' ').first,
          lastName: event.leadGuestName.split(' ').length > 1
              ? event.leadGuestName.split(' ').sublist(1).join(' ')
              : 'Guest',
          email: event.leadGuestEmail,
          phone: '+213-550-123456',
          passportNumber: 'N10984728',
          dateOfBirth: DateTime(1992, 5, 14),
        ),
      ];
      _contactEmail = event.leadGuestEmail;
      _contactPhone = '+213-550-123456';

      emit(CheckoutPassengerEntry(
        hotelOffer: _currentHotelOffer,
        passengers: _currentPassengers,
        contactEmail: _contactEmail,
        contactPhone: _contactPhone,
      ));
    } else if (event is SubmitTravelerDetails) {
      await _handleSubmitTravelerDetails(event);
    } else if (event is ProcessTokenizedPayment) {
      await _handleProcessTokenizedPayment(event);
    } else if (event is Complete3DSChallenge) {
      await _handleComplete3DSChallenge();
    } else if (event is ResetCheckout) {
      emit(const CheckoutInitial());
    }
  }

  Future<void> _handleSubmitTravelerDetails(SubmitTravelerDetails event) async {
    _currentPassengers = event.passengers;
    _contactEmail = event.contactEmail;
    _contactPhone = event.contactPhone;

    emit(const CheckoutProcessingPayment('Initializing secure payment session...'));

    try {
      final amount = _currentFlightOffer?.price.totalAmount ?? _currentHotelOffer?.price.totalAmount ?? 100.0;
      final currency = _currentFlightOffer?.price.currency ?? _currentHotelOffer?.price.currency ?? 'USD';
      final ref = 'TRV-2026-${Random().nextInt(899999) + 100000}';

      _currentPaymentIntent = await paymentService.createPaymentIntent(
        amount: amount,
        currency: currency,
        bookingReference: ref,
      );

      emit(CheckoutPaymentReady(
        flightOffer: _currentFlightOffer,
        hotelOffer: _currentHotelOffer,
        passengers: _currentPassengers,
        contactEmail: _contactEmail,
        contactPhone: _contactPhone,
        paymentIntent: _currentPaymentIntent!,
      ));
    } catch (e) {
      emit(CheckoutFailure('Failed to initialize secure checkout: $e'));
    }
  }

  Future<void> _handleProcessTokenizedPayment(ProcessTokenizedPayment event) async {
    if (_currentPaymentIntent == null) {
      emit(const CheckoutFailure('Payment intent expired. Please restart checkout.'));
      return;
    }

    _currentPaymentMethod = event.paymentMethod;
    emit(const CheckoutProcessingPayment('Processing tokenized payment & contacting issuer bank...'));

    try {
      final updatedIntent = await paymentService.confirmPayment(
        intent: _currentPaymentIntent!,
        paymentMethod: event.paymentMethod,
        idempotencyKey: 'PAY-${_currentPaymentIntent!.id}',
      );

      _currentPaymentIntent = updatedIntent;

      if (updatedIntent.requires3DSChallenge) {
        emit(Checkout3DSChallengeRequired(
          paymentIntent: updatedIntent,
          paymentMethod: event.paymentMethod,
        ));
      } else {
        await _issueConfirmedBooking();
      }
    } catch (e) {
      emit(CheckoutFailure('Payment failed: $e'));
    }
  }

  Future<void> _handleComplete3DSChallenge() async {
    if (_currentPaymentIntent == null) return;

    emit(const CheckoutProcessingPayment('Verifying 3-D Secure OTP challenge with bank...'));

    try {
      final verifiedIntent = await paymentService.complete3DSecureChallenge(
        intent: _currentPaymentIntent!,
      );
      _currentPaymentIntent = verifiedIntent;
      await _issueConfirmedBooking();
    } catch (e) {
      emit(CheckoutFailure('3-D Secure verification failed: $e'));
    }
  }

  Future<void> _issueConfirmedBooking() async {
    emit(const CheckoutProcessingPayment('Issuing official airline PNR & luxury voucher...'));
    await Future.delayed(const Duration(milliseconds: 300));

    final randomRefNum = Random().nextInt(899999) + 100000;
    final bookingRef = 'TRV-2026-$randomRefNum';
    final leadPassenger = _currentPassengers.isNotEmpty
        ? _currentPassengers.first
        : PassengerInput(
            firstName: 'Tahar',
            lastName: 'Braknia',
            email: _contactEmail,
            phone: _contactPhone,
            passportNumber: 'N10984728',
            dateOfBirth: DateTime(1992, 5, 14),
          );

    final String ticketOrVoucher;
    final Booking booking;

    if (_currentFlightOffer != null) {
      final offer = _currentFlightOffer!;
      final pnr = '${offer.validatingAirlineCode}-${Random().nextInt(89999) + 10000}';
      ticketOrVoucher = '074-${Random().nextInt(899999999) + 100000000}';

      final passengersList = _currentPassengers.asMap().entries.map((entry) {
        return entry.value.toPassenger('P-${entry.key + 1}', seatNumber: '14A');
      }).toList();

      booking = Booking(
        bookingId: 'BK-FL-$randomRefNum',
        bookingReference: bookingRef,
        bookingType: BookingType.flight,
        status: BookingStatus.confirmed,
        customerName: leadPassenger.fullName,
        customerEmail: _contactEmail,
        customerPhone: _contactPhone,
        provider: offer.validatingAirline,
        providerBookingReference: pnr,
        createdAt: DateTime.now(),
        price: offer.price,
        flightDetails: FlightBookingDetails(
          airlineBookingReference: pnr,
          passengers: passengersList,
          segments: offer.outboundSegments,
          ticketNumbers: {
            if (passengersList.isNotEmpty) passengersList.first.id: ticketOrVoucher,
          },
        ),
      );
    } else if (_currentHotelOffer != null) {
      final hotel = _currentHotelOffer!;
      final confNum = 'HTL-CONF-$randomRefNum';
      ticketOrVoucher = confNum;

      booking = Booking(
        bookingId: 'BK-HTL-$randomRefNum',
        bookingReference: bookingRef,
        bookingType: BookingType.hotel,
        status: BookingStatus.confirmed,
        customerName: leadPassenger.fullName,
        customerEmail: _contactEmail,
        customerPhone: _contactPhone,
        provider: 'TRAVELGO Luxury Stays',
        providerBookingReference: confNum,
        createdAt: DateTime.now(),
        price: hotel.price,
        hotelDetails: HotelBookingDetails(
          hotelName: hotel.name,
          hotelAddress: hotel.address,
          hotelCity: hotel.city,
          hotelCountry: hotel.country,
          checkInDate: DateTime.now().add(const Duration(days: 14)),
          checkOutDate: DateTime.now().add(const Duration(days: 19)),
          numberOfNights: 5,
          numberOfGuests: _currentPassengers.length,
          guestName: leadPassenger.fullName,
          hotelConfirmationNumber: confNum,
          mealPlan: hotel.mealPlan,
          cancellationPolicy: hotel.cancellationPolicy,
          rooms: [hotel.primaryRoom],
        ),
      );
    } else {
      booking = MockBookingsData.flightBookingMock;
      ticketOrVoucher = '074-998877665';
    }

    emit(CheckoutBookingSuccess(
      confirmedBooking: booking,
      eTicketOrVoucherNumber: ticketOrVoucher,
    ));
  }
}
