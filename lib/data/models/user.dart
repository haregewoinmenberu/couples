class AppUser {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String countryCode;
  final String avatarSeed;
  final bool phoneVerified;
  final String? partnerId;
  final String? coupleId;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.countryCode,
    required this.avatarSeed,
    this.phoneVerified = false,
    this.partnerId,
    this.coupleId,
  });

  bool get hasPartner => partnerId != null && coupleId != null;

  AppUser copyWith({
    String? id,
    String? fullName,
    String? username,
    String? email,
    String? phoneNumber,
    String? countryCode,
    String? avatarSeed,
    bool? phoneVerified,
    String? partnerId,
    String? coupleId,
    bool clearPartner = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      partnerId: clearPartner ? null : (partnerId ?? this.partnerId),
      coupleId: clearPartner ? null : (coupleId ?? this.coupleId),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
        'avatarSeed': avatarSeed,
        'phoneVerified': phoneVerified,
        'partnerId': partnerId,
        'coupleId': coupleId,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        countryCode: json['countryCode'] as String,
        avatarSeed: json['avatarSeed'] as String,
        phoneVerified: json['phoneVerified'] as bool? ?? false,
        partnerId: json['partnerId'] as String?,
        coupleId: json['coupleId'] as String?,
      );
}
