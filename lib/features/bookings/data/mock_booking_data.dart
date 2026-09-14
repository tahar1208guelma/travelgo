import '../models/booking_document.dart';
import '../models/booking_model.dart';
import '../models/customer_info.dart';
import '../models/flight_booking_details.dart';
import '../models/hotel_booking_details.dart';
import '../models/price_breakdown.dart';

class MockBookingData {
  /// Standard Mock Flight Booking (TRV-2026-000001)
  static final Booking flightBooking = Booking(
    bookingId: 'BK-FLIGHT-001',
    bookingReference: 'TRV-2026-000001',
    bookingType: BookingType.flight,
    status: BookingStatus.confirmed,
    customer: const CustomerInfo(
      id: 'USR-TAHAR-01',
      fullName: 'Tahar Braknia',
      email: 'tahar.braknia@example.com',
      phone: '+213 555 123 456',
      passengers: [
        PassengerInfo(
          fullName: 'Tahar Braknia',
          passengerType: PassengerType.adult,
          seatNumber: '14A',
          ticketNumber: '082-2491029481',
          passportOrIdNumber: 'N10294810',
          nationality: 'Algerian',
        ),
      ],
    ),
    provider: 'Demo Airline',
    providerBookingReference: 'TG-PNR-8823',
    priceBreakdown: const PriceBreakdown(
      basePrice: 250.00,
      serviceFee: 1.00,
      taxes: 0.00,
      discount: 0.00,
      totalAmount: 251.00,
      currency: 'USD',
    ),
    flightDetails: FlightBookingDetails(
      airlineBookingReference: 'TG-PNR-8823',
      ticketNumber: '082-2491029481',
      cabinClass: 'Economy',
      baggageAllowance: '1 x 23kg Checked Bag + 1 x 7kg Cabin Bag',
      isDirect: true,
      passengers: const [
        PassengerInfo(
          fullName: 'Tahar Braknia',
          passengerType: PassengerType.adult,
          seatNumber: '14A',
          ticketNumber: '082-2491029481',
        ),
      ],
      segments: [
        FlightSegment(
          airline: 'Demo Airline',
          airlineCode: 'TG',
          flightNumber: 'TG100',
          departureAirport: 'Houari Boumediene Airport',
          departureAirportCode: 'ALG',
          departureCity: 'Algiers',
          departureTerminal: 'Terminal 1',
          departureDateTime: DateTime(2026, 9, 15, 10, 30),
          arrivalAirport: 'Istanbul Airport',
          arrivalAirportCode: 'IST',
          arrivalCity: 'Istanbul',
          arrivalTerminal: 'Main International',
          arrivalDateTime: DateTime(2026, 9, 15, 16, 0),
          flightDuration: '3h 30m',
          cabinClass: 'Economy',
          baggageAllowance: '1 x 23kg Checked Bag + 1 x 7kg Cabin Bag',
          aircraft: 'Airbus A321neo',
          seatNumber: '14A',
        ),
      ],
    ),
    createdAt: DateTime(2026, 8, 20, 14, 15),
    document: BookingDocument(
      documentId: 'DOC-2026-000001',
      documentTitle: 'Travel Booking Confirmation',
      bookingReference: 'TRV-2026-000001',
      issuedAt: DateTime(2026, 8, 20, 14, 16),
      qrData: 'TRV-2026-000001',
      isDemo: true,
      termsAndConditions:
          'DEMO / TEST BOOKING — Not valid for actual boarding. In production, this document confirms reservation with Demo Airline. Check-in closes 60 minutes prior to scheduled departure.',
      supportEmail: 'support@travelgo.com',
      supportPhone: '+1 (800) 555-TRVL',
      supportWebsite: 'https://travelgo.example',
    ),
  );

