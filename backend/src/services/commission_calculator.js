/**
 * @file commission_calculator.js
 * @description Pure deterministic financial arithmetic service for TravelGo.
 * Complies strictly with AGENTS.md rules 11, 12, and 13.
 */

export class CommissionCalculator {
  /**
   * Round amount deterministically to 2 decimal places.
   * @param {number} val
   * @returns {number}
   */
  static round2(val) {
    return Math.round((val + Number.EPSILON) * 100) / 100;
  }

  /**
   * Calculates financial breakdown for a Direct Booking.
   * Total = Base Fare + Taxes + Standard Direct Service Fee ($1.00 default)
   *
   * @param {Object} params
   * @param {number} params.baseFare - Flight or Room base cost
   * @param {number} params.taxes - Applicable airport/local taxes
   * @param {number} [params.serviceFee=1.00] - Standard platform fee ($1.00 default)
   * @param {number} [params.commissionRate=0.0075] - Dynamic rate (0.75% default, or partner tier e.g. 0.12)
   * @returns {Object} Deterministic breakdown
   */
  static calculateDirectBooking({
    baseFare,
    taxes = 0,
    serviceFee = 1.00,
    commissionRate = 0.0075
  }) {
    if (baseFare < 0 || taxes < 0 || serviceFee < 0) {
      throw new Error('Financial values must be non-negative');
    }

    const roundedBase = this.round2(baseFare);
    const roundedTaxes = this.round2(taxes);
    const roundedFee = this.round2(serviceFee);

    // Total Amount paid by user
    const totalAmount = this.round2(roundedBase + roundedTaxes + roundedFee);

    // Platform percentage commission earned
    const commissionAmount = this.round2(roundedBase * commissionRate);

    // Provider payout: Base + Taxes - Commission Amount
    const providerPayout = this.round2((roundedBase + roundedTaxes) - commissionAmount);

    // Net Platform Revenue = Service Fee ($1.00) + Commission Amount
    const platformRevenue = this.round2(roundedFee + commissionAmount);

    return {
      baseFare: roundedBase,
      taxes: roundedTaxes,
      serviceFee: roundedFee,
      totalAmount,
      commissionRate,
      commissionAmount,
      providerPayout,
      platformRevenue
    };
  }

  /**
   * Calculates financial breakdown for Affiliate Redirects.
   * Service fee on affiliate redirects is strictly $0.00 (Rule 12.2).
   *
   * @param {Object} params
   * @param {number} params.baseFare
   * @param {number} params.taxes
   * @returns {Object}
   */
  static calculateAffiliateRedirect({ baseFare, taxes = 0 }) {
    if (baseFare < 0 || taxes < 0) {
      throw new Error('Financial values must be non-negative');
    }

    const roundedBase = this.round2(baseFare);
    const roundedTaxes = this.round2(taxes);
    const serviceFee = 0.00; // Zero platform markup

    return {
      baseFare: roundedBase,
      taxes: roundedTaxes,
      serviceFee,
      totalAmount: this.round2(roundedBase + roundedTaxes),
      platformMarkup: 0.00
    };
  }

  /**
   * Calculates refund breakdown upon cancellation.
   * Standard policy: base fare and taxes are refunded to customer,
   * while the standard service fee ($1.00) covers operational payment processing.
   *
   * @param {Object} bookingDetails
   * @returns {Object}
   */
  static calculateRefund({ baseFare, taxes, serviceFee = 1.00, isFullRefund = false }) {
    const roundedBase = this.round2(baseFare);
    const roundedTaxes = this.round2(taxes);
    const roundedFee = this.round2(serviceFee);

    let customerRefundAmount;
    if (isFullRefund) {
      customerRefundAmount = this.round2(roundedBase + roundedTaxes + roundedFee);
    } else {
      customerRefundAmount = this.round2(roundedBase + roundedTaxes);
    }

    return {
      customerRefundAmount,
      retainedPlatformFee: isFullRefund ? 0.00 : roundedFee,
      isFullRefund
    };
  }
}
