import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/backend_course_model.dart';

class CourseService {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  static const String _keyCachedCourses = 'rc_cached_approved_courses';

  CourseService(this._apiClient, this._prefs);

  /// Fetches approved public courses (GET /course/get-approved-course)
  Future<List<BackendCourseModel>> getApprovedCourses({String? category}) async {
    try {
      final response = await _apiClient.get(ApiConstants.coursesApproved);

      if (response is Map<String, dynamic> && response['courses'] != null) {
        final List<dynamic> list = response['courses'];
        var courses = list
            .map((e) => BackendCourseModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        await _prefs.setString(_keyCachedCourses, jsonEncode(list));

        if (category != null && category.isNotEmpty && category != 'All') {
          courses = courses
              .where((c) => c.category?.toLowerCase() == category.toLowerCase())
              .toList();
        }
        return courses;
      }
    } catch (_) {
      final cachedRaw = _prefs.getString(_keyCachedCourses);
      if (cachedRaw != null && cachedRaw.isNotEmpty) {
        try {
          final List<dynamic> list = jsonDecode(cachedRaw);
          var courses = list
              .map((e) => BackendCourseModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          if (category != null && category.isNotEmpty && category != 'All') {
            courses = courses
                .where((c) => c.category?.toLowerCase() == category.toLowerCase())
                .toList();
          }
          return courses;
        } catch (_) {}
      }
    }

    return _getFallbackCourses(category: category);
  }

  /// Fetches course details by ID (POST /course/get-course-by-id)
  Future<BackendCourseModel?> getCourseById(String courseId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.courseDetailsById,
        body: {'courseId': courseId},
      );

      if (response is Map<String, dynamic> && response['course'] != null) {
        return BackendCourseModel.fromJson(
          Map<String, dynamic>.from(response['course']),
        );
      }
    } catch (_) {}

    final all = _getFallbackCourses();
    return all.firstWhere(
      (c) => c.id == courseId,
      orElse: () => all.first,
    );
  }

  List<BackendCourseModel> _getFallbackCourses({String? category}) {
    final list = [
      BackendCourseModel(
        id: 'course_neet_12',
        title: 'Complete Class 12 Physics Masterclass',
        description: 'Full syllabus coverage with mock tests and live doubts',
        price: 1499,
        discountPrice: 999,
        thumbnail: 'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?auto=format&fit=crop&w=800&q=80',
        category: 'Physics',
        isApproved: true,
        modules: const [
          CourseModuleModel(
            title: 'Electrostatics',
            chapters: [
              CourseChapterModel(
                title: 'Electric Charges and Fields',
                topics: [
                  CourseTopicModel(
                    title: "Coulomb's Law",
                    videoUrl: 'https://example.com/video',
                    notesUrl: 'https://example.com/notes.pdf',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      BackendCourseModel(
        id: 'course_jee_chem',
        title: 'JEE Advanced Organic Chemistry Accelerator',
        description: 'Master reaction mechanisms and problem-solving',
        price: 1999,
        discountPrice: 1299,
        thumbnail: 'https://images.unsplash.com/photo-1603126857599-f6e157fa2fe6?auto=format&fit=crop&w=800&q=80',
        category: 'Chemistry',
        isApproved: true,
      ),
      BackendCourseModel(
        id: 'course_maths_12',
        title: 'Calculus Mastery for Class 12 Boards & CUET',
        description: 'Complete limits, continuity, differentiability and integrals',
        price: 1299,
        discountPrice: 899,
        thumbnail: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=800&q=80',
        category: 'Mathematics',
        isApproved: true,
      ),
    ];

    if (category != null && category.isNotEmpty && category != 'All') {
      return list
          .where((c) => c.category?.toLowerCase() == category.toLowerCase())
          .toList();
    }
    return list;
  }
}
