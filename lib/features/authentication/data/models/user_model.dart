import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,
    super.profileImage,
    super.preferredLanguage,
    super.preferredCurrency,
    super.role,
    super.isGuest,
    super.authToken,
    required super.createdAt,
    required super.updatedAt,
  });

  static UserRole parseRole(dynamic role) {
    if (role == null) return UserRole.user;
    if (role is UserRole) return role;
    final normalized = role.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    if (normalized == 'admin') return UserRole.admin;
    if (normalized == 'partner' || normalized == 'hotelowner') return UserRole.partner;
    return UserRole.user;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      preferredCurrency: json['preferredCurrency'] as String? ?? 'USD',
      role: parseRole(json['role']),
      isGuest: json['isGuest'] as bool? ?? false,
      authToken: json['authToken'] as String?,
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
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'preferredLanguage': preferredLanguage,
      'preferredCurrency': preferredCurrency,
      'role': role.name,
      'isGuest': isGuest,
      'authToken': authToken,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      profileImage: entity.profileImage,
      preferredLanguage: entity.preferredLanguage,
      preferredCurrency: entity.preferredCurrency,
      role: entity.role,
      isGuest: entity.isGuest,
      authToken: entity.authToken,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
