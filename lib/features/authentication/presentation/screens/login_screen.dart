import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import '../controllers/auth_controller.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'traveler@travelgo.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(authStateProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final success = await ref.read(authStateProvider.notifier).loginWithGoogle();
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  void _handleAppleLogin() async {
    setState(() => _isLoading = true);
    final success = await ref.read(authStateProvider.notifier).loginWithApple();
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  void _handleGuestMode() async {
    await ref.read(authStateProvider.notifier).continueAsGuest();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  void _showPhoneOtpBottomSheet(BuildContext context) {
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    bool isOtpSent = false;
    bool isSubmitting = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: bottomPadding + AppSpacing.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      context.tr('auth_otp_dialog_title'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isOtpSent
                          ? '${context.tr('auth_otp_sent_to')} ${phoneController.text.trim()}'
                          : context.tr('auth_otp_dialog_subtitle'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],

                    if (!isOtpSent) ...[
                      CustomTextField(
                        label: context.tr('auth_phone_number'),
                        hintText: context.tr('auth_phone_hint'),
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomButton(
                        text: context.tr('auth_send_otp'),
                        isLoading: isSubmitting,
                        onPressed: () async {
                          final phone = phoneController.text.trim();
                          if (phone.length < 7) {
                            setSheetState(() => errorMessage = 'Please enter a valid phone number');
                            return;
                          }
                          setSheetState(() {
                            isSubmitting = true;
                            errorMessage = null;
                          });

                          final ok = await ref.read(authStateProvider.notifier).sendPhoneOtp(phone);
                          setSheetState(() {
                            isSubmitting = false;
                            if (ok) {
                              isOtpSent = true;
                            } else {
                              errorMessage = 'Failed to send verification code. Try again.';
                            }
                          });
                        },
                      ),
                    ] else ...[
                      CustomTextField(
                        label: context.tr('auth_otp_code'),
                        hintText: context.tr('auth_otp_hint'),
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.lock_clock_rounded, size: 20),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomButton(
                        text: context.tr('auth_verify_otp'),
                        isLoading: isSubmitting,
                        onPressed: () async {
                          final code = otpController.text.trim();
                          if (code.length != 6) {
                            setSheetState(() => errorMessage = 'Please enter the 6-digit code');
                            return;
                          }
                          setSheetState(() {
                            isSubmitting = true;
                            errorMessage = null;
                          });

                          final ok = await ref.read(authStateProvider.notifier).verifyPhoneOtp(
                            phoneController.text.trim(),
                            code,
                          );

                          if (ok && mounted) {
                            Navigator.of(bottomSheetContext).pop();
                            Navigator.of(this.context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                            );
                          } else {
                            setSheetState(() {
                              isSubmitting = false;
                              errorMessage = 'Invalid verification code. Please try again.';
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = ref.watch(languageProvider.notifier).isArabic;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(languageProvider.notifier).toggleLanguage(),
            icon: const Icon(Icons.language, size: 18),
            label: Text(isArabic ? 'English' : 'العربية'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flight_takeoff_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Text(
                    context.tr('auth_welcome_back'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: Text(
                    context.tr('auth_login_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Email field
                CustomTextField(
                  label: context.tr('auth_email'),
                  hintText: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (value) => AppValidators.validateEmail(
                    value,
                    requiredMsg: context.tr('validation_required'),
                    invalidMsg: context.tr('validation_invalid_email'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Password field
                CustomTextField(
                  label: context.tr('auth_password'),
                  hintText: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) => AppValidators.validatePassword(
                    value,
                    requiredMsg: context.tr('validation_required'),
                    minLengthMsg: context.tr('validation_password_too_short'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      context.tr('auth_forgot_password'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Sign In Button
                CustomButton(
                  text: context.tr('auth_login'),
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                ),
                const SizedBox(height: AppSpacing.md),

                // Social Login Section
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? AppColors.dividerDark : AppColors.dividerLight)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text(
                        context.tr('auth_or_continue_with'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: isDark ? AppColors.dividerDark : AppColors.dividerLight)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Google Sign In Button
                CustomButton(
                  text: context.tr('auth_google_sign_in'),
                  onPressed: _handleGoogleLogin,
                  type: ButtonType.outline,
                  icon: Icons.g_mobiledata_rounded,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Apple Sign In Button
                CustomButton(
                  text: context.tr('auth_apple_sign_in'),
                  onPressed: _handleAppleLogin,
                  type: ButtonType.outline,
                  icon: Icons.apple_rounded,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Phone OTP Sign In Button
                CustomButton(
                  text: context.tr('auth_phone_sign_in'),
                  onPressed: () => _showPhoneOtpBottomSheet(context),
                  type: ButtonType.outline,
                  icon: Icons.phone_android_rounded,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Guest Mode Button
                CustomButton(
                  text: context.tr('auth_guest_sign_in'),
                  onPressed: _handleGuestMode,
                  type: ButtonType.text,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.md),

                // Terms disclaimer
                Center(
                  child: Text(
                    context.tr('auth_terms_agreement'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('auth_no_account'),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        context.tr('auth_register'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
