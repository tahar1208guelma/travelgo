import 'package:flutter/material.dart';
import '../../../../core/architecture/bloc_base.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../bookings/presentation/widgets/price_summary_card.dart';
import '../../../flights/models/flight_offer.dart';
import '../../bloc/checkout_bloc.dart';
import '../../bloc/checkout_event.dart';
import '../../bloc/checkout_state.dart';
import '../../models/passenger_input.dart';
import '../widgets/hosted_card_input_widget.dart';
import '../widgets/three_d_secure_dialog.dart';
import 'booking_success_screen.dart';

class FlightCheckoutScreen extends StatefulWidget {
  final FlightOffer offer;
  final CheckoutBloc bloc;

  const FlightCheckoutScreen({super.key, required this.offer, required this.bloc});

  @override
  State<FlightCheckoutScreen> createState() => _FlightCheckoutScreenState();
}

class _FlightCheckoutScreenState extends State<FlightCheckoutScreen> {
  final _firstNameController = TextEditingController(text: 'Tahar');
  final _lastNameController = TextEditingController(text: 'Braknia');
  final _emailController = TextEditingController(text: 'tahar.braknia@example.com');
  final _phoneController = TextEditingController(text: '+213-550-123456');
  final _passportController = TextEditingController(text: 'N10984728');

  @override
  void initState() {
    super.initState();
    widget.bloc.add(StartFlightCheckout(widget.offer));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passportController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    final passenger = PassengerInput(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      passportNumber: _passportController.text.trim(),
      dateOfBirth: DateTime(1992, 5, 14),
    );

    widget.bloc.add(SubmitTravelerDetails(
      passengers: [passenger],
      contactEmail: _emailController.text.trim(),
      contactPhone: _phoneController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      bloc: widget.bloc,
      listener: (context, state) {
        if (state is Checkout3DSChallengeRequired) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => ThreeDSecureDialog(
              intent: state.paymentIntent,
              paymentMethod: state.paymentMethod,
              onVerificationComplete: () {
                widget.bloc.add(const Complete3DSChallenge());
              },
            ),
          );
        } else if (state is CheckoutBookingSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BookingSuccessScreen(
                booking: state.confirmedBooking,
                eTicketOrVoucherNumber: state.eTicketOrVoucherNumber,
                pdfService: PdfService(),
                printService: PrintService(),
                shareService: ShareService(),
              ),
            ),
          );
        } else if (state is CheckoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage), backgroundColor: AppTheme.errorRed),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Secure Flight Checkout'),
          ),
          body: ResponsiveContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Progress Tracker
                  Row(
                    children: [
                      _buildStepPill('1. Passenger Details', state is CheckoutPassengerEntry || state is CheckoutInitial),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 8),
                      _buildStepPill('2. Secure Payment & 3DS', state is CheckoutPaymentReady || state is Checkout3DSChallengeRequired),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Flight Summary Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.flight, color: AppTheme.accentBlue, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.offer.validatingAirline} • ${widget.offer.primaryOutboundSegment.flightNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                                ),
                                Text(
                                  '${widget.offer.primaryOutboundSegment.departureAirportCode} → ${widget.offer.primaryOutboundSegment.arrivalAirportCode} (${widget.offer.primaryOutboundSegment.cabinClass})',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(widget.offer.price.totalAmount, currency: widget.offer.price.currency),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (state is CheckoutProcessingPayment) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(color: AppTheme.accentBlue),
                            const SizedBox(height: 16),
                            Text(state.statusMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ] else if (state is CheckoutPaymentReady || state is Checkout3DSChallengeRequired) ...[
                    // Payment Card
                    PriceSummaryCard(price: widget.offer.price),
                    const SizedBox(height: 16),
                    HostedCardInputWidget(
                      onPaymentMethodCreated: (paymentMethod) {
                        widget.bloc.add(ProcessTokenizedPayment(paymentMethod));
                      },
                    ),
                  ] else ...[
                    // Passenger Information Form
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Traveler Identification & Contact',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                            const Divider(height: 20, color: AppTheme.cardBorder),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _firstNameController,
                                    decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _lastNameController,
                                    decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passportController,
                              decoration: const InputDecoration(
                                labelText: 'Passport Number',
                                prefixIcon: Icon(Icons.badge_outlined, size: 18),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Confirmation Email',
                                prefixIcon: Icon(Icons.email_outlined, size: 18),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Mobile Phone',
                                prefixIcon: Icon(Icons.phone_outlined, size: 18),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price Breakdown
                    PriceSummaryCard(price: widget.offer.price),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Continue to Secure Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepPill(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.accentBlue : AppTheme.slateBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : AppTheme.textMuted,
        ),
      ),
    );
  }
}
