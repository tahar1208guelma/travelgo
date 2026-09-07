import { db } from '../config/database';
import { ApiError } from '../errors/api.error';
import { CommissionService } from '../services/commission.service';
import { NotificationService } from '../services/notification.service';
import { BackendPdfService } from '../services/pdf.service';
import { FlightsService } from '../flights/flights.service';
import { HotelsService } from '../hotels/hotels.service';
import { AuditService } from '../services/audit.service';
import { FinanceService } from '../finance/finance.service';

export interface CreateFlightBookingDto {
  bookingType: 'flight';
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

export interface CreateHotelBookingDto {
  bookingType: 'hotel';
  hotelId: string;
  roomId: string;
  hotelName: string;
  checkIn: string;
  checkOut: string;
  nights: number;
  roomsCount: number;
  basePricePerNight: number;
  taxesPerNight: number;
  currency: string;
  guests: Array<{
    firstName: string;
    lastName: string;
    email: string;
    phone?: string;
  }>;
}

export type CreateBookingDto = CreateFlightBookingDto | CreateHotelBookingDto;

export class BookingsService {
  static async createBooking(dto: CreateBookingDto, userId?: string, ip?: string) {
    const client = await db.getClient();
    try {
      await client.query('BEGIN');

      const bookingRef = `TRV-${new Date().getFullYear()}-${Math.floor(100000 + Math.random() * 900000)}`;

      if (dto.bookingType === 'flight') {
        // 1. Retrieve offer details
        const oRes = await client.query('SELECT * FROM flight_offers WHERE id = $1', [dto.offerId]);
        if (oRes.rows.length === 0) {
          throw ApiError.notFound('Selected flight offer has expired. Please perform a new search.');
        }

        const offer = oRes.rows[0];
        const basePrice = parseFloat(offer.base_price);
        const taxes = parseFloat(offer.taxes);
        const pricing = await CommissionService.calculate(basePrice, taxes, offer.currency);

        // 2. Insert master booking record
        const bRes = await client.query(
          `INSERT INTO bookings 
           (booking_reference, user_id, booking_type, provider_id, status, base_price, taxes, commission_rate, commission_amount, total_price, currency, is_refundable)
           VALUES ($1, $2, 'flight', $3, 'payment_pending', $4, $5, $6, $7, $8, $9, $10)
           RETURNING id`,
          [
            bookingRef,
            userId || null,
            offer.provider_id,
            pricing.basePrice,
            pricing.taxes,
            pricing.commissionRate,
            pricing.commissionAmount,
            pricing.totalPrice,
            pricing.currency,
            offer.is_refundable,
          ]
        );

        const bookingId = bRes.rows[0].id;

        // 3. Insert flight_bookings child record
        await client.query(
          `INSERT INTO flight_bookings (booking_id, validating_airline, segments, passengers)
           VALUES ($1, $2, $3, $4)`,
          [bookingId, offer.validating_airline, offer.outbound_itinerary_json, JSON.stringify(dto.passengers)]
        );

        // 4. Save passengers to user profile if user logged in
        if (userId) {
          for (const p of dto.passengers) {
            await client.query(
              `INSERT INTO passengers (user_id, first_name, last_name, passport_number, nationality, passport_expiry, date_of_birth, gender)
               VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
               ON CONFLICT DO NOTHING`,
              [userId, p.firstName, p.lastName, p.passportNumber || null, p.nationality || 'Algerian', p.passportExpiry || null, p.dateOfBirth, p.gender || null]
            );
          }
        }

        await client.query('COMMIT');
        await AuditService.log('BOOKING_CREATED', 'bookings', bookingId, userId, { bookingRef, type: 'flight' }, ip);

        return {
          bookingId,
          bookingReference: bookingRef,
          status: 'payment_pending',
          bookingType: 'flight',
          price: pricing,
        };
      } else {
        // Hotel Booking
        const totalBase = dto.basePricePerNight * dto.nights * dto.roomsCount;
        const totalTaxes = dto.taxesPerNight * dto.nights * dto.roomsCount;
        const pricing = await CommissionService.calculate(totalBase, totalTaxes, dto.currency);

        const bRes = await client.query(
          `INSERT INTO bookings 
           (booking_reference, user_id, booking_type, provider_id, status, base_price, taxes, commission_rate, commission_amount, total_price, currency, is_refundable)
           VALUES ($1, $2, 'hotel', 'mock_hotel', 'payment_pending', $3, $4, $5, $6, $7, $8, TRUE)
           RETURNING id`,
          [bookingRef, userId || null, pricing.basePrice, pricing.taxes, pricing.commissionRate, pricing.commissionAmount, pricing.totalPrice, pricing.currency]
        );

        const bookingId = bRes.rows[0].id;

        await client.query(
          `INSERT INTO hotel_bookings (booking_id, hotel_id, room_id, hotel_name, check_in, check_out, nights, rooms_count, guests)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
          [bookingId, dto.hotelId, dto.roomId, dto.hotelName, dto.checkIn, dto.checkOut, dto.nights, dto.roomsCount, JSON.stringify(dto.guests)]
        );

        await client.query('COMMIT');
        await AuditService.log('BOOKING_CREATED', 'bookings', bookingId, userId, { bookingRef, type: 'hotel' }, ip);

        return {
          bookingId,
          bookingReference: bookingRef,
          status: 'payment_pending',
          bookingType: 'hotel',
          price: pricing,
        };
      }
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  static async confirmBookingAfterPayment(bookingId: string, paymentIntentId: string, paymentMethodLast4?: string) {
    const bRes = await db.query('SELECT * FROM bookings WHERE id = $1', [bookingId]);
    if (bRes.rows.length === 0) throw ApiError.notFound('Booking not found');
    const booking = bRes.rows[0];

    // Confirm with provider
    let providerRef = 'CONF-' + Math.random().toString(36).substring(2, 8).toUpperCase();
    let isTicketConfirmed = false;

    if (booking.booking_type === 'flight') {
      const flightProvider = await FlightsService.getActiveProvider();
      const fbRes = await db.query('SELECT * FROM flight_bookings WHERE booking_id = $1', [bookingId]);
      const fb = fbRes.rows[0];
      const result = await flightProvider.createBooking({
        offerId: bookingId,
        passengers: typeof fb.passengers === 'string' ? JSON.parse(fb.passengers) : fb.passengers,
      });

      providerRef = result.providerReference;
      isTicketConfirmed = result.isTicketIssued;

      await db.query(
        `UPDATE flight_bookings SET airline_pnr = $1, ticket_numbers = $2, is_ticket_issued = $3 WHERE booking_id = $4`,
        [result.providerReference, JSON.stringify(result.ticketNumbers), isTicketConfirmed, bookingId]
      );
    } else {
      const hotelProvider = await HotelsService.getActiveProvider();
      const hbRes = await db.query('SELECT * FROM hotel_bookings WHERE booking_id = $1', [bookingId]);
      const hb = hbRes.rows[0];
      const result = await hotelProvider.createBooking({
        hotelId: hb.hotel_id,
        roomId: hb.room_id,
        checkIn: hb.check_in,
        checkOut: hb.check_out,
        guests: typeof hb.guests === 'string' ? JSON.parse(hb.guests) : hb.guests,
      });
      providerRef = result.providerConfirmationReference;
      isTicketConfirmed = true;
    }

    // Update master status to 'confirmed'
    await db.query(
      `UPDATE bookings SET status = 'confirmed', provider_reference = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2`,
      [providerRef, bookingId]
    );

    // Financial Architecture: Strict Commission Lifecycle (Payment -> Pending -> Provider Confirmed -> Available)
    const platformOwnerId = '00000000-0000-0000-0000-000000000001';
    await FinanceService.recordPendingCommission(
      platformOwnerId,
      bookingId,
      parseFloat(booking.base_price),
      booking.currency,
      parseFloat(booking.commission_rate)
    );

    // When provider confirms (PNR / hotel voucher issued), release commission to available wallet balance
    if (isTicketConfirmed) {
      await FinanceService.releaseCommissionToAvailable(platformOwnerId, bookingId);
    }

    // Generate Voucher & Invoice metadata
    const docMeta = {
      bookingReference: booking.booking_reference,
      providerReference: providerRef,
      isConfirmedWithProvider: isTicketConfirmed,
      bookingType: booking.booking_type,
      status: 'confirmed',
      customerName: 'Traveler',
      totalPrice: parseFloat(booking.total_price),
      currency: booking.currency,
      createdAt: new Date().toISOString(),
    };

    const docTitles = BackendPdfService.getDocumentTypeAndTitle(docMeta);
    const qrPayload = BackendPdfService.generateVerificationPayload(docMeta);

    await db.query(
      `INSERT INTO invoices (invoice_number, booking_id, total_amount, currency, qr_code_payload)
       VALUES ($1, $2, $3, $4, $5)`,
      [`INV-${Date.now()}`, bookingId, booking.total_price, booking.currency, qrPayload]
    );

    await db.query(
      `INSERT INTO vouchers (voucher_number, booking_id, voucher_type)
       VALUES ($1, $2, $3)`,
      [`VCH-${Date.now()}`, bookingId, docTitles.documentType]
    );

    // Dispatch notification
    if (booking.user_id) {
      await NotificationService.send({
        userId: booking.user_id,
        type: 'booking_confirmed',
        title: `Booking Confirmed: ${booking.booking_reference}`,
        message: `Your ${booking.booking_type} reservation (${providerRef}) has been confirmed successfully.`,
        metadata: { bookingId, reference: booking.booking_reference, pnr: providerRef },
      });
    }

    return {
      bookingId,
      bookingReference: booking.booking_reference,
      status: 'confirmed',
      providerReference: providerRef,
      documentTitle: docTitles.documentTitle,
      isTicketConfirmed,
    };
  }

  static async getBookingById(bookingId: string, userId?: string) {
    const res = await db.query(
      `SELECT b.*, 
              fb.airline_pnr, fb.validating_airline, fb.segments, fb.passengers, fb.ticket_numbers, fb.is_ticket_issued,
              hb.hotel_name, hb.check_in, hb.check_out, hb.nights, hb.rooms_count, hb.guests
       FROM bookings b
       LEFT JOIN flight_bookings fb ON b.id = fb.booking_id
       LEFT JOIN hotel_bookings hb ON b.id = hb.booking_id
       WHERE b.id = $1`,
      [bookingId]
    );

    if (res.rows.length === 0) throw ApiError.notFound('Booking not found');
    const booking = res.rows[0];

    if (userId && booking.user_id && booking.user_id !== userId) {
      throw ApiError.forbidden('Unauthorized access to booking');
    }

    return booking;
  }

  static async getUserBookings(userId: string) {
    const res = await db.query(
      `SELECT b.*, 
              fb.airline_pnr, fb.validating_airline, fb.segments,
              hb.hotel_name, hb.check_in, hb.check_out
       FROM bookings b
       LEFT JOIN flight_bookings fb ON b.id = fb.booking_id
       LEFT JOIN hotel_bookings hb ON b.id = hb.booking_id
       WHERE b.user_id = $1
       ORDER BY b.created_at DESC`,
      [userId]
    );

    return res.rows;
  }

  static async cancelBooking(bookingId: string, userId?: string) {
    const booking = await this.getBookingById(bookingId, userId);

    if (booking.status === 'cancelled') {
      throw ApiError.badRequest('Booking is already cancelled', 'BOOKING_CANCELLED');
    }

    if (!booking.is_refundable && booking.status === 'confirmed') {
      throw ApiError.badRequest('This booking is non-refundable per provider fare rules', 'BOOKING_FAILED');
    }

    // Provider cancellation
    if (booking.booking_type === 'flight') {
      const flightProvider = await FlightsService.getActiveProvider();
      await flightProvider.cancelBooking(booking.provider_reference || '');
    }

    await db.query(
      `UPDATE bookings SET status = 'cancelled', updated_at = CURRENT_TIMESTAMP WHERE id = $1`,
      [bookingId]
    );

    if (booking.user_id) {
      await NotificationService.send({
        userId: booking.user_id,
        type: 'cancellation',
        title: `Booking Cancelled: ${booking.booking_reference}`,
        message: `Your booking has been cancelled according to policy.`,
      });
    }

    return { isCancelled: true, bookingReference: booking.booking_reference, status: 'cancelled' };
  }
}
