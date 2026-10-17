class QuestionAnalysisModel {
  final String questionId;
  final int questionNumber;
  final String section;
  final String questionText;
  final int? selectedOptionIndex; // null if unattempted
  final int correctOptionIndex;
  final bool isAttempted;
  final bool isCorrect;
  final double marksAwarded;
  final String explanation;
  final List<String> optionTexts;

  const QuestionAnalysisModel({
    required this.questionId,
    required this.questionNumber,
    required this.section,
    required this.questionText,
    this.selectedOptionIndex,
    required this.correctOptionIndex,
    required this.isAttempted,
    required this.isCorrect,
    required this.marksAwarded,
    required this.explanation,
    required this.optionTexts,
  });

  factory QuestionAnalysisModel.fromJson(Map<String, dynamic> json) {
    return QuestionAnalysisModel(
      questionId: json['questionId'] as String? ?? '',
      questionNumber: json['questionNumber'] as int? ?? 1,
      section: json['section'] as String? ?? 'General',
      questionText: json['questionText'] as String? ?? '',
      selectedOptionIndex: json['selectedOptionIndex'] as int?,
      correctOptionIndex: json['correctOptionIndex'] as int? ?? 0,
      isAttempted: json['isAttempted'] as bool? ?? false,
      isCorrect: json['isCorrect'] as bool? ?? false,
      marksAwarded: (json['marksAwarded'] as num?)?.toDouble() ?? 0.0,
      explanation: json['explanation'] as String? ?? '',
      optionTexts: (json['optionTexts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'questionNumber': questionNumber,
    'section': section,
    'questionText': questionText,
    'selectedOptionIndex': selectedOptionIndex,
    'correctOptionIndex': correctOptionIndex,
    'isAttempted': isAttempted,
    'isCorrect': isCorrect,
    'marksAwarded': marksAwarded,
    'explanation': explanation,
    'optionTexts': optionTexts,
  };
}

class TestResultModel {
  final String attemptId;
  final String testId;
  final String testTitle;
  final int totalQuestions;
  final int attemptedCount;
  final int correctCount;
  final int incorrectCount;
  final int unattemptedCount;
  final double totalScore;
  final int maxMarks;
  final double accuracyPercentage;
  final int timeTakenSeconds;
  final double percentile;
  final int rank;
  final int totalParticipants;
  final DateTime submittedAt;
  final List<QuestionAnalysisModel> questionsAnalysis;

  const TestResultModel({
    required this.attemptId,
    required this.testId,
    required this.testTitle,
    required this.totalQuestions,
    required this.attemptedCount,
    required this.correctCount,
    required this.incorrectCount,
    required this.unattemptedCount,
    required this.totalScore,
    required this.maxMarks,
    required this.accuracyPercentage,
    required this.timeTakenSeconds,
    this.percentile = 92.4,
    this.rank = 48,
    this.totalParticipants = 650,
    required this.submittedAt,
    this.questionsAnalysis = const [],
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    return TestResultModel(
      attemptId: json['attemptId'] as String? ?? '',
      testId: json['testId'] as String? ?? '',
      testTitle: json['testTitle'] as String? ?? 'Mock Test',
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      attemptedCount: json['attemptedCount'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      incorrectCount: json['incorrectCount'] as int? ?? 0,
      unattemptedCount: json['unattemptedCount'] as int? ?? 0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      maxMarks: json['maxMarks'] as int? ?? 100,
      accuracyPercentage: (json['accuracyPercentage'] as num?)?.toDouble() ?? 0.0,
      timeTakenSeconds: json['timeTakenSeconds'] as int? ?? 0,
      percentile: (json['percentile'] as num?)?.toDouble() ?? 92.4,
      rank: json['rank'] as int? ?? 1,
      totalParticipants: json['totalParticipants'] as int? ?? 100,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      questionsAnalysis: (json['questionsAnalysis'] as List<dynamic>?)
              ?.map((e) => QuestionAnalysisModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'attemptId': attemptId,
    'testId': testId,
    'testTitle': testTitle,
    'totalQuestions': totalQuestions,
    'attemptedCount': attemptedCount,
    'correctCount': correctCount,
    'incorrectCount': incorrectCount,
    'unattemptedCount': unattemptedCount,
    'totalScore': totalScore,
    'maxMarks': maxMarks,
    'accuracyPercentage': accuracyPercentage,
    'timeTakenSeconds': timeTakenSeconds,
    'percentile': percentile,
    'rank': rank,
    'totalParticipants': totalParticipants,
    'submittedAt': submittedAt.toIso8601String(),
    'questionsAnalysis': questionsAnalysis.map((e) => e.toJson()).toList(),
  };
}
