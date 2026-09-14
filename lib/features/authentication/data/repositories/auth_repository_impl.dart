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
      return UserModel.fromJson(cached);
    }
    return null;
  }

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Network simulation
    if (password.length < 6) {
      throw ServerException(message: 'Invalid email or password');
    }

    final user = UserModel(
      id: 'usr_${email.hashCode.abs()}',
      name: email.split('@').first.toUpperCase(),
      email: email,
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
      preferredLanguage: 'en',
      preferredCurrency: 'USD',
      role: email.contains('admin') ? UserRole.admin : UserRole.user,
      isGuest: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );

    await _storageService.setCachedUser(user.toJson());
    return user;
  }

  @override
  Future<UserEntity> registerWithEmail(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final user = UserModel(
      id: 'usr_${_uuid.v4().substring(0, 8)}',
      name: name,
      email: email,
      profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop',
      preferredLanguage: 'en',
      preferredCurrency: 'USD',
      role: UserRole.user,
      isGuest: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storageService.setCachedUser(user.toJson());
    return user;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = UserModel(
      id: 'usr_google_99218',
      name: 'Alex Johnson',
      email: 'alex.traveler@gmail.com',
      profileImage: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop',
      preferredLanguage: 'en',
      preferredCurrency: 'USD',
      role: UserRole.user,
      isGuest: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storageService.setCachedUser(user.toJson());
    return user;
  }

  @override
  Future<UserEntity> continueAsGuest() async {
    final guest = UserModel(
      id: 'guest_${_uuid.v4().substring(0, 6)}',
      name: 'Guest Traveler',
      email: 'guest@travelgo.app',
      profileImage: null,
      preferredLanguage: 'en',
      preferredCurrency: 'USD',
      role: UserRole.user,
      isGuest: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _storageService.setCachedUser(guest.toJson());
    return guest;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserEntity> updateProfile({
    String? name,
    String? profileImage,
    String? preferredLanguage,
    String? preferredCurrency,
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
      updatedAt: DateTime.now(),
    );

    await _storageService.setCachedUser(UserModel.fromEntity(updated).toJson());
    return updated;
  }

  @override
  Future<void> logout() async {
    await _storageService.setCachedUser(null);
  }
}
