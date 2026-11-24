import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(storage);
});

final authStateProvider = StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    checkCurrentUser();
  }

  UserEntity? get currentUser => state.value;
  bool get isAuthenticated => state.value != null && !(state.value?.isGuest ?? false);
  bool get isGuest => state.value?.isGuest ?? true;
  bool get isAdmin => state.value?.isAdmin ?? false;
  bool get isPartner => state.value?.isPartner ?? false;

  Future<void> checkCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginWithEmail(email, password);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password, {
    UserRole role = UserRole.user,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.registerWithEmail(name, email, password, role: role);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInWithGoogle();
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInWithApple();
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> continueAsGuest() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.continueAsGuest();
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> sendPhoneOtp(String phoneNumber) async {
    try {
      await _repository.sendPhoneOtp(phoneNumber);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> verifyPhoneOtp(String phoneNumber, String otpCode) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.verifyPhoneOtp(phoneNumber, otpCode);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? profileImage,
    String? preferredLanguage,
    String? preferredCurrency,
    String? phoneNumber,
  }) async {
    try {
      final updated = await _repository.updateProfile(
        name: name,
        profileImage: profileImage,
        preferredLanguage: preferredLanguage,
        preferredCurrency: preferredCurrency,
        phoneNumber: phoneNumber,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateLanguagePreference(String languageCode) async {
    await updateProfile(preferredLanguage: languageCode);
  }

  Future<void> updateCurrencyPreference(String currencyCode) async {
    await updateProfile(preferredCurrency: currencyCode);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
