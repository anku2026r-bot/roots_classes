class ApiConstants {
  ApiConstants._();

  /// Base URL for backend server (defaults to localhost:5050 per Backend API Guide)
  static String _baseUrl = 'http://localhost:5050';

  static String get baseUrl => _baseUrl;

  static set baseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _baseUrl = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  /// High-speed connection and receive timeouts (instant fallback, no slow hanging)
  static const Duration connectTimeout = Duration(milliseconds: 2500);
  static const Duration receiveTimeout = Duration(milliseconds: 3000);

  // ==========================================
  // 1. Authentication & Student Endpoints (7)
  // ==========================================
  static const String studentRegister = '/student/register';
  static const String studentLogin = '/student/login';
  static const String studentGoogleAuth = '/student/google-auth';
  static const String studentSendOtp = '/student/send-otp';
  static const String studentVerifyOtp = '/student/verify-otp';
  static const String studentResetPassword = '/student/reset-password';
  static const String studentGetProfile = '/student/get-student';

  // ==========================================
  // 2. Admin Endpoints (2)
  // ==========================================
  static const String adminLogin = '/admin/admin-login';
  static const String adminGetAllStudents = '/admin/getall_student';

  // ==========================================
  // 3. Courses Endpoints (2)
  // ==========================================
  static const String coursesApproved = '/course/get-approved-course';
  static const String courseDetailsById = '/course/get-course-by-id';

  // ==========================================
  // 4. Tests & Results Endpoints (3)
  // ==========================================
  static const String testsPublished = '/test/get_isPublish';
  static const String testStartSession = '/result/start-test';
  static const String testSubmitAndScore = '/result/submit_test';

  // ==========================================
  // 5. Payments & Purchases Endpoints (4)
  // ==========================================
  static const String paymentCreateOrder = '/payment/create-payment';
  static const String paymentVerify = '/payment/verify-payment';
  static const String paymentMyCourses = '/payment/get-my-course';
  static const String paymentPurchasedTests = '/payment/get-purchased-tests';

  // ==========================================
  // Legacy / UI Support Endpoints
  // ==========================================
  static const String classes = '/classes';
  static const String classDetails = '/classes/{id}';
  static const String enrollClass = '/classes/{id}/enroll';
  static const String testSeries = '/test-series';
  static const String testSeriesDetails = '/test-series/{id}';
  static const String testDetails = '/tests/{id}';
  static const String testQuestions = '/tests/{id}/questions';
  static const String submitTest = '/tests/{id}/submit';
  static const String testResult = '/tests/{id}/result/{attemptId}';
  static const String testAttempts = '/user/test-attempts';
  static const String userEnrollments = '/user/enrollments';
  static const String homeBanners = '/banners';
  static const String teamMembers = '/team';
  static const String educationalVideos = '/videos';

  // Exam Categories (Roots Classes Official Streams)
  static const List<String> categories = [
    'All',
    'Foundation (8-10)',
    'Medical (NEET)',
    'Engineering (JEE)',
    'Board Booster',
  ];
}
