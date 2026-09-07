import '../models/booking.dart';
import '../models/booking_status.dart';
import '../models/booking_type.dart';
import '../models/flight_booking_details.dart';
import '../models/hotel_booking_details.dart';
import '../models/passenger.dart';
import '../models/price_breakdown.dart';

class MockBookingsData {
  /// Primary mock booking defined in Requirement 17
  static final Booking flightBookingMock = Booking(
    bookingId: 'BK-FLIGHT-001',
    bookingReference: 'TRV-2026-000001',
    bookingType: BookingType.flight,
    status: BookingStatus.confirmed,
    customerName: 'Tahar Braknia',
    customerEmail: 'tahar.braknia@example.com',
    customerPhone: '+213 555 012 345',
    provider: 'TRAVELGO Air Direct',
    providerBookingReference: 'TG-PNR-88201',
    createdAt: DateTime(2026, 8, 20, 14, 15),
    isDemo: true,
    price: const PriceBreakdown(
      basePrice: 250.00,
      serviceFee: 1.00,
      currency: 'USD',
      totalAmount: 251.00,
    ),
    flightDetails: FlightBookingDetails(
      airlineBookingReference: 'TG-PNR-88201',
      ticketNumbers: {'PAX-001': '074-2458991201'},
      passengers: const [
        Passenger(
          id: 'PAX-001',
          fullName: 'Tahar Braknia',
          passengerType: PassengerType.adult,
          nationality: 'Algerian',
          seatNumber: '14B',
        ),
      ],
      segments: [
        FlightSegment(
          airline: 'Demo Airline',
          flightNumber: 'TG100',
          departureAirport: 'Houari Boumediene Airport',
          departureAirportCode: 'ALG',
          departureCity: 'Algiers',
          departureTerminal: 'Terminal 1',
          departureDateTime: DateTime(2026, 9, 15, 10, 30),
          arrivalAirport: 'Istanbul Airport',
          arrivalAirportCode: 'IST',
          arrivalCity: 'Istanbul',
          arrivalTerminal: 'International',
          arrivalDateTime: DateTime(2026, 9, 15, 16, 00),
          duration: const Duration(hours: 5, minutes: 30),
          cabinClass: 'Economy',
          baggageAllowance: '1 x 23 kg checked, 1 x 8 kg cabin',
          aircraftType: 'Boeing 737-800',
        ),
      ],
    ),
  );

  /// Hotel Voucher Mock
  static final Booking hotelBookingMock = Booking(
    bookingId: 'BK-HOTEL-002',
    bookingReference: 'TRV-2026-000002',
    bookingType: BookingType.hotel,
    status: BookingStatus.confirmed,
    customerName: 'Tahar Braknia',
    customerEmail: 'tahar.braknia@example.com',
    customerPhone: '+213 555 012 345',
    provider: 'TRAVELGO Stays Network',
    providerBookingReference: 'HTL-CONF-9923',
    createdAt: DateTime(2026, 8, 22, 11, 0),
    isDemo: true,
    price: const PriceBreakdown(
      basePrice: 650.00,
      serviceFee: null, // No service fee invented
      currency: 'USD',
      totalAmount: 650.00,
    ),
    hotelDetails: HotelBookingDetails(
      hotelName: 'Bosphorus View Grand Hotel',
      hotelAddress: 'Ciragan Cad. No: 32, Besiktas',
      hotelCity: 'Istanbul',
      hotelCountry: 'Turkey',
      hotelPhone: '+90 212 555 0199',
      hotelEmail: 'reservations@bosphorusgrand.example',
      checkInDate: DateTime(2026, 9, 15),
      checkOutDate: DateTime(2026, 9, 20),
      numberOfNights: 5,
      numberOfGuests: 2,
      guestName: 'Tahar Braknia',
      mealPlan: 'Bed & Breakfast (Buffet included)',
      cancellationPolicy: 'Free cancellation until 13 Sep 2026, 23:59. Non-refundable afterwards.',
      hotelConfirmationNumber: 'HTL-CONF-9923',
      specialRequests: 'High floor room facing the Bosphorus Strait if available.',
      rooms: const [
        HotelRoom(
          roomType: 'Deluxe Sea View King Room',
          numberOfGuests: 2,
          bedType: '1 King Bed',
          description: 'Spacious 42 sqm room with balcony overlooking the Bosphorus, complimentary Wi-Fi and marble bathroom.',
        ),
      ],
    ),
  );

