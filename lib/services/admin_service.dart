import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/admin_student_model.dart';
import '../models/user_model.dart';
import 'session_service.dart';

class AdminLoginResult {
  final bool isSuccess;
  final String? message;
  final UserModel? adminUser;
  final String? token;

  const AdminLoginResult({
    required this.isSuccess,
    this.message,
    this.adminUser,
    this.token,
  });
}

class AdminService {
  final ApiClient _apiClient;
  final SessionService _sessionService;

  AdminService(this._apiClient, this._sessionService);

  /// Authenticates an admin user (POST /admin/admin-login)
  Future<AdminLoginResult> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.adminLogin,
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (response is Map<String, dynamic>) {
        final success = response['success'] == true;
        if (!success) {
          return AdminLoginResult(
            isSuccess: false,
            message: response['message'] as String? ?? 'Admin login failed',
          );
        }

        final token = response['token'] as String?;
        final userJson = response['user'] as Map<String, dynamic>?;

        if (token != null && token.isNotEmpty) {
          final adminUser = userJson != null
              ? UserModel.fromJson(userJson)
              : UserModel(
                  id: 'admin_id',
                  name: 'Admin',
                  email: email,
                  role: 'admin',
                  createdAt: DateTime.now(),
                );

          await _sessionService.saveSession(
            token: token,
            userId: adminUser.id,
            rememberMe: true,
            email: adminUser.email,
          );

          return AdminLoginResult(
            isSuccess: true,
            message: response['message'] as String? ?? 'Login successful',
            adminUser: adminUser,
            token: token,
          );
        }
      }
      return const AdminLoginResult(
        isSuccess: false,
        message: 'Invalid response from admin auth endpoint',
      );
    } catch (e) {
      return AdminLoginResult(
        isSuccess: false,
        message: 'Failed to connect to admin server: $e',
      );
    }
  }

  /// Fetches all registered students (POST /admin/getall_student)
  Future<List<AdminStudentModel>> getAllStudents() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.adminGetAllStudents,
        body: {},
      );

      if (response is Map<String, dynamic> && response['data'] != null) {
        final List<dynamic> list = response['data'];
        return list
            .map((e) => AdminStudentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}

    return [];
  }
}
