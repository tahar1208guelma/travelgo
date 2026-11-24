import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final StorageService _storageService;
  final _uuid = const Uuid();

  AuthRepositoryImpl(this._storageService);

  @override
  Future<UserEntity?> getCurrentUser() async {
    final cached = _storageService.getCachedUser();
    if (cached != null) {
      final token = _storageService.getAuthToken();
      final user = UserModel.fromJson(cached);
      if (token != null && user.authToken == null) {
        return user.copyWith(authToken: token);
      }
      return user;
    }
    return null;
  }

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Network simulation
    if (password.length < 6) {
      throw ServerException(message: 'Invalid email or password');
    }

    final normalizedEmail = email.trim().toLowerCase();
    final role = normalizedEmail.contains('admin')
        ? UserRole.admin
        : (normalizedEmail.contains('partner') || normalizedEmail.contains('hotel'))
            ? UserRole.partner
            : UserRole.user;

    final token = 'token_usr_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode.abs()}';

    final user = UserModel(
      id: 'usr_${email.hashCode.abs()}',
      name: email.split('@').first.toUpperCase(),
      email: email.trim(),
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
      preferredLanguage: 'en',
      preferredCurrency: 'USD',
      role: role,
      isGuest: false,
      authToken: token,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );

    await _storageService.setAuthToken(token);
    await _storageService.setCachedUser(user.toJson());
    return user;
  }

  @override
  Future<UserEntity> registerWithEmail(
    String name,
    String email,
    String password, {
    UserRole role = UserRole.user,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (password.length < 6) {
      throw ValidationException(message: 'Password must be at least 6 characters long');
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      throw ValidationException(message: 'Please provide a valid email address');
    }

    // STRICT SECURITY GUARDRAIL: Public registration MUST NEVER grant admin privileges
    final safeRole = (role == UserRole.admin) ? UserRole.user : role;

    final token = 'token_reg_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 6)}';

    final user = UserModel(
      id: 'usr_${_uuid.v4().substring(0, 8)}',
      name: name.trim(),
      email: email.trim(),
      profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop',
      preferredLanguage: 'en',
      preferredCurrency: 'USD',
      role: safeRole,
      isGuest: false,
      authToken: token,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storageService.setAuthToken(token);
    await _storageService.setCachedUser(user.toJson());
    return user;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final token = 'token_google_${DateTime.now().millisecondsSinceEpoch}';

    final user = UserModel(
      id: 'usr_google_99218',
      name: 'Alex Johnson',
      email: 'alex.traveler@gmail.com',
      profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop',
      preferredLanguage: 'en',
      preferredCurrency: 'USD',
      role: UserRole.user,
      isGuest: false,
      authToken: token,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storageService.setAuthToken(token);
    await _storageService.setCachedUser(user.toJson());
    return user;
  }

  @override
  Future<UserEntity> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final token = 'token_apple_${DateTime.now().millisecondsSinceEpoch}';

    final user = UserModel(
      id: 'usr_apple_88192',
      name: 'Tahar Braknia',
      email: 'tahar.braknia@privaterelay.appleid.com',
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
      preferredLanguage: 'ar',
      preferredCurrency: 'USD',
      role: UserRole.user,
      isGuest: false,
      authToken: token,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storageService.setAuthToken(token);
    await _storageService.setCachedUser(user.toJson());
    return user;
  }

  @override
  Future<UserEntity> continueAsGuest() async {
    final guestToken = 'guest_token_${_uuid.v4().substring(0, 8)}';
    final guest = UserModel(
      id: 'guest_${_uuid.v4().substring(0, 6)}',
      name: 'Guest Traveler',
      email: 'guest@travelgo.app',
      profileImage: null,
      preferredLanguage: 'en',
      preferredCurrency: 'USD',
      role: UserRole.user,
      isGuest: true,
      authToken: guestToken,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storageService.setAuthToken(guestToken);
    await _storageService.setCachedUser(guest.toJson());
    return guest;
  }

  @override
  Future<void> sendPhoneOtp(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.length < 7) {
      throw ValidationException(message: 'Invalid phone number format');
    }
  }

  @override
  Future<UserEntity> verifyPhoneOtp(String phoneNumber, String otpCode) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanOtp = otpCode.trim();
    if (cleanOtp.length != 6 || int.tryParse(cleanOtp) == null) {
      throw ValidationException(message: 'Invalid verification code. Please enter 6 digits.');
    }

    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final suffix = cleanPhone.length > 4 ? cleanPhone.substring(cleanPhone.length - 4) : cleanPhone;
    final token = 'token_phone_${DateTime.now().millisecondsSinceEpoch}_${cleanPhone.hashCode.abs()}';

    final user = UserModel(
      id: 'usr_phone_${cleanPhone.hashCode.abs()}',
      name: 'Traveler $suffix',
      email: '$cleanPhone@phone.travelgo.app',
      phoneNumber: phoneNumber,
      profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop',
      preferredLanguage: 'en',
      preferredCurrency: 'USD',
      role: UserRole.user,
      isGuest: false,
      authToken: token,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storageService.setAuthToken(token);
    await _storageService.setCachedUser(user.toJson());
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.trim().isEmpty || !email.contains('@')) {
      throw ValidationException(message: 'Please enter a valid email address');
    }
  }

  @override
  Future<UserEntity> updateProfile({
    String? name,
    String? profileImage,
    String? preferredLanguage,
    String? preferredCurrency,
    String? phoneNumber,
  }) async {
    final current = await getCurrentUser();
    if (current == null) {
      throw ServerException(message: 'User session not found');
    }

    final updated = current.copyWith(
      name: name,
      profileImage: profileImage,
      preferredLanguage: preferredLanguage,
      preferredCurrency: preferredCurrency,
      phoneNumber: phoneNumber,
      updatedAt: DateTime.now(),
    );

    await _storageService.setCachedUser(UserModel.fromEntity(updated).toJson());
    return updated;
  }

  @override
  Future<void> updatePreferences({
    String? preferredLanguage,
    String? preferredCurrency,
  }) async {
    final current = await getCurrentUser();
    if (current != null) {
      await updateProfile(
        preferredLanguage: preferredLanguage,
        preferredCurrency: preferredCurrency,
      );
    }
  }

  @override
  Future<String?> getCachedToken() async {
    return _storageService.getAuthToken();
  }

  @override
  Future<void> logout() async {
    await _storageService.clearAuthSession();
  }
}
