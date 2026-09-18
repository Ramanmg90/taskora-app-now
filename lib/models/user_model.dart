class AppUser {
  final int? id;
  final String username;
  final String passwordHash;
  final String? email;
  final String? fullName;
  final String? bio;
  final String? phoneNumber;
  final String? avatarPath;
  final String themePreference; // 'light' | 'dark'
  final DateTime createdAt;

  AppUser({
    this.id,
    required this.username,
    required this.passwordHash,
    this.email,
    this.fullName,
    this.bio,
    this.phoneNumber,
    this.avatarPath,
    this.themePreference = 'light',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'password_hash': passwordHash,
        'email': email,
        'full_name': fullName,
        'bio': bio,
        'phone_number': phoneNumber,
        'avatar_path': avatarPath,
        'theme_preference': themePreference,
        'created_at': createdAt.toIso8601String(),
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as int?,
        username: map['username'] as String,
        passwordHash: map['password_hash'] as String,
        email: map['email'] as String?,
        fullName: map['full_name'] as String?,
        bio: map['bio'] as String?,
        phoneNumber: map['phone_number'] as String?,
        avatarPath: map['avatar_path'] as String?,
        themePreference: map['theme_preference'] as String? ?? 'light',
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  AppUser copyWith({
    String? email,
    String? fullName,
    String? bio,
    String? phoneNumber,
    String? avatarPath,
    String? themePreference,
  }) =>
      AppUser(
        id: id,
        username: username,
        passwordHash: passwordHash,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        bio: bio ?? this.bio,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        avatarPath: avatarPath ?? this.avatarPath,
        themePreference: themePreference ?? this.themePreference,
        createdAt: createdAt,
      );
}