  /// Standard Mock Hotel Voucher (TRV-2026-000002)
  static final Booking hotelBooking = Booking(
    bookingId: 'BK-HOTEL-002',
    bookingReference: 'TRV-2026-000002',
    bookingType: BookingType.hotel,
    status: BookingStatus.confirmed,
    customer: const CustomerInfo(
      id: 'USR-TAHAR-01',
      fullName: 'Tahar Braknia',
      email: 'tahar.braknia@example.com',
      phone: '+213 555 123 456',
      passengers: [
        PassengerInfo(
          fullName: 'Tahar Braknia',
          passengerType: PassengerType.adult,
        ),
      ],
    ),
    provider: 'Bosphorus Grand Palace Hotel',
    providerBookingReference: 'HTL-BOS-9941',
    priceBreakdown: const PriceBreakdown(
      basePrice: 650.00,
      serviceFee: 1.00,
      taxes: 0.00,
      discount: 0.00,
      totalAmount: 651.00,
      currency: 'USD',
    ),
    hotelDetails: HotelBookingDetails(
      hotelConfirmationNumber: 'HTL-BOS-9941',
      hotelName: 'Bosphorus Grand Palace Hotel',
      hotelAddress: 'Ciragan Caddesi No. 32, Besiktas, 34349 Istanbul',
      hotelCity: 'Istanbul',
      hotelCountry: 'Turkey',
      hotelRating: 4.9,
      hotelPhone: '+90 212 555 0199',
      hotelEmail: 'reservations@bosphorusgrand.com',
      checkInDate: DateTime(2026, 9, 15),
      checkInTime: '14:00',
      checkOutDate: DateTime(2026, 9, 20),
      checkOutTime: '12:00',
      numberOfNights: 5,
      numberOfGuests: 2,
      numberOfRooms: 1,
      roomType: 'Deluxe King Sea View Suite',
      mealPlan: 'Full Turkish Breakfast Included',
      cancellationPolicy: 'Free cancellation until 14 September 2026, 14:00 (24h before check-in)',
      rooms: const [
        HotelRoomDetails(
          roomType: 'Deluxe King Sea View Suite',
          numberOfGuests: 2,
          bedType: '1 King Bed',
          mealPlan: 'Full Turkish Breakfast Included',
          description: 'Spacious 45m² room with panoramic Bosphorus views, marble bathroom, and espresso machine.',
          pricePerNightUSD: 130.00,
        ),
      ],
      specialRequests: 'High floor, quiet room requested.',
    ),
    createdAt: DateTime(2026, 8, 21, 10, 45),
    document: BookingDocument(
      documentId: 'DOC-2026-000002',
      documentTitle: 'Hotel Voucher',
      bookingReference: 'TRV-2026-000002',
      issuedAt: DateTime(2026, 8, 21, 10, 46),
      qrData: 'TRV-2026-000002',
      isDemo: true,
      termsAndConditions:
          'DEMO / TEST BOOKING — Present this voucher with a valid photo ID upon arrival. City taxes may be collected directly by the hotel if applicable.',
      supportEmail: 'support@travelgo.com',
      supportPhone: '+1 (800) 555-TRVL',
      supportWebsite: 'https://travelgo.example',
    ),
  );

