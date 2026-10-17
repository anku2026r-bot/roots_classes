import 'package:flutter/foundation.dart';
import '../models/class_model.dart';
import '../models/enrollment_model.dart';
import '../services/classes_api_service.dart';

class ClassesController extends ChangeNotifier {
  final ClassesApiService _apiService;

  ClassesController({required ClassesApiService apiService})
      : _apiService = apiService {
    // Instant pre-population for 0ms page load
    _classes = _apiService.getDynamicClassesCatalog();
  }

  List<ClassModel> _classes = [];
  List<EnrollmentModel> _userEnrollments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<ClassModel> get classes => _classes;
  List<EnrollmentModel> get userEnrollments => _userEnrollments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Fetches classes list dynamically in parallel with instant fallback
  Future<void> fetchClasses({bool forceShowLoading = false}) async {
    if (forceShowLoading || _classes.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      final results = await Future.wait([
        _apiService.getClasses(
          category: _selectedCategory,
          search: _searchQuery,
        ),
        _apiService.getUserEnrollments(),
      ]);
      _classes = results[0] as List<ClassModel>;
      _userEnrollments = results[1] as List<EnrollmentModel>;
    } catch (e) {
      if (_classes.isEmpty) {
        _errorMessage = 'Failed to load classes: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchClasses();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchClasses();
  }

  /// Enrolls or buys a class
  Future<bool> enrollClass(String classId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.enrollClass(classId);
      if (success) {
        // Refresh classes state
        _classes = await _apiService.getClasses(
          category: _selectedCategory,
          search: _searchQuery,
        );
        _userEnrollments = await _apiService.getUserEnrollments();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Enrollment failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
