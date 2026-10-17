class TestItemModel {
  final String id;
  final String testSeriesId;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final int totalMarks;
  final double negativeMarking;
  final int passingMarks;
  final bool isFree;
  final bool isAttempted;
  final double? previousScore;
  final String? previousAttemptId;
  final String instructions;

  const TestItemModel({
    required this.id,
    required this.testSeriesId,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.totalMarks,
    this.negativeMarking = 1.0,
    this.passingMarks = 72,
    this.isFree = false,
    this.isAttempted = false,
    this.previousScore,
    this.previousAttemptId,
    this.instructions =
        '1. Total duration is specified in minutes.\n2. +4 marks for correct answer, -1 mark for wrong answer.\n3. Do not refresh or exit the app during the test.',
  });

  factory TestItemModel.fromJson(Map<String, dynamic> json) {
    return TestItemModel(
      id: json['id'] as String? ?? '',
      testSeriesId: json['testSeriesId'] as String? ?? '',
      title: json['title'] as String? ?? 'Mock Test',
      durationMinutes: json['durationMinutes'] as int? ?? 180,
      totalQuestions: json['totalQuestions'] as int? ?? 75,
      totalMarks: json['totalMarks'] as int? ?? 300,
      negativeMarking: (json['negativeMarking'] as num?)?.toDouble() ?? 1.0,
      passingMarks: json['passingMarks'] as int? ?? 72,
      isFree: json['isFree'] as bool? ?? false,
      isAttempted: json['isAttempted'] as bool? ?? false,
      previousScore: (json['previousScore'] as num?)?.toDouble(),
      previousAttemptId: json['previousAttemptId'] as String?,
      instructions: json['instructions'] as String? ??
          '1. Total duration is specified in minutes.\n2. +4 marks for correct answer, -1 mark for wrong answer.\n3. Do not refresh or exit the app during the test.',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'testSeriesId': testSeriesId,
    'title': title,
    'durationMinutes': durationMinutes,
    'totalQuestions': totalQuestions,
    'totalMarks': totalMarks,
    'negativeMarking': negativeMarking,
    'passingMarks': passingMarks,
    'isFree': isFree,
    'isAttempted': isAttempted,
    'previousScore': previousScore,
    'previousAttemptId': previousAttemptId,
    'instructions': instructions,
  };
}

class TestSeriesModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int numberOfTests;
  final int totalQuestions;
  final int totalMarks;
  final int durationMinutes;
  final double price;
  final double originalPrice;
  final bool isFree;
  final bool isPurchased;
  final bool isLocked;
  final double negativeMarking;
  final int attemptsCount;
  final List<TestItemModel> tests;

  const TestSeriesModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.numberOfTests,
    required this.totalQuestions,
    required this.totalMarks,
    required this.durationMinutes,
    required this.price,
    required this.originalPrice,
    this.isFree = false,
    this.isPurchased = false,
    this.isLocked = false,
    this.negativeMarking = 1.0,
    this.attemptsCount = 4200,
    this.tests = const [],
  });

  bool get canAccess => isFree || isPurchased || !isLocked;

  TestSeriesModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? numberOfTests,
    int? totalQuestions,
    int? totalMarks,
    int? durationMinutes,
    double? price,
    double? originalPrice,
    bool? isFree,
    bool? isPurchased,
    bool? isLocked,
    double? negativeMarking,
    int? attemptsCount,
    List<TestItemModel>? tests,
  }) {
    return TestSeriesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      numberOfTests: numberOfTests ?? this.numberOfTests,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalMarks: totalMarks ?? this.totalMarks,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      isFree: isFree ?? this.isFree,
      isPurchased: isPurchased ?? this.isPurchased,
      isLocked: isLocked ?? this.isLocked,
      negativeMarking: negativeMarking ?? this.negativeMarking,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      tests: tests ?? this.tests,
    );
  }

  factory TestSeriesModel.fromJson(Map<String, dynamic> json) {
    final String parsedId = (json['_id'] ?? json['id'] ?? '') as String;
    final String parsedTitle = (json['title'] ?? '') as String;
    final int parsedDuration = json['duration'] != null
        ? (json['duration'] as num).toInt()
        : (json['durationMinutes'] as int? ?? 180);
    final double parsedPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    final bool parsedIsPaid = json['isPaid'] as bool? ?? (parsedPrice > 0);

    return TestSeriesModel(
      id: parsedId,
      title: parsedTitle,
      description: json['description'] as String? ?? 'Full syllabus mock test series',
      category: (json['category'] ?? json['className'] ?? 'General') as String,
      numberOfTests: json['numberOfTests'] as int? ?? 10,
      totalQuestions: json['totalQuestions'] as int? ?? 75,
      totalMarks: json['totalMarks'] as int? ?? 300,
      durationMinutes: parsedDuration,
      price: parsedPrice,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? parsedPrice,
      isFree: !parsedIsPaid,
      isPurchased: json['isPurchased'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      negativeMarking: (json['negativeMarking'] as num?)?.toDouble() ?? 1.0,
      attemptsCount: json['attemptsCount'] as int? ?? 1500,
      tests: (json['tests'] as List<dynamic>?)
              ?.map((e) => TestItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [
            TestItemModel(
              id: parsedId,
              testSeriesId: parsedId,
              title: parsedTitle,
              durationMinutes: parsedDuration,
              totalQuestions: 75,
              totalMarks: 300,
              isFree: !parsedIsPaid,
            )
          ],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'numberOfTests': numberOfTests,
    'totalQuestions': totalQuestions,
    'totalMarks': totalMarks,
    'durationMinutes': durationMinutes,
    'price': price,
    'originalPrice': originalPrice,
    'isFree': isFree,
    'isPurchased': isPurchased,
    'isLocked': isLocked,
    'negativeMarking': negativeMarking,
    'attemptsCount': attemptsCount,
    'tests': tests.map((e) => e.toJson()).toList(),
  };
}
