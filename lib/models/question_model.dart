class QuestionOptionModel {
  final String id;
  final String text;
  final String label; // A, B, C, D

  const QuestionOptionModel({
    required this.id,
    required this.text,
    required this.label,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'label': label,
  };
}

class QuestionModel {
  final String id;
  final String testId;
  final int questionNumber;
  final String section; // Physics, Chemistry, Mathematics, Biology, etc.
  final String questionText;
  final List<QuestionOptionModel> options;
  final int correctOptionIndex;
  final double marksPositive;
  final double marksNegative;
  final String explanation;
  final String? imageUrl;

  const QuestionModel({
    required this.id,
    required this.testId,
    required this.questionNumber,
    required this.section,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.marksPositive = 4.0,
    this.marksNegative = 1.0,
    required this.explanation,
    this.imageUrl,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String? ?? '',
      testId: json['testId'] as String? ?? '',
      questionNumber: json['questionNumber'] as int? ?? 1,
      section: json['section'] as String? ?? 'General',
      questionText: json['questionText'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => QuestionOptionModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      correctOptionIndex: json['correctOptionIndex'] as int? ?? 0,
      marksPositive: (json['marksPositive'] as num?)?.toDouble() ?? 4.0,
      marksNegative: (json['marksNegative'] as num?)?.toDouble() ?? 1.0,
      explanation: json['explanation'] as String? ?? 'No explanation provided.',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'testId': testId,
    'questionNumber': questionNumber,
    'section': section,
    'questionText': questionText,
    'options': options.map((e) => e.toJson()).toList(),
    'correctOptionIndex': correctOptionIndex,
    'marksPositive': marksPositive,
    'marksNegative': marksNegative,
    'explanation': explanation,
    'imageUrl': imageUrl,
  };
}
