import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.user;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Enforce role safety: public registration only allows user or partner (never admin)
    final safeRole = (_selectedRole == UserRole.admin) ? UserRole.user : _selectedRole;

    final success = await ref.read(authStateProvider.notifier).register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      role: safeRole,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  void _handleGoogleRegister() async {
    setState(() => _isLoading = true);
    final success = await ref.read(authStateProvider.notifier).loginWithGoogle();
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  void _handleAppleRegister() async {
    setState(() => _isLoading = true);
    final success = await ref.read(authStateProvider.notifier).loginWithApple();
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('auth_register_title'),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.tr('auth_register_subtitle'),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Account Type Selector (Customer vs Hotel Partner)
                Text(
                  context.tr('auth_account_type'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text(context.tr('auth_role_traveler')),
                        selected: _selectedRole == UserRole.user,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedRole = UserRole.user);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ChoiceChip(
                        label: Text(context.tr('auth_role_partner')),
                        selected: _selectedRole == UserRole.partner,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedRole = UserRole.partner);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Name field
                CustomTextField(
                  label: context.tr('auth_full_name'),
                  hintText: 'John Doe',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (value) => AppValidators.validateRequired(
                    value,
                    context.tr('validation_required'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

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
                const SizedBox(height: AppSpacing.md),

                // Confirm Password field
                CustomTextField(
                  label: context.tr('auth_confirm_password'),
                  hintText: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  validator: (value) => AppValidators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                    matchMsg: context.tr('validation_passwords_not_match'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit Button
                CustomButton(
                  text: context.tr('auth_register'),
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Social registration section
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

                // Google Sign Up Button
                CustomButton(
                  text: context.tr('auth_google_register'),
                  onPressed: _handleGoogleRegister,
                  type: ButtonType.outline,
                  icon: Icons.g_mobiledata_rounded,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Apple Sign Up Button
                CustomButton(
                  text: context.tr('auth_apple_register'),
                  onPressed: _handleAppleRegister,
                  type: ButtonType.outline,
                  icon: Icons.apple_rounded,
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

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('auth_have_account'),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        context.tr('auth_login'),
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
