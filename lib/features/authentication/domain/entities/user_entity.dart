enum UserRole { user, admin }

class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String preferredLanguage;
  final String preferredCurrency;
  final UserRole role;
  final bool isGuest;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'USD',
    this.role = UserRole.user,
    this.isGuest = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserEntity copyWith({
    String? name,
    String? email,
    String? profileImage,
    String? preferredLanguage,
    String? preferredCurrency,
    UserRole? role,
    bool? isGuest,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      role: role ?? this.role,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
