enum UserRole {
  user,
  partner,
  admin;

  /// Alias for partner (hotel owner)
  static const UserRole hotelOwner = UserRole.partner;

  bool get isCustomer => this == UserRole.user;
  bool get isPartner => this == UserRole.partner;
  bool get isHotelOwner => this == UserRole.partner;
  bool get isAdmin => this == UserRole.admin;
}

class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final String preferredLanguage;
  final String preferredCurrency;
  final UserRole role;
  final bool isGuest;
  final String? authToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'USD',
    this.role = UserRole.user,
    this.isGuest = false,
    this.authToken,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role.isAdmin;
  bool get isPartner => role.isPartner;
  bool get isHotelOwner => role.isHotelOwner;
  bool get isCustomer => role.isCustomer;

  /// Role-based access control permission checks
  bool get canManageHotels => isAdmin || isPartner;
  bool get canAccessAdminPanel => isAdmin;
  bool get canManageCommission => isAdmin;

  UserEntity copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImage,
    String? preferredLanguage,
    String? preferredCurrency,
    UserRole? role,
    bool? isGuest,
    String? authToken,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      role: role ?? this.role,
      isGuest: isGuest ?? this.isGuest,
      authToken: authToken ?? this.authToken,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
