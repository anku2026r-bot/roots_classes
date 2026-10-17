class TestSessionModel {
  final String attemptId;
  final String studentId;
  final String testId;
  final DateTime? testStartTime;
  final bool isCompleted;

  const TestSessionModel({
    required this.attemptId,
    required this.studentId,
    required this.testId,
    this.testStartTime,
    this.isCompleted = false,
  });

  factory TestSessionModel.fromJson(Map<String, dynamic> json) {
    return TestSessionModel(
      attemptId: (json['_id'] ?? json['attemptId'] ?? '') as String,
      studentId: (json['studentId'] ?? '') as String,
      testId: (json['testId'] ?? '') as String,
      testStartTime: json['testStartTime'] != null
          ? DateTime.tryParse(json['testStartTime'].toString())
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': attemptId,
      'studentId': studentId,
      'testId': testId,
      'testStartTime': testStartTime?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}

class TestSubmissionResultModel {
  final String attemptId;
  final String studentId;
  final String testId;
  final double totalMarks;
  final double obtainedMarks;
  final double percentage;
  final bool isEligible;
  final bool isCompleted;
  final DateTime? attemptDate;

  const TestSubmissionResultModel({
    required this.attemptId,
    required this.studentId,
    required this.testId,
    this.totalMarks = 0.0,
    this.obtainedMarks = 0.0,
    this.percentage = 0.0,
    this.isEligible = false,
    this.isCompleted = true,
    this.attemptDate,
  });

  factory TestSubmissionResultModel.fromJson(Map<String, dynamic> json) {
    return TestSubmissionResultModel(
      attemptId: (json['_id'] ?? json['attemptId'] ?? '') as String,
      studentId: (json['studentId'] ?? '') as String,
      testId: (json['testId'] ?? '') as String,
      totalMarks: json['totalMarks'] != null
          ? (json['totalMarks'] as num).toDouble()
          : 0.0,
      obtainedMarks: json['obtainedMarks'] != null
          ? (json['obtainedMarks'] as num).toDouble()
          : 0.0,
      percentage: json['percentage'] != null
          ? (json['percentage'] as num).toDouble()
          : 0.0,
      isEligible: json['isEligible'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? true,
      attemptDate: json['attemptDate'] != null
          ? DateTime.tryParse(json['attemptDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': attemptId,
      'studentId': studentId,
      'testId': testId,
      'totalMarks': totalMarks,
      'obtainedMarks': obtainedMarks,
      'percentage': percentage,
      'isEligible': isEligible,
      'isCompleted': isCompleted,
      'attemptDate': attemptDate?.toIso8601String(),
    };
  }
}
