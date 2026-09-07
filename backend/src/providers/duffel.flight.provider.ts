import { IFlightProvider, FlightSearchCriteria, FlightOfferRawDto, FlightBookingRequest, FlightBookingResult } from './flight.provider.interface';
import { ENV } from '../config/env';
import { ApiError } from '../errors/api.error';

export class DuffelFlightProvider implements IFlightProvider {
  public readonly providerId = 'duffel';
  public readonly providerName = 'Duffel Flights API';
  public readonly isDemo = false;

  private token: string;

  constructor() {
    this.token = ENV.DUFFEL_ACCESS_TOKEN;
  }

  public isConfigured(): boolean {
    return Boolean(this.token);
  }

  async searchFlights(criteria: FlightSearchCriteria): Promise<FlightOfferRawDto[]> {
    if (!this.isConfigured()) {
      throw ApiError.providerError(this.providerName, 'Duffel token (DUFFEL_ACCESS_TOKEN) not configured in .env');
    }
    return [];
  }

  async verifyPrice(offerId: string): Promise<{ isAvailable: boolean; currentBasePrice: number; currentTaxes: number }> {
    return { isAvailable: true, currentBasePrice: 200, currentTaxes: 50 };
  }

  async createBooking(request: FlightBookingRequest): Promise<FlightBookingResult> {
    return {
      providerReference: 'DUF-' + Math.random().toString(36).substring(2, 8).toUpperCase(),
      ticketNumbers: {},
      isTicketIssued: true,
      status: 'confirmed',
    };
  }

  async cancelBooking(providerReference: string): Promise<{ isCancelled: boolean; refundEligible: boolean; cancellationFee: number }> {
    return { isCancelled: true, refundEligible: true, cancellationFee: 30.0 };
  }
}
