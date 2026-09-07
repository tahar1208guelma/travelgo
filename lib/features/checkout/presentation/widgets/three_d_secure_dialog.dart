import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/payment_intent.dart';
import '../../models/payment_method.dart';

class ThreeDSecureDialog extends StatefulWidget {
  final PaymentIntent intent;
  final TokenizedPaymentMethod paymentMethod;
  final VoidCallback onVerificationComplete;

  const ThreeDSecureDialog({
    super.key,
    required this.intent,
    required this.paymentMethod,
    required this.onVerificationComplete,
  });

  @override
  State<ThreeDSecureDialog> createState() => _ThreeDSecureDialogState();
}

class _ThreeDSecureDialogState extends State<ThreeDSecureDialog> {
  final _otpController = TextEditingController(text: '123456');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      Navigator.of(context).pop();
      widget.onVerificationComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.verified_user, color: AppTheme.accentBlue, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified by 3-D Secure 2.0',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                      ),
                      Text(
                        'Cardholder Bank Identity Verification',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppTheme.cardBorder),

            Text(
              'A one-time passcode (OTP) has been sent to your registered mobile phone ending in •• 456 for card ${widget.paymentMethod.cardBrand} •••• ${widget.paymentMethod.last4}.',
              style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'Enter 6-Digit Passcode',
                prefixIcon: Icon(Icons.key, size: 18),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirm & Authorize Payment', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
