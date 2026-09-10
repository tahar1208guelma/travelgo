import { db } from '../config/database';
import { IFlightProvider, FlightSearchCriteria } from '../providers/flight.provider.interface';
import { AmadeusFlightProvider } from '../providers/amadeus.flight.provider';
import { DuffelFlightProvider } from '../providers/duffel.flight.provider';
import { MockFlightProvider } from '../providers/mock.flight.provider';
import { CommissionService } from '../services/commission.service';
import { ApiError } from '../errors/api.error';

export class FlightsService {
  private static amadeus = new AmadeusFlightProvider();
  private static duffel = new DuffelFlightProvider();
  private static mock = new MockFlightProvider();

  /**
   * Resolves the active flight provider based on configuration and database toggle
   */
  static async getActiveProvider(): Promise<IFlightProvider> {
    try {
      const res = await db.query(
        "SELECT id, is_active FROM providers WHERE type = 'flight' AND is_active = TRUE ORDER BY is_demo ASC LIMIT 1"
      );
      if (res.rows.length > 0) {
        const id = res.rows[0].id;
        if (id === 'amadeus' && this.amadeus.isConfigured()) return this.amadeus;
        if (id === 'duffel' && this.duffel.isConfigured()) return this.duffel;
      }
    } catch (err) {
      // Fallback
    }

    // Default to Mock Provider when live credentials are not provided
    return this.mock;
  }

