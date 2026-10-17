class AdminStudentModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final bool isBanned;
  final DateTime? createdAt;

  const AdminStudentModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.isBanned = false,
    this.createdAt,
  });

  factory AdminStudentModel.fromJson(Map<String, dynamic> json) {
    return AdminStudentModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      fullName: (json['fullName'] ?? json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: json['phone'] as String?,
      isBanned: json['isBanned'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'isBanned': isBanned,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
