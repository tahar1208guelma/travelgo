import { db } from '../config/database';
import { IHotelProvider, HotelSearchCriteria } from '../providers/hotel.provider.interface';
import { BookingComHotelProvider } from '../providers/bookingcom.hotel.provider';
import { MockHotelProvider } from '../providers/mock.hotel.provider';
import { CommissionService } from '../services/commission.service';

export class HotelsService {
  private static bookingCom = new BookingComHotelProvider();
  private static mock = new MockHotelProvider();

  static async getActiveProvider(): Promise<IHotelProvider> {
    try {
      const res = await db.query(
        "SELECT id, is_active FROM providers WHERE type = 'hotel' AND is_active = TRUE ORDER BY is_demo ASC LIMIT 1"
      );
      if (res.rows.length > 0 && res.rows[0].id === 'booking_com' && this.bookingCom.isConfigured()) {
        return this.bookingCom;
      }
    } catch (err) {
      // Fallback
    }
    return this.mock;
  }

  static async search(criteria: HotelSearchCriteria, userId?: string) {
    const provider = await this.getActiveProvider();

    // Log search
    try {
      await db.query(
        `INSERT INTO hotel_searches (user_id, destination, check_in, check_out, adults, children, rooms_count)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [userId || null, criteria.destination, criteria.checkIn, criteria.checkOut, criteria.adults, criteria.children, criteria.roomsCount]
      );
    } catch (err) {
      // Non-blocking
    }

    const rawHotels = await provider.searchHotels(criteria);

    // Apply TravelGo Commission to room prices
    const hotels = await Promise.all(
      rawHotels.map(async (h) => {
        const rooms = await Promise.all(
          h.rooms.map(async (r) => {
            const pricing = await CommissionService.calculate(r.basePricePerNight, r.taxesPerNight, r.currency);
            return {
              ...r,
              pricing,
            };
          })
        );
        return {
          ...h,
          rooms,
        };
      })
    );

    return {
      provider: { id: provider.providerId, name: provider.providerName, isDemo: provider.isDemo },
      hotelsCount: hotels.length,
      hotels,
    };
  }

  static async getDetails(hotelId: string) {
    const provider = await this.getActiveProvider();
    return provider.getHotelDetails(hotelId);
  }
}