  /// Standard Mock Combined Flight + Hotel Booking (TRV-2026-000003)
  static final Booking combinedBooking = Booking(
    bookingId: 'BK-COMBO-003',
    bookingReference: 'TRV-2026-000003',
    bookingType: BookingType.flightAndHotel,
    status: BookingStatus.confirmed,
    customer: const CustomerInfo(
      id: 'USR-TAHAR-01',
      fullName: 'Tahar Braknia',
      email: 'tahar.braknia@example.com',
      phone: '+213 555 123 456',
      passengers: [
        PassengerInfo(
          fullName: 'Tahar Braknia',
          passengerType: PassengerType.adult,
          seatNumber: '12C',
          ticketNumber: '082-9918237411',
        ),
      ],
    ),
    provider: 'TRAVELGO Vacations Package',
    providerBookingReference: 'PKG-IST-7712',
    priceBreakdown: const PriceBreakdown(
      basePrice: 890.00,
      serviceFee: 1.00,
      taxes: 0.00,
      discount: 0.00,
      totalAmount: 891.00,
      currency: 'USD',
    ),
    flightDetails: FlightBookingDetails(
      airlineBookingReference: 'TG-PNR-8823',
      ticketNumber: '082-9918237411',
      cabinClass: 'Economy',
      baggageAllowance: '1 x 23kg Checked Bag',
      isDirect: true,
      passengers: const [
        PassengerInfo(
          fullName: 'Tahar Braknia',
          passengerType: PassengerType.adult,
          seatNumber: '12C',
        ),
      ],
      segments: [
        FlightSegment(
          airline: 'Demo Airline',
          flightNumber: 'TG100',
          departureAirport: 'Houari Boumediene Airport',
          departureAirportCode: 'ALG',
          departureCity: 'Algiers',
          departureDateTime: DateTime(2026, 9, 15, 10, 30),
          arrivalAirport: 'Istanbul Airport',
          arrivalAirportCode: 'IST',
          arrivalCity: 'Istanbul',
          arrivalDateTime: DateTime(2026, 9, 15, 16, 0),
          flightDuration: '3h 30m',
          cabinClass: 'Economy',
        ),
      ],
    ),
    hotelDetails: HotelBookingDetails(
      hotelConfirmationNumber: 'HTL-BOS-9941',
      hotelName: 'Bosphorus Grand Palace Hotel',
      hotelAddress: 'Ciragan Caddesi No. 32, Besiktas, Istanbul',
      checkInDate: DateTime(2026, 9, 15),
      checkOutDate: DateTime(2026, 9, 20),
      numberOfNights: 5,
      numberOfGuests: 2,
      roomType: 'Deluxe King Sea View Suite',
      mealPlan: 'Full Breakfast Included',
      cancellationPolicy: 'Free cancellation until 14 September 2026, 14:00',
    ),
    createdAt: DateTime(2026, 8, 22, 16, 20),
    document: BookingDocument(
      documentId: 'DOC-2026-000003',
      documentTitle: 'Travel Booking Confirmation & Voucher',
      bookingReference: 'TRV-2026-000003',
      issuedAt: DateTime(2026, 8, 22, 16, 21),
      qrData: 'TRV-2026-000003',
      isDemo: true,
      termsAndConditions:
          'DEMO / TEST BOOKING — Combined flight and accommodation booking confirmation. Present to airline counter and hotel front desk.',
    ),
  );

  /// Mock Cancelled Booking (TRV-2026-000004)
  static final Booking cancelledBooking = Booking(
    bookingId: 'BK-CANCEL-004',
    bookingReference: 'TRV-2026-000004',
    bookingType: BookingType.flight,
    status: BookingStatus.cancelled,
    customer: const CustomerInfo(
      id: 'USR-TAHAR-01',
      fullName: 'Tahar Braknia',
      email: 'tahar.braknia@example.com',
      phone: '+213 555 123 456',
    ),
    provider: 'Air France',
    providerBookingReference: 'AF-CAN-1234',
    priceBreakdown: const PriceBreakdown(
      basePrice: 320.00,
      serviceFee: 1.00,
      totalAmount: 321.00,
      currency: 'USD',
    ),
    flightDetails: FlightBookingDetails(
      airlineBookingReference: 'AF-CAN-1234',
      segments: [
        FlightSegment(
          airline: 'Air France',
          flightNumber: 'AF1450',
          departureAirport: 'Charles de Gaulle Airport',
          departureAirportCode: 'CDG',
          departureDateTime: DateTime(2026, 7, 10, 08, 0),
          arrivalAirport: 'Dubai International Airport',
          arrivalAirportCode: 'DXB',
          arrivalDateTime: DateTime(2026, 7, 10, 17, 30),
          flightDuration: '6h 30m',
        ),
      ],
    ),
    createdAt: DateTime(2026, 6, 1, 11, 0),
    cancellationReason: 'Trip cancelled by customer request on June 15, 2026.',
    document: BookingDocument(
      documentId: 'DOC-2026-000004',
      documentTitle: 'Cancelled Booking Record',
      bookingReference: 'TRV-2026-000004',
      issuedAt: DateTime(2026, 6, 1, 11, 1),
      qrData: 'TRV-2026-000004',
      isDemo: true,
    ),
  );

