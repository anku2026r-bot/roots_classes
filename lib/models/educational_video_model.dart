class EducationalVideoModel {
  final String id;
  final String title;
  final String subject;
  final String instructorName;
  final String duration;
  final int durationSeconds;
  final String? thumbnailUrl;
  final String? videoUrl;
  final int views;
  final String category;
  final String description;
  final List<String> topicsCovered;

  const EducationalVideoModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.instructorName,
    required this.duration,
    required this.durationSeconds,
    this.thumbnailUrl,
    this.videoUrl,
    this.views = 1500,
    required this.category,
    required this.description,
    this.topicsCovered = const [],
  });

  factory EducationalVideoModel.fromJson(Map<String, dynamic> json) {
    return EducationalVideoModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Educational Lecture',
      subject: json['subject'] as String? ?? 'General Science',
      instructorName: json['instructorName'] as String? ?? 'Faculty Member',
      duration: json['duration'] as String? ?? '15:00',
      durationSeconds: json['durationSeconds'] as int? ?? 900,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      views: json['views'] as int? ?? 1200,
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      topicsCovered: (json['topicsCovered'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'instructorName': instructorName,
    'duration': duration,
    'durationSeconds': durationSeconds,
    'thumbnailUrl': thumbnailUrl,
    'videoUrl': videoUrl,
    'views': views,
    'category': category,
    'description': description,
    'topicsCovered': topicsCovered,
  };
}
