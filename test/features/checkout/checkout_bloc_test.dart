import 'package:flutter_test/flutter_test.dart';
import 'package:travelgo/core/network/api_client.dart';
import 'package:travelgo/features/bookings/models/booking_status.dart';
import 'package:travelgo/features/bookings/models/flight_booking_details.dart';
import 'package:travelgo/features/bookings/models/price_breakdown.dart';
import 'package:travelgo/features/checkout/bloc/checkout_bloc.dart';
import 'package:travelgo/features/checkout/bloc/checkout_event.dart';
import 'package:travelgo/features/checkout/bloc/checkout_state.dart';
import 'package:travelgo/features/checkout/models/passenger_input.dart';
import 'package:travelgo/features/checkout/models/payment_method.dart';
import 'package:travelgo/features/checkout/services/payment_gateway_service.dart';
import 'package:travelgo/features/flights/models/flight_offer.dart';

void main() {
  group('CheckoutBloc Complete Order & 3DS Lifecycle Tests', () {
    late CheckoutBloc bloc;
    late PaymentGatewayService paymentService;

    final mockOffer = FlightOffer(
      offerId: 'FL-TEST-101',
      validatingAirline: 'Air Algerie',
      validatingAirlineCode: 'AH',
      price: PriceBreakdown.calculateWithTravelGoFee(basePrice: 250.0),
      priceLockExpiry: DateTime.now().add(const Duration(minutes: 15)),
      outboundSegments: [
        FlightSegment(
          airline: 'Air Algerie',
          flightNumber: 'AH1000',
          departureAirport: 'Houari Boumediene',
          departureAirportCode: 'ALG',
          departureDateTime: DateTime(2026, 9, 20, 8, 0),
          arrivalAirport: 'Istanbul Airport',
          arrivalAirportCode: 'IST',
          arrivalDateTime: DateTime(2026, 9, 20, 13, 30),
          duration: const Duration(hours: 3, minutes: 30),
        ),
      ],
    );

    setUp(() {
      paymentService = PaymentGatewayServiceImpl(apiClient: ApiClient());
      bloc = CheckoutBloc(paymentService: paymentService);
    });

    tearDown(() {
      bloc.dispose();
    });

    test('Initial state is CheckoutInitial', () {
      expect(bloc.state, isA<CheckoutInitial>());
    });

    test('Full Flight Checkout Flow: Entry -> Payment Ready -> 3DS Challenge -> Success', () async {
      final states = <CheckoutState>[];
      final sub = bloc.stream.listen(states.add);

      // Step 1: Start checkout
      bloc.add(StartFlightCheckout(mockOffer));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state, isA<CheckoutPassengerEntry>());

      // Step 2: Submit traveler info
      final p = PassengerInput(
        firstName: 'Tahar',
        lastName: 'Braknia',
        email: 'tahar@example.com',
        phone: '+213-550-123456',
        passportNumber: 'N10984728',
        dateOfBirth: DateTime(1992, 5, 14),
      );

      final readyFuture = bloc.stream.firstWhere((s) => s is CheckoutPaymentReady);
      bloc.add(SubmitTravelerDetails(
        passengers: [p],
        contactEmail: 'tahar@example.com',
        contactPhone: '+213-550-123456',
      ));

      final readyState = await readyFuture as CheckoutPaymentReady;
      expect(readyState.paymentIntent.amount, equals(mockOffer.price.totalAmount));

      // Step 3: Process tokenized payment method (triggers 3DS2 challenge)
      const token = TokenizedPaymentMethod(
        paymentToken: 'pm_tok_test_4242',
        cardBrand: 'Visa',
        last4: '4242',
        expiryMonth: '12',
        expiryYear: '28',
        cardholderName: 'Tahar Braknia',
        requires3DS: true,
      );

      final challengeFuture = bloc.stream.firstWhere((s) => s is Checkout3DSChallengeRequired);
      bloc.add(const ProcessTokenizedPayment(token));
      await challengeFuture;

      // Step 4: Complete 3DS challenge OTP
      final successFuture = bloc.stream.firstWhere((s) => s is CheckoutBookingSuccess);
      bloc.add(const Complete3DSChallenge());
      final successState = await successFuture as CheckoutBookingSuccess;
      expect(successState.confirmedBooking.status, equals(BookingStatus.confirmed));
      expect(successState.confirmedBooking.customerName, equals('Tahar Braknia'));
      expect(successState.confirmedBooking.price.totalAmount, equals(mockOffer.price.totalAmount));
      expect(successState.eTicketOrVoucherNumber, isNotEmpty);
      expect(successState.confirmedBooking.flightDetails?.airlineBookingReference, isNotNull);

      await sub.cancel();
    });
  });
}
