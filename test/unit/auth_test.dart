import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelgo/core/errors/exceptions.dart';
import 'package:travelgo/core/services/storage_service.dart';
import 'package:travelgo/features/authentication/data/models/user_model.dart';
import 'package:travelgo/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:travelgo/features/authentication/domain/entities/user_entity.dart';
import 'package:travelgo/features/authentication/presentation/controllers/auth_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserRole & RBAC Entity Unit Tests', () {
    test('UserRole enum correctly distinguishes Customer, Partner, and Admin', () {
      expect(UserRole.user.isCustomer, isTrue);
      expect(UserRole.user.isPartner, isFalse);
      expect(UserRole.user.isAdmin, isFalse);

      expect(UserRole.partner.isCustomer, isFalse);
      expect(UserRole.partner.isPartner, isTrue);
      expect(UserRole.partner.isHotelOwner, isTrue);
      expect(UserRole.partner.isAdmin, isFalse);

      // Verify hotelOwner alias
      expect(UserRole.hotelOwner, equals(UserRole.partner));
      expect(UserRole.hotelOwner.isHotelOwner, isTrue);

      expect(UserRole.admin.isCustomer, isFalse);
      expect(UserRole.admin.isPartner, isFalse);
      expect(UserRole.admin.isAdmin, isTrue);
    });

    test('UserEntity permissions enforce access boundaries', () {
      final customer = UserEntity(
        id: 'u_1',
        name: 'Jane Customer',
        email: 'customer@test.com',
        role: UserRole.user,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(customer.canManageHotels, isFalse);
      expect(customer.canAccessAdminPanel, isFalse);
      expect(customer.canManageCommission, isFalse);

      final hotelPartner = UserEntity(
        id: 'p_1',
        name: 'Hotel Partner',
        email: 'partner@grandpalace.com',
        role: UserRole.partner,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(hotelPartner.canManageHotels, isTrue);
      expect(hotelPartner.canAccessAdminPanel, isFalse);
      expect(hotelPartner.canManageCommission, isFalse);

      final admin = UserEntity(
        id: 'a_1',
        name: 'System Admin',
        email: 'admin@travelgo.com',
        role: UserRole.admin,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(admin.canManageHotels, isTrue);
      expect(admin.canAccessAdminPanel, isTrue);
      expect(admin.canManageCommission, isTrue);
    });
  });

  group('UserModel Deserialization & Serialization Tests', () {
    test('Parses various role string formats safely', () {
      expect(UserModel.parseRole('admin'), equals(UserRole.admin));
      expect(UserModel.parseRole('ADMIN'), equals(UserRole.admin));
      expect(UserModel.parseRole('partner'), equals(UserRole.partner));
      expect(UserModel.parseRole('hotelOwner'), equals(UserRole.partner));
      expect(UserModel.parseRole('hotel_owner'), equals(UserRole.partner));
      expect(UserModel.parseRole('user'), equals(UserRole.user));
      expect(UserModel.parseRole('customer'), equals(UserRole.user));
      expect(UserModel.parseRole(null), equals(UserRole.user));
    });

    test('Serializes and deserializes UserModel with full fidelity', () {
      final now = DateTime(2026, 11, 24, 12, 0);
      final model = UserModel(
        id: 'usr_test_100',
        name: 'Test Partner',
        email: 'host@luxuryhotel.com',
        phoneNumber: '+15551234567',
        profileImage: 'https://images.unsplash.com/photo-1',
        preferredLanguage: 'ar',
        preferredCurrency: 'AED',
        role: UserRole.partner,
        isGuest: false,
        authToken: 'token_xyz_123',
        createdAt: now,
        updatedAt: now,
      );

      final json = model.toJson();
      expect(json['id'], 'usr_test_100');
      expect(json['role'], 'partner');
      expect(json['phoneNumber'], '+15551234567');
      expect(json['preferredLanguage'], 'ar');
      expect(json['preferredCurrency'], 'AED');
      expect(json['authToken'], 'token_xyz_123');

      final reconstructed = UserModel.fromJson(json);
      expect(reconstructed.id, model.id);
      expect(reconstructed.role, UserRole.partner);
      expect(reconstructed.isPartner, isTrue);
      expect(reconstructed.phoneNumber, '+15551234567');
      expect(reconstructed.preferredLanguage, 'ar');
      expect(reconstructed.preferredCurrency, 'AED');
      expect(reconstructed.authToken, 'token_xyz_123');
    });
  });

  group('AuthRepositoryImpl & Session Management Tests', () {
    late StorageService storageService;
    late AuthRepositoryImpl authRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
      authRepository = AuthRepositoryImpl(storageService);
    });

    test('Login with email caches user and session token', () async {
      final user = await authRepository.loginWithEmail('traveler@travelgo.com', 'password123');

      expect(user.email, 'traveler@travelgo.com');
      expect(user.role, UserRole.user);
      expect(user.authToken, isNotNull);

      // Verify session caching in StorageService
      final cachedUser = storageService.getCachedUser();
      expect(cachedUser, isNotNull);
      expect(cachedUser!['email'], 'traveler@travelgo.com');

      final cachedToken = storageService.getAuthToken();
      expect(cachedToken, isNotNull);
      expect(cachedToken, equals(user.authToken));

      final currentUser = await authRepository.getCurrentUser();
      expect(currentUser?.email, 'traveler@travelgo.com');
    });

    test('Login with invalid short password throws ServerException', () async {
      expect(
        () => authRepository.loginWithEmail('traveler@travelgo.com', '123'),
        throwsA(isA<ServerException>()),
      );
    });

    test('Public registration STRICTLY PREVENTS assigning admin privileges', () async {
      // Malicious attempt to register as admin
      final registered = await authRepository.registerWithEmail(
        'Hacker',
        'hacker@example.com',
        'securePassword123',
        role: UserRole.admin, // Attempting admin privilege
      );

      // Must be stripped to standard customer role!
      expect(registered.role, equals(UserRole.user));
      expect(registered.isAdmin, isFalse);
      expect(registered.role, isNot(UserRole.admin));

      // Check cache to verify no admin stored
      final cached = storageService.getCachedUser();
      expect(cached!['role'], equals('user'));
    });

    test('Public registration permits hotel owner / partner registration', () async {
      final partner = await authRepository.registerWithEmail(
        'Hotel Owner',
        'owner@resort.com',
        'resortPassword123',
        role: UserRole.partner,
      );

      expect(partner.role, equals(UserRole.partner));
      expect(partner.isPartner, isTrue);
      expect(partner.canManageHotels, isTrue);
    });

    test('Google Sign-In creates user and secure session', () async {
      final googleUser = await authRepository.signInWithGoogle();
      expect(googleUser.email, contains('@gmail.com'));
      expect(googleUser.role, UserRole.user);
      expect(storageService.getAuthToken(), isNotNull);
    });

    test('Apple Sign-In creates user and secure session', () async {
      final appleUser = await authRepository.signInWithApple();
      expect(appleUser.email, contains('appleid.com'));
      expect(appleUser.role, UserRole.user);
      expect(storageService.getAuthToken(), isNotNull);
    });

    test('Guest Mode creates guest session with isGuest = true', () async {
      final guest = await authRepository.continueAsGuest();
      expect(guest.isGuest, isTrue);
      expect(guest.role, UserRole.user);
      expect(storageService.getCachedUser()!['isGuest'], isTrue);
      expect(storageService.getAuthToken(), isNotNull);
    });

    test('Phone OTP hooks validate phone and OTP code correctly', () async {
      // Invalid short phone throws ValidationException
      expect(
        () => authRepository.sendPhoneOtp('123'),
        throwsA(isA<ValidationException>()),
      );

      // Valid phone does not throw
      await authRepository.sendPhoneOtp('+1 (555) 234-5678');

      // Invalid OTP code (not 6 digits) throws ValidationException
      expect(
        () => authRepository.verifyPhoneOtp('+15552345678', '12'),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => authRepository.verifyPhoneOtp('+15552345678', 'abcdef'),
        throwsA(isA<ValidationException>()),
      );

      // Valid 6-digit OTP logs in successfully
      final phoneUser = await authRepository.verifyPhoneOtp('+15552345678', '123456');
      expect(phoneUser.phoneNumber, '+15552345678');
      expect(phoneUser.isGuest, isFalse);
      expect(storageService.getAuthToken(), isNotNull);
    });

    test('Profile update and preference persistence', () async {
      await authRepository.loginWithEmail('traveler@travelgo.com', 'password123');

      final updated = await authRepository.updateProfile(
        name: 'Updated Traveler Name',
        phoneNumber: '+19998887777',
        preferredLanguage: 'ar',
        preferredCurrency: 'EUR',
      );

      expect(updated.name, 'Updated Traveler Name');
      expect(updated.phoneNumber, '+19998887777');
      expect(updated.preferredLanguage, 'ar');
      expect(updated.preferredCurrency, 'EUR');

      // Verify cached update
      final current = await authRepository.getCurrentUser();
      expect(current?.name, 'Updated Traveler Name');
      expect(current?.phoneNumber, '+19998887777');
      expect(current?.preferredLanguage, 'ar');
      expect(current?.preferredCurrency, 'EUR');
    });

    test('Logout clears cached user and session tokens', () async {
      await authRepository.loginWithEmail('traveler@travelgo.com', 'password123');
      expect(storageService.getCachedUser(), isNotNull);
      expect(storageService.getAuthToken(), isNotNull);

      await authRepository.logout();
      expect(storageService.getCachedUser(), isNull);
      expect(storageService.getAuthToken(), isNull);
      final current = await authRepository.getCurrentUser();
      expect(current, isNull);
    });
  });

  group('AuthController Riverpod Tests', () {
    late StorageService storageService;
    late AuthRepositoryImpl authRepository;
    late AuthController authController;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
      authRepository = AuthRepositoryImpl(storageService);
      authController = AuthController(authRepository);
    });

    test('AuthController manages state throughout authentication lifecycle', () async {
      // Initial state is null since cache is empty
      await authController.checkCurrentUser();
      expect(authController.currentUser, isNull);
      expect(authController.isAuthenticated, isFalse);

      // Login
      final loginSuccess = await authController.login('traveler@travelgo.com', 'password123');
      expect(loginSuccess, isTrue);
      expect(authController.currentUser, isNotNull);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.isGuest, isFalse);

      // Update profile
      await authController.updateProfile(name: 'New Name');
      expect(authController.currentUser?.name, 'New Name');

      // Logout
      await authController.logout();
      expect(authController.currentUser, isNull);
      expect(authController.isAuthenticated, isFalse);
    });
  });
}
