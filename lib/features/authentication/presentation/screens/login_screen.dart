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

  void _handleGuestMode() async {
    await ref.read(authStateProvider.notifier).continueAsGuest();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
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

                // Google Sign In Button
                CustomButton(
                  text: context.tr('auth_google_sign_in'),
                  onPressed: _handleGoogleLogin,
                  type: ButtonType.outline,
                  icon: Icons.g_mobiledata_rounded,
                ),
                const SizedBox(height: AppSpacing.md),

                // Guest Mode Button
                CustomButton(
                  text: context.tr('auth_guest_sign_in'),
                  onPressed: _handleGuestMode,
                  type: ButtonType.text,
                  icon: Icons.person_outline_rounded,
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