  static async search(criteria: FlightSearchCriteria, userId?: string) {
    const provider = await this.getActiveProvider();

    // 1. Log search in DB
    let searchId: string | null = null;
    try {
      const sRes = await db.query(
        `INSERT INTO flight_searches (user_id, origin_code, destination_code, departure_date, return_date, adults, children, infants, cabin_class)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
        [
          userId || null,
          criteria.originCode.toUpperCase(),
          criteria.destinationCode.toUpperCase(),
          criteria.departureDate,
          criteria.returnDate || null,
          criteria.adults,
          criteria.children,
          criteria.infants,
          criteria.cabinClass,
        ]
      );
      searchId = sRes.rows[0].id;
    } catch (err) {
      // Non-blocking for search query
    }

    // 2. Fetch raw offers from provider
    const rawOffers = await provider.searchFlights(criteria);

    // 3. Apply TravelGo backend commission calculation (0.75% default from DB settings)
    const finalOffers = await Promise.all(
      rawOffers.map(async (raw) => {
        const pricing = await CommissionService.calculate(raw.basePrice, raw.taxes, raw.currency);

        const stopsCount = raw.outboundSegments.length - 1;

        // Persist to flight_offers cache
        if (searchId) {
          await db.query(
            `INSERT INTO flight_offers 
             (id, search_id, provider_id, validating_airline, validating_airline_code, base_price, taxes, commission_rate, commission_amount, total_price, currency, stops_count, is_refundable, baggage_summary, outbound_itinerary_json, price_lock_expiry)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
             ON CONFLICT (id) DO UPDATE SET total_price = EXCLUDED.total_price`,
            [
              raw.providerOfferId,
              searchId,
              provider.providerId,
              raw.validatingAirline,
              raw.validatingAirlineCode,
              pricing.basePrice,
              pricing.taxes,
              pricing.commissionRate,
              pricing.commissionAmount,
              pricing.totalPrice,
              pricing.currency,
              stopsCount,
              raw.isRefundable,
              raw.baggageSummary,
              JSON.stringify(raw.outboundSegments),
              raw.priceLockExpiry,
            ]
          );
        }

        return {
          offerId: raw.providerOfferId,
          providerId: provider.providerId,
          providerName: provider.providerName,
          isDemo: provider.isDemo, // Clearly flagged if demo
          validatingAirline: raw.validatingAirline,
          validatingAirlineCode: raw.validatingAirlineCode,
          seatsRemaining: raw.seatsRemaining,
          isRefundable: raw.isRefundable,
          baggageSummary: raw.baggageSummary,
          priceLockExpiry: raw.priceLockExpiry,
          price: pricing,
          stopsCount,
          outboundSegments: raw.outboundSegments,
          returnSegments: raw.returnSegments,
        };
      })
    );

    // Calculate smart tags
    if (finalOffers.length > 0) {
      // Fastest
      const offersWithDuration = finalOffers.map((o) => {
        const totalDuration = o.outboundSegments.reduce((sum, seg) => sum + seg.durationMinutes, 0);
        let layoverDuration = 0;
        for (let i = 0; i < o.outboundSegments.length - 1; i++) {
          const arr = new Date(o.outboundSegments[i].arrivalDateTime).getTime();
          const dep = new Date(o.outboundSegments[i+1].departureDateTime).getTime();
          layoverDuration += (dep - arr) / 60000;
        }
        return { ...o, totalDuration: totalDuration + layoverDuration };
      });

      const fastestOffer = offersWithDuration.reduce((prev, current) => (prev.totalDuration < current.totalDuration) ? prev : current);
      const cheapestOffer = finalOffers.reduce((prev, current) => (prev.price.totalPrice < current.price.totalPrice) ? prev : current);

      // Best Value: normalize price and duration
      const maxPrice = Math.max(...finalOffers.map(o => o.price.totalPrice));
      const minPrice = Math.min(...finalOffers.map(o => o.price.totalPrice));
      const maxDuration = Math.max(...offersWithDuration.map(o => o.totalDuration));
      const minDuration = Math.min(...offersWithDuration.map(o => o.totalDuration));

      const bestValueOffer = offersWithDuration.reduce((prev, current) => {
        const priceScorePrev = maxPrice === minPrice ? 0 : (prev.price.totalPrice - minPrice) / (maxPrice - minPrice);
        const durationScorePrev = maxDuration === minDuration ? 0 : (prev.totalDuration - minDuration) / (maxDuration - minDuration);
        const scorePrev = priceScorePrev * 0.7 + durationScorePrev * 0.3; // Give more weight to price

        const priceScoreCurr = maxPrice === minPrice ? 0 : (current.price.totalPrice - minPrice) / (maxPrice - minPrice);
        const durationScoreCurr = maxDuration === minDuration ? 0 : (current.totalDuration - minDuration) / (maxDuration - minDuration);
        const scoreCurr = priceScoreCurr * 0.7 + durationScoreCurr * 0.3;

        return (scorePrev < scoreCurr) ? prev : current;
      });

      finalOffers.forEach(o => {
        (o as any)['smartTags'] = [];
        if (o.offerId === fastestOffer.offerId) (o as any)['smartTags'].push('Fastest');
        if (o.offerId === cheapestOffer.offerId && !((o as any)['smartTags'] as string[]).includes('Cheapest')) (o as any)['smartTags'].push('Cheapest');
        if (o.offerId === bestValueOffer.offerId && !((o as any)['smartTags'] as string[]).includes('Best Value')) (o as any)['smartTags'].push('Best Value');
      });
    }

    return {
      searchId,
      provider: { id: provider.providerId, name: provider.providerName, isDemo: provider.isDemo },
      offersCount: finalOffers.length,
      offers: finalOffers,
    };
  }

  static async verifyPrice(offerId: string) {
    const res = await db.query('SELECT * FROM flight_offers WHERE id = $1', [offerId]);
    if (res.rows.length === 0) {
      throw ApiError.notFound('Flight offer has expired or does not exist');
    }

    const offer = res.rows[0];
    const provider = await this.getActiveProvider();
    const verification = await provider.verifyPrice(offerId);

    if (!verification.isAvailable) {
      throw ApiError.badRequest('This flight is no longer available from the airline', 'AVAILABILITY_CHANGED');
    }

    // Check if price changed
    const currentBase = verification.currentBasePrice;
    const oldBase = parseFloat(offer.base_price);
    if (Math.abs(currentBase - oldBase) > 2.0) {
      const updatedPricing = await CommissionService.calculate(currentBase, verification.currentTaxes, offer.currency);
      throw ApiError.priceChanged(parseFloat(offer.total_price), updatedPricing.totalPrice, offer.currency);
    }

    return { isVerified: true, offer };
  }
}
