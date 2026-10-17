class UserModel {
  final String id;
  final String name;
  final String email;
  final String? passwordHash;
  final String? salt;
  final bool isEmailVerified;
  final String? verificationCode;
  final String? resetToken;
  final DateTime? resetTokenExpiresAt;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String role;
  final String? avatarUrl;
  final String? phone;
  final String? currentClass;
  final String? interestedCourse;
  final String? gender;
  final String? address;
  final String? dateofBirth;
  final List<String> enrolledCourses;
  final List<String> purchasedTests;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.passwordHash,
    this.salt,
    this.isEmailVerified = false,
    this.verificationCode,
    this.resetToken,
    this.resetTokenExpiresAt,
    required this.createdAt,
    this.lastLoginAt,
    this.role = 'Student',
    this.avatarUrl,
    this.phone,
    this.currentClass,
    this.interestedCourse,
    this.gender,
    this.address,
    this.dateofBirth,
    this.enrolledCourses = const [],
    this.purchasedTests = const [],
  });

  /// Returns user model without sensitive hashes for UI consumption
  UserModel toSafeUser() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      passwordHash: null,
      salt: null,
      isEmailVerified: isEmailVerified,
      verificationCode: null,
      resetToken: null,
      resetTokenExpiresAt: null,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      role: role,
      avatarUrl: avatarUrl,
      phone: phone,
      currentClass: currentClass,
      interestedCourse: interestedCourse,
      gender: gender,
      address: address,
      dateofBirth: dateofBirth,
      enrolledCourses: enrolledCourses,
      purchasedTests: purchasedTests,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? salt,
    bool? isEmailVerified,
    String? verificationCode,
    String? resetToken,
    DateTime? resetTokenExpiresAt,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? role,
    String? avatarUrl,
    String? phone,
    String? currentClass,
    String? interestedCourse,
    String? gender,
    String? address,
    String? dateofBirth,
    List<String>? enrolledCourses,
    List<String>? purchasedTests,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      verificationCode: verificationCode ?? this.verificationCode,
      resetToken: resetToken ?? this.resetToken,
      resetTokenExpiresAt: resetTokenExpiresAt ?? this.resetTokenExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      currentClass: currentClass ?? this.currentClass,
      interestedCourse: interestedCourse ?? this.interestedCourse,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      dateofBirth: dateofBirth ?? this.dateofBirth,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      purchasedTests: purchasedTests ?? this.purchasedTests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'salt': salt,
      'isEmailVerified': isEmailVerified,
      'verificationCode': verificationCode,
      'resetToken': resetToken,
      'resetTokenExpiresAt': resetTokenExpiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'role': role,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'currentClass': currentClass,
      'interestedCourse': interestedCourse,
      'gender': gender,
      'address': address,
      'dateofBirth': dateofBirth,
      'enrolledCourses': enrolledCourses,
      'purchasedTests': purchasedTests,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return [];
    }

    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      name: (json['fullName'] ?? json['name'] ?? 'Student') as String,
      email: (json['email'] ?? '') as String,
      passwordHash: json['passwordHash'] as String?,
      salt: json['salt'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? true,
      verificationCode: json['verificationCode'] as String?,
      resetToken: json['resetToken'] as String?,
      resetTokenExpiresAt: json['resetTokenExpiresAt'] != null
          ? DateTime.tryParse(json['resetTokenExpiresAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'] as String)
          : null,
      role: (json['role'] ?? 'Student') as String,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      currentClass: (json['currentClass'] ?? json['className']) as String?,
      interestedCourse: json['interestedCourse'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      dateofBirth: json['dateofBirth'] as String?,
      enrolledCourses: parseStringList(json['enrolledCourses']),
      purchasedTests: parseStringList(json['purchasedTests']),
    );
  }
}
