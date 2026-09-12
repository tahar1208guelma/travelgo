export interface FlightSegmentDto {
  airline: string;
  airlineCode: string;
  flightNumber: string;
  departureAirport: string;
  departureAirportCode: string;
  departureCity: string;
  departureTerminal?: string;
  departureDateTime: string;
  arrivalAirport: string;
  arrivalAirportCode: string;
  arrivalCity: string;
  arrivalTerminal?: string;
  arrivalDateTime: string;
  durationMinutes: number;
  cabinClass: string;
  aircraftType?: string;
  baggageAllowance?: string;
}

export interface FlightOfferRawDto {
  providerOfferId: string;
  providerCode: string;
  isDemo: boolean;
  validatingAirline: string;
  validatingAirlineCode: string;
  basePrice: number;
  taxes: number;
  currency: string;
  seatsRemaining: number;
  isRefundable: boolean;
  baggageSummary: string;
  priceLockExpiry: string;
  outboundSegments: FlightSegmentDto[];
  returnSegments?: FlightSegmentDto[];
}

export interface FlightSearchCriteria {
  originCode: string;
  destinationCode: string;
  departureDate: string;
  returnDate?: string;
  adults: number;
  children: number;
  infants: number;
  cabinClass: string; // 'Economy' | 'Premium Economy' | 'Business' | 'First'
  currency?: string;
}

export interface FlightBookingRequest {
  offerId: string;
  passengers: Array<{
    firstName: string;
    lastName: string;
    dateOfBirth: string;
    passportNumber?: string;
    passportExpiry?: string;
    nationality?: string;
    gender?: string;
  }>;
}

export interface FlightBookingResult {
  providerReference: string; // PNR
  ticketNumbers: Record<string, string>; // passengerName -> ticketNum
  isTicketIssued: boolean;
  status: 'confirmed' | 'pending' | 'failed';
  remarks?: string;
}

export interface IFlightProvider {
  readonly providerId: string;
  readonly providerName: string;
  readonly isDemo: boolean;

  searchFlights(criteria: FlightSearchCriteria): Promise<FlightOfferRawDto[]>;
  verifyPrice(offerId: string): Promise<{ isAvailable: boolean; currentBasePrice: number; currentTaxes: number }>;
  createBooking(request: FlightBookingRequest): Promise<FlightBookingResult>;
  cancelBooking(providerReference: string): Promise<{ isCancelled: boolean; refundEligible: boolean; cancellationFee: number }>;
}
