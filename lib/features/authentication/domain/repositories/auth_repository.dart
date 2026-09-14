import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> loginWithEmail(String email, String password);
  Future<UserEntity> registerWithEmail(String name, String email, String password);
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> continueAsGuest();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserEntity> updateProfile({String? name, String? profileImage, String? preferredLanguage, String? preferredCurrency});
  Future<void> logout();
}
