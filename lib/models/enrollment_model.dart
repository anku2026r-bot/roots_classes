class EnrollmentModel {
  final String id;
  final String userId;
  final String itemId;
  final String itemType; // 'class' or 'test_series'
  final String title;
  final double pricePaid;
  final DateTime enrolledAt;
  final DateTime expiresAt;
  final String status; // 'active', 'expired', 'pending'

  const EnrollmentModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.title,
    required this.pricePaid,
    required this.enrolledAt,
    required this.expiresAt,
    this.status = 'active',
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      itemType: json['itemType'] as String? ?? 'class',
      title: json['title'] as String? ?? '',
      pricePaid: (json['pricePaid'] as num?)?.toDouble() ?? 0.0,
      enrolledAt: json['enrolledAt'] != null
          ? DateTime.tryParse(json['enrolledAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String) ?? DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 365)),
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'itemId': itemId,
    'itemType': itemType,
    'title': title,
    'pricePaid': pricePaid,
    'enrolledAt': enrolledAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'status': status,
  };
}
