import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.profileImage,
    super.preferredLanguage,
    super.preferredCurrency,
    super.role,
    super.isGuest,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      profileImage: json['profileImage'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      preferredCurrency: json['preferredCurrency'] as String? ?? 'USD',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.user,
      isGuest: json['isGuest'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'preferredLanguage': preferredLanguage,
      'preferredCurrency': preferredCurrency,
      'role': role == UserRole.admin ? 'admin' : 'user',
      'isGuest': isGuest,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      profileImage: entity.profileImage,
      preferredLanguage: entity.preferredLanguage,
      preferredCurrency: entity.preferredCurrency,
      role: entity.role,
      isGuest: entity.isGuest,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
