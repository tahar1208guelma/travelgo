import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Retrieves the currently cached user session, if available.
  Future<UserEntity?> getCurrentUser();

  /// Logs in with email and password credentials.
  Future<UserEntity> loginWithEmail(String email, String password);

  /// Registers a new user. Public registration enforces role safety.
  Future<UserEntity> registerWithEmail(
    String name,
    String email,
    String password, {
    UserRole role = UserRole.user,
  });

  /// Authenticates using Google Sign-In.
  Future<UserEntity> signInWithGoogle();

  /// Authenticates using Apple Sign-In.
  Future<UserEntity> signInWithApple();

  /// Initializes an unauthenticated/guest session.
  Future<UserEntity> continueAsGuest();

  /// Dispatches a password reset email to the given address.
  Future<void> sendPasswordResetEmail(String email);

  /// Hooks for Phone OTP authentication
  Future<void> sendPhoneOtp(String phoneNumber);
  Future<UserEntity> verifyPhoneOtp(String phoneNumber, String otpCode);

  /// Updates profile information including language, currency, and phone.
  Future<UserEntity> updateProfile({
    String? name,
    String? profileImage,
    String? preferredLanguage,
    String? preferredCurrency,
    String? phoneNumber,
  });

  /// Convenience hook to update language/currency preferences.
  Future<void> updatePreferences({
    String? preferredLanguage,
    String? preferredCurrency,
  });

  /// Retrieves the active cached authentication token.
  Future<String?> getCachedToken();

  /// Terminates the current session and clears cached data and tokens.
  Future<void> logout();
}
