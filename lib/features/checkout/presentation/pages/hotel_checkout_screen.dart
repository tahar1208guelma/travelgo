import 'package:flutter/material.dart';
import '../../../../core/architecture/bloc_base.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/print_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../bookings/presentation/widgets/price_summary_card.dart';
import '../../../hotels/models/hotel_offer.dart';
import '../../bloc/checkout_bloc.dart';
import '../../bloc/checkout_event.dart';
import '../../bloc/checkout_state.dart';
import '../../models/passenger_input.dart';
import '../widgets/hosted_card_input_widget.dart';
import '../widgets/three_d_secure_dialog.dart';
import 'booking_success_screen.dart';
import '../../../auth/presentation/pages/email_verification_screen.dart';

class HotelCheckoutScreen extends StatefulWidget {
  final HotelOffer hotel;
  final CheckoutBloc bloc;

  const HotelCheckoutScreen({super.key, required this.hotel, required this.bloc});

  @override
  State<HotelCheckoutScreen> createState() => _HotelCheckoutScreenState();
}

class _HotelCheckoutScreenState extends State<HotelCheckoutScreen> {
  final _guestNameController = TextEditingController(text: 'Tahar Braknia');
  final _emailController = TextEditingController(text: 'tahar.braknia@example.com');
  final _phoneController = TextEditingController(text: '+213-550-123456');

  @override
  void initState() {
    super.initState();
    widget.bloc.add(StartHotelCheckout(
      hotel: widget.hotel,
      leadGuestName: _guestNameController.text.trim(),
      leadGuestEmail: _emailController.text.trim(),
    ));
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    final names = _guestNameController.text.trim().split(' ');
    final firstName = names.isNotEmpty ? names.first : 'Guest';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'Guest';

    final passenger = PassengerInput(
      firstName: firstName,
      lastName: lastName,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      passportNumber: 'N10984728',
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
            title: const Text('Reserve Hotel Room'),
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
                      _buildStepPill('1. Guest Details', state is CheckoutPassengerEntry || state is CheckoutInitial),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 8),
                      _buildStepPill('2. Secure Payment & 3DS', state is CheckoutPaymentReady || state is Checkout3DSChallengeRequired),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hotel Summary Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.hotel, color: AppTheme.accentBlue, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.hotel.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                                ),
                                Text(
                                  '${widget.hotel.primaryRoom.roomType} • ${widget.hotel.mealPlan}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(widget.hotel.price.totalAmount, currency: widget.hotel.price.currency),
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
                    PriceSummaryCard(price: widget.hotel.price),
                    const SizedBox(height: 16),
                    HostedCardInputWidget(
                      onPaymentMethodCreated: (paymentMethod) {
                        widget.bloc.add(ProcessTokenizedPayment(paymentMethod));
                      },
                    ),
                  ] else ...[
                    // Guest Information Form
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
                              'Primary Guest Information',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                            const Divider(height: 20, color: AppTheme.cardBorder),
                            TextField(
                              controller: _guestNameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Guest Name',
                                prefixIcon: Icon(Icons.person_outline, size: 18),
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
                    PriceSummaryCard(price: widget.hotel.price),
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
