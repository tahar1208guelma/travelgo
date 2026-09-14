import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Initialize storageService first in main.dart');
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

  Future<bool> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.registerWithEmail(name, email, password);
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

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile({String? name, String? profileImage}) async {
    try {
      final updated = await _repository.updateProfile(
        name: name,
        profileImage: profileImage,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
