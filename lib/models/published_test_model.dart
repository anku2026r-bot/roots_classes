class PublishedTestModel {
  final String id;
  final String title;
  final int duration; // in minutes
  final double passingPercentage;
  final String? className;
  final String? category;
  final String? difficulty;
  final bool isPaid;
  final double price;

  const PublishedTestModel({
    required this.id,
    required this.title,
    this.duration = 60,
    this.passingPercentage = 40.0,
    this.className,
    this.category,
    this.difficulty,
    this.isPaid = false,
    this.price = 0.0,
  });

  factory PublishedTestModel.fromJson(Map<String, dynamic> json) {
    return PublishedTestModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      duration: json['duration'] != null ? (json['duration'] as num).toInt() : 60,
      passingPercentage: json['passingPercentage'] != null
          ? (json['passingPercentage'] as num).toDouble()
          : 40.0,
      className: json['className'] as String?,
      category: json['category'] as String?,
      difficulty: json['difficulty'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'duration': duration,
      'passingPercentage': passingPercentage,
      'className': className,
      'category': category,
      'difficulty': difficulty,
      'isPaid': isPaid,
      'price': price,
    };
  }
}
