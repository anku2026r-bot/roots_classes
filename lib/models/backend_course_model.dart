class BackendCourseModel {
  final String id;
  final String title;
  final String? description;
  final double price;
  final double discountPrice;
  final String? thumbnail;
  final String? category;
  final bool isApproved;
  final List<CourseModuleModel> modules;

  const BackendCourseModel({
    required this.id,
    required this.title,
    this.description,
    this.price = 0,
    this.discountPrice = 0,
    this.thumbnail,
    this.category,
    this.isApproved = true,
    this.modules = const [],
  });

  factory BackendCourseModel.fromJson(Map<String, dynamic> json) {
    var rawModules = json['modules'];
    List<CourseModuleModel> parsedModules = [];
    if (rawModules is List) {
      parsedModules = rawModules
          .map((m) => CourseModuleModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    return BackendCourseModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      price: (json['price'] != null ? (json['price'] as num).toDouble() : 0.0),
      discountPrice: (json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : (json['price'] != null ? (json['price'] as num).toDouble() : 0.0)),
      thumbnail: json['thumbnail'] as String?,
      category: json['category'] as String?,
      isApproved: json['isApproved'] as bool? ?? true,
      modules: parsedModules,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'thumbnail': thumbnail,
      'category': category,
      'isApproved': isApproved,
      'modules': modules.map((m) => m.toJson()).toList(),
    };
  }
}

class CourseModuleModel {
  final String title;
  final List<CourseChapterModel> chapters;

  const CourseModuleModel({
    required this.title,
    this.chapters = const [],
  });

  factory CourseModuleModel.fromJson(Map<String, dynamic> json) {
    var rawChapters = json['chapters'];
    List<CourseChapterModel> parsedChapters = [];
    if (rawChapters is List) {
      parsedChapters = rawChapters
          .map((c) => CourseChapterModel.fromJson(Map<String, dynamic>.from(c)))
          .toList();
    }

    return CourseModuleModel(
      title: (json['title'] ?? '') as String,
      chapters: parsedChapters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'chapters': chapters.map((c) => c.toJson()).toList(),
    };
  }
}

class CourseChapterModel {
  final String title;
  final List<CourseTopicModel> topics;

  const CourseChapterModel({
    required this.title,
    this.topics = const [],
  });

  factory CourseChapterModel.fromJson(Map<String, dynamic> json) {
    var rawTopics = json['topics'];
    List<CourseTopicModel> parsedTopics = [];
    if (rawTopics is List) {
      parsedTopics = rawTopics
          .map((t) => CourseTopicModel.fromJson(Map<String, dynamic>.from(t)))
          .toList();
    }

    return CourseChapterModel(
      title: (json['title'] ?? '') as String,
      topics: parsedTopics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'topics': topics.map((t) => t.toJson()).toList(),
    };
  }
}

class CourseTopicModel {
  final String title;
  final String? videoUrl;
  final String? notesUrl;

  const CourseTopicModel({
    required this.title,
    this.videoUrl,
    this.notesUrl,
  });

  factory CourseTopicModel.fromJson(Map<String, dynamic> json) {
    return CourseTopicModel(
      title: (json['title'] ?? '') as String,
      videoUrl: json['videoUrl'] as String?,
      notesUrl: json['notesUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'videoUrl': videoUrl,
      'notesUrl': notesUrl,
    };
  }
}
