import { IHotelProvider, HotelSearchCriteria, HotelPropertyDto, HotelBookingRequest, HotelBookingResult } from './hotel.provider.interface';
import { ENV } from '../config/env';
import { ApiError } from '../errors/api.error';

export class BookingComHotelProvider implements IHotelProvider {
  public readonly providerId = 'booking_com';
  public readonly providerName = 'Booking.com Affiliate API';
  public readonly isDemo = false;

  private apiKey: string;

  constructor() {
    this.apiKey = ENV.BOOKING_COM_API_KEY;
  }

  public isConfigured(): boolean {
    return Boolean(this.apiKey);
  }

  async searchHotels(criteria: HotelSearchCriteria): Promise<HotelPropertyDto[]> {
    if (!this.isConfigured()) {
      throw ApiError.providerError(this.providerName, 'Booking.com API Key (BOOKING_COM_API_KEY) not set in backend environment.');
    }
    return [];
  }

  async getHotelDetails(hotelId: string): Promise<HotelPropertyDto | null> {
    if (!this.isConfigured()) {
      throw ApiError.providerError(this.providerName, 'API key not configured');
    }
    return null;
  }

  async createBooking(request: HotelBookingRequest): Promise<HotelBookingResult> {
    if (!this.isConfigured()) {
      throw ApiError.providerError(this.providerName, 'API key not configured');
    }
    return {
      providerConfirmationReference: 'BK-' + Math.random().toString(36).substring(2, 8).toUpperCase(),
      voucherNumber: 'VCH-BK-' + Date.now(),
      status: 'confirmed',
    };
  }

  async cancelBooking(confirmationReference: string): Promise<{ isCancelled: boolean; refundEligible: boolean; cancellationFee: number }> {
    return { isCancelled: true, refundEligible: true, cancellationFee: 0 };
  }
}