  /// Mock Multi-Segment Connecting Flight Booking (for PDF Multi-Segment testing)
  static final Booking multiSegmentBooking = Booking(
    bookingId: 'BK-MULTI-005',
    bookingReference: 'TRV-2026-000005',
    bookingType: BookingType.flight,
    status: BookingStatus.confirmed,
    customer: const CustomerInfo(
      id: 'USR-TAHAR-01',
      fullName: 'Tahar Braknia',
      email: 'tahar.braknia@example.com',
      phone: '+213 555 123 456',
      passengers: [
        PassengerInfo(
          fullName: 'Tahar Braknia',
          passengerType: PassengerType.adult,
          seatNumber: '12B',
          ticketNumber: '082-9988112233',
        ),
        PassengerInfo(
          fullName: 'Amira Braknia (Very Long Family Member Name For Testing Robustness)',
          passengerType: PassengerType.adult,
          seatNumber: '12C',
          ticketNumber: '082-9988112234',
        ),
      ],
    ),
    provider: 'Global Airlines',
    priceBreakdown: const PriceBreakdown(
      basePrice: 580.00,
      serviceFee: 1.00,
      taxes: 45.00,
      totalAmount: 626.00,
      currency: 'USD',
    ),
    flightDetails: FlightBookingDetails(
      airlineBookingReference: 'GLB-PNR-4421',
      cabinClass: 'Economy',
      baggageAllowance: '2 x 23kg Checked Bags',
      isDirect: false,
      passengers: const [
        PassengerInfo(
          fullName: 'Tahar Braknia',
          passengerType: PassengerType.adult,
          seatNumber: '12B',
        ),
        PassengerInfo(
          fullName: 'Amira Braknia (Very Long Family Member Name For Testing Robustness)',
          passengerType: PassengerType.adult,
          seatNumber: '12C',
        ),
      ],
      segments: [
        FlightSegment(
          airline: 'Global Airlines',
          flightNumber: 'GA201',
          departureAirport: 'Houari Boumediene Airport',
          departureAirportCode: 'ALG',
          departureCity: 'Algiers',
          departureDateTime: DateTime(2026, 10, 5, 08, 0),
          arrivalAirport: 'Rome Fiumicino Airport',
          arrivalAirportCode: 'FCO',
          arrivalCity: 'Rome',
          arrivalDateTime: DateTime(2026, 10, 5, 11, 0),
          flightDuration: '2h 00m',
          seatNumber: '12B / 12C',
        ),
        FlightSegment(
          airline: 'Global Airlines',
          flightNumber: 'GA550',
          departureAirport: 'Rome Fiumicino Airport',
          departureAirportCode: 'FCO',
          departureCity: 'Rome',
          departureDateTime: DateTime(2026, 10, 5, 14, 30),
          arrivalAirport: 'Tokyo Haneda Airport',
          arrivalAirportCode: 'HND',
          arrivalCity: 'Tokyo',
          arrivalDateTime: DateTime(2026, 10, 6, 09, 45),
          flightDuration: '12h 15m',
          seatNumber: '24J / 24K',
        ),
      ],
    ),
    createdAt: DateTime(2026, 8, 25, 09, 30),
    document: BookingDocument(
      documentId: 'DOC-2026-000005',
      documentTitle: 'Travel Booking Confirmation',
      bookingReference: 'TRV-2026-000005',
      issuedAt: DateTime(2026, 8, 25, 09, 31),
      qrData: 'TRV-2026-000005',
      isDemo: true,
    ),
  );

  /// Default mock bookings list
  static List<Booking> get defaultBookings => [
        flightBooking,
        hotelBooking,
        combinedBooking,
        cancelledBooking,
        multiSegmentBooking,
      ];
}
