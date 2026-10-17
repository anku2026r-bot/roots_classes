class EducatorModel {
  final String id;
  final String name;
  final String subject;
  final String experience;
  final String qualification;
  final String? avatarUrl;

  const EducatorModel({
    required this.id,
    required this.name,
    required this.subject,
    required this.experience,
    required this.qualification,
    this.avatarUrl,
  });

  factory EducatorModel.fromJson(Map<String, dynamic> json) {
    return EducatorModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Faculty Member',
      subject: json['subject'] as String? ?? 'Subject Expert',
      experience: json['experience'] as String? ?? '5+ Years',
      qualification: json['qualification'] as String? ?? 'M.Sc., B.Ed.',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subject': subject,
    'experience': experience,
    'qualification': qualification,
    'avatarUrl': avatarUrl,
  };
}

class LectureModel {
  final String id;
  final String title;
  final int durationMinutes;
  final bool isLive;
  final bool isCompleted;
  final String? videoUrl;
  final String? scheduledAt;

  const LectureModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
    this.isLive = false,
    this.isCompleted = false,
    this.videoUrl,
    this.scheduledAt,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Class Lecture',
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      isLive: json['isLive'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      videoUrl: json['videoUrl'] as String?,
      scheduledAt: json['scheduledAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'durationMinutes': durationMinutes,
    'isLive': isLive,
    'isCompleted': isCompleted,
    'videoUrl': videoUrl,
    'scheduledAt': scheduledAt,
  };
}

class StudyMaterialModel {
  final String id;
  final String title;
  final String fileType;
  final String fileSize;
  final String? downloadUrl;

  const StudyMaterialModel({
    required this.id,
    required this.title,
    this.fileType = 'PDF',
    this.fileSize = '2.4 MB',
    this.downloadUrl,
  });

  factory StudyMaterialModel.fromJson(Map<String, dynamic> json) {
    return StudyMaterialModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Lecture Notes',
      fileType: json['fileType'] as String? ?? 'PDF',
      fileSize: json['fileSize'] as String? ?? '2.4 MB',
      downloadUrl: json['downloadUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'fileType': fileType,
    'fileSize': fileSize,
    'downloadUrl': downloadUrl,
  };
}

class ClassModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final EducatorModel educator;
  final String validity;
  final double price;
  final double originalPrice;
  final bool isEnrolled;
  final double rating;
  final int totalStudents;
  final String? bannerUrl;
  final int liveClassesCount;
  final int recordedLecturesCount;
  final int studyMaterialsCount;
  final int testSeriesCount;
  final List<LectureModel> lectures;
  final List<StudyMaterialModel> materials;

  const ClassModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.educator,
    required this.validity,
    required this.price,
    required this.originalPrice,
    this.isEnrolled = false,
    this.rating = 4.8,
    this.totalStudents = 1250,
    this.bannerUrl,
    this.liveClassesCount = 45,
    this.recordedLecturesCount = 120,
    this.studyMaterialsCount = 35,
    this.testSeriesCount = 12,
    this.lectures = const [],
    this.materials = const [],
  });

  bool get isFree => price <= 0;

  ClassModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? category,
    EducatorModel? educator,
    String? validity,
    double? price,
    double? originalPrice,
    bool? isEnrolled,
    double? rating,
    int? totalStudents,
    String? bannerUrl,
    int? liveClassesCount,
    int? recordedLecturesCount,
    int? studyMaterialsCount,
    int? testSeriesCount,
    List<LectureModel>? lectures,
    List<StudyMaterialModel>? materials,
  }) {
    return ClassModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      category: category ?? this.category,
      educator: educator ?? this.educator,
      validity: validity ?? this.validity,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      rating: rating ?? this.rating,
      totalStudents: totalStudents ?? this.totalStudents,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      liveClassesCount: liveClassesCount ?? this.liveClassesCount,
      recordedLecturesCount: recordedLecturesCount ?? this.recordedLecturesCount,
      studyMaterialsCount: studyMaterialsCount ?? this.studyMaterialsCount,
      testSeriesCount: testSeriesCount ?? this.testSeriesCount,
      lectures: lectures ?? this.lectures,
      materials: materials ?? this.materials,
    );
  }

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? (json['description'] as String? ?? ''),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      educator: json['educator'] != null
          ? EducatorModel.fromJson(Map<String, dynamic>.from(json['educator']))
          : const EducatorModel(
              id: 'edu_1',
              name: 'Dr. R.K. Verma',
              subject: 'Physics',
              experience: '12+ Years',
              qualification: 'Ph.D. IIT Delhi',
            ),
      validity: json['validity'] as String? ?? '1 Year',
      price: (json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : (json['price'] as num?)?.toDouble() ?? 0.0),
      originalPrice: (json['price'] as num?)?.toDouble() ??
          ((json['discountPrice'] as num?)?.toDouble() ?? 0.0),
      isEnrolled: json['isEnrolled'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      totalStudents: json['totalStudents'] as int? ?? 850,
      bannerUrl: (json['thumbnail'] ?? json['bannerUrl']) as String?,
      liveClassesCount: json['liveClassesCount'] as int? ?? 30,
      recordedLecturesCount: json['recordedLecturesCount'] as int? ?? 100,
      studyMaterialsCount: json['studyMaterialsCount'] as int? ?? 25,
      testSeriesCount: json['testSeriesCount'] as int? ?? 10,
      lectures: (json['lectures'] as List<dynamic>?)
              ?.map((e) => LectureModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      materials: (json['materials'] as List<dynamic>?)
              ?.map((e) => StudyMaterialModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'category': category,
    'educator': educator.toJson(),
    'validity': validity,
    'price': price,
    'originalPrice': originalPrice,
    'isEnrolled': isEnrolled,
    'rating': rating,
    'totalStudents': totalStudents,
    'bannerUrl': bannerUrl,
    'liveClassesCount': liveClassesCount,
    'recordedLecturesCount': recordedLecturesCount,
    'studyMaterialsCount': studyMaterialsCount,
    'testSeriesCount': testSeriesCount,
    'lectures': lectures.map((e) => e.toJson()).toList(),
    'materials': materials.map((e) => e.toJson()).toList(),
  };
}