  /// Combined Flight + Hotel Mock
  static final Booking combinedBookingMock = Booking(
    bookingId: 'BK-COMBO-003',
    bookingReference: 'TRV-2026-000003',
    bookingType: BookingType.flightAndHotel,
    status: BookingStatus.confirmed,
    customerName: 'Tahar Braknia',
    customerEmail: 'tahar.braknia@example.com',
    provider: 'TRAVELGO Package Direct',
    providerBookingReference: 'PKG-TRV-7711',
    createdAt: DateTime(2026, 8, 25, 9, 45),
    isDemo: true,
    price: const PriceBreakdown(
      basePrice: 500.00,
      serviceFee: 2.00,
      currency: 'USD',
      totalAmount: 502.00,
    ),
    flightDetails: FlightBookingDetails(
      airlineBookingReference: 'AF-PNR-3021',
      ticketNumbers: {'PAX-001': '057-9928172635'},
      passengers: const [
        Passenger(
          id: 'PAX-001',
          fullName: 'Tahar Braknia',
          passengerType: PassengerType.adult,
          nationality: 'Algerian',
          seatNumber: '21A',
        ),
      ],
      segments: [
        FlightSegment(
          airline: 'Air France Demo',
          flightNumber: 'AF1854',
          departureAirport: 'Charles de Gaulle Airport',
          departureAirportCode: 'CDG',
          departureCity: 'Paris',
          departureTerminal: 'Terminal 2E',
          departureDateTime: DateTime(2026, 10, 5, 14, 20),
          arrivalAirport: 'Houari Boumediene Airport',
          arrivalAirportCode: 'ALG',
          arrivalCity: 'Algiers',
          arrivalTerminal: 'Terminal 1',
          arrivalDateTime: DateTime(2026, 10, 5, 16, 40),
          duration: const Duration(hours: 2, minutes: 20),
          cabinClass: 'Premium Economy',
          baggageAllowance: '2 x 23 kg checked, 1 x 12 kg cabin',
        ),
      ],
    ),
    hotelDetails: HotelBookingDetails(
      hotelName: 'El Aurassi Hotel',
      hotelAddress: '2 Boulevard Frantz Fanon, Les Tagarins',
      hotelCity: 'Algiers',
      hotelCountry: 'Algeria',
      hotelPhone: '+213 21 74 82 52',
      hotelEmail: 'contact@elaurassi.example',
      checkInDate: DateTime(2026, 10, 5),
      checkOutDate: DateTime(2026, 10, 10),
      numberOfNights: 5,
      numberOfGuests: 1,
      guestName: 'Tahar Braknia',
      mealPlan: 'Half Board (Breakfast & Dinner)',
      cancellationPolicy: 'Free cancellation until 48 hours prior to check-in.',
      hotelConfirmationNumber: 'AUR-2026-4481',
      rooms: const [
        HotelRoom(
          roomType: 'Executive Suite Bay View',
          numberOfGuests: 1,
          bedType: '1 King Bed',
          description: 'Panoramic view over the Bay of Algiers.',
        ),
      ],
    ),
  );

  /// Cancelled Booking Mock
  static final Booking cancelledBookingMock = Booking(
    bookingId: 'BK-FLIGHT-004',
    bookingReference: 'TRV-2026-000004',
    bookingType: BookingType.flight,
    status: BookingStatus.cancelled,
    customerName: 'Tahar Braknia',
    customerEmail: 'tahar.braknia@example.com',
    provider: 'TRAVELGO Air Direct',
    createdAt: DateTime(2026, 8, 10, 8, 30),
    isDemo: true,
    price: const PriceBreakdown(
      basePrice: 420.00,
      currency: 'USD',
      totalAmount: 420.00,
    ),
    flightDetails: FlightBookingDetails(
      passengers: const [
        Passenger(id: 'PAX-001', fullName: 'Tahar Braknia'),
      ],
      segments: [
        FlightSegment(
          airline: 'British Airways Demo',
          flightNumber: 'BA178',
          departureAirport: 'Heathrow Airport',
          departureAirportCode: 'LHR',
          departureCity: 'London',
          departureDateTime: DateTime(2026, 11, 1, 9, 0),
          arrivalAirport: 'John F. Kennedy Intl',
          arrivalAirportCode: 'JFK',
          arrivalCity: 'New York',
          arrivalDateTime: DateTime(2026, 11, 1, 12, 15),
          duration: const Duration(hours: 7, minutes: 15),
        ),
      ],
    ),
  );

  /// Failed Booking Mock
  static final Booking failedBookingMock = Booking(
    bookingId: 'BK-HOTEL-005',
    bookingReference: 'TRV-2026-000005',
    bookingType: BookingType.hotel,
    status: BookingStatus.failed,
    customerName: 'Tahar Braknia',
    customerEmail: 'tahar.braknia@example.com',
    provider: 'TRAVELGO Stays Network',
    createdAt: DateTime(2026, 8, 28, 16, 20),
    isDemo: true,
    notes: 'Provider reservation timed out. No charge was processed.',
    price: const PriceBreakdown(
      basePrice: 180.00,
      currency: 'USD',
      totalAmount: 180.00,
    ),
    hotelDetails: HotelBookingDetails(
      hotelName: 'Tokyo Bay Luxury Resort',
      hotelAddress: '1-1-1 Maihama, Urayasu',
      hotelCity: 'Tokyo',
      hotelCountry: 'Japan',
      checkInDate: DateTime(2026, 12, 10),
      checkOutDate: DateTime(2026, 12, 12),
      numberOfNights: 2,
      numberOfGuests: 1,
      guestName: 'Tahar Braknia',
      mealPlan: 'Room Only',
      cancellationPolicy: 'Non-refundable',
      rooms: const [
        HotelRoom(roomType: 'Standard Room', numberOfGuests: 1),
      ],
    ),
  );

  static List<Booking> get allMockBookings => [
    flightBookingMock,
    hotelBookingMock,
    combinedBookingMock,
    cancelledBookingMock,
    failedBookingMock,
  ];
}
