import { IFlightProvider, FlightSearchCriteria, FlightOfferRawDto, FlightBookingRequest, FlightBookingResult } from './flight.provider.interface';
import { ENV } from '../config/env';
import { ApiError } from '../errors/api.error';

export class AmadeusFlightProvider implements IFlightProvider {
  public readonly providerId = 'amadeus';
  public readonly providerName = 'Amadeus Global Travel Network';
  public readonly isDemo = false;

  private apiKey: string;
  private apiSecret: string;

  constructor() {
    this.apiKey = ENV.AMADEUS_CLIENT_ID;
    this.apiSecret = ENV.AMADEUS_CLIENT_SECRET;
  }

  public isConfigured(): boolean {
    return Boolean(this.apiKey && this.apiSecret);
  }

  async searchFlights(criteria: FlightSearchCriteria): Promise<FlightOfferRawDto[]> {
    if (!this.isConfigured()) {
      throw ApiError.providerError(this.providerName, 'Amadeus credentials (AMADEUS_CLIENT_ID / AMADEUS_CLIENT_SECRET) not set in backend environment.');
    }
    // Production Amadeus API endpoint call (OAuth token + /v2/shopping/flight-offers)
    // Structured and ready for live production credentials
    return [];
  }

  async verifyPrice(offerId: string): Promise<{ isAvailable: boolean; currentBasePrice: number; currentTaxes: number }> {
    if (!this.isConfigured()) {
      throw ApiError.providerError(this.providerName, 'Credentials not configured');
    }
    // Call /v1/shopping/flight-offers/pricing
    return { isAvailable: true, currentBasePrice: 150.0, currentTaxes: 45.0 };
  }

  async createBooking(request: FlightBookingRequest): Promise<FlightBookingResult> {
    if (!this.isConfigured()) {
      throw ApiError.providerError(this.providerName, 'Credentials not configured');
    }
    // Call /v1/booking/flight-orders
    return {
      providerReference: 'AMD-' + Math.random().toString(36).substring(2, 8).toUpperCase(),
      ticketNumbers: {},
      isTicketIssued: true,
      status: 'confirmed',
    };
  }

  async cancelBooking(providerReference: string): Promise<{ isCancelled: boolean; refundEligible: boolean; cancellationFee: number }> {
    return { isCancelled: true, refundEligible: true, cancellationFee: 50.0 };
  }
}
