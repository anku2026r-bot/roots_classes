import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/test_attempt_model.dart';
import '../models/test_series_model.dart';
import '../services/test_series_api_service.dart';

class TestSeriesController extends ChangeNotifier {
  final TestSeriesApiService _apiService;

  TestSeriesController({required TestSeriesApiService apiService})
      : _apiService = apiService {
    // Instant pre-population for 0ms page load
    _testSeriesList = _apiService.getDynamicTestSeriesCatalog();
  }

  List<TestSeriesModel> _testSeriesList = [];
  List<TestResultModel> _userAttempts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // CBT Exam Execution State
  TestItemModel? _activeTest;
  List<QuestionModel> _activeQuestions = [];
  int _currentQuestionIndex = 0;
  final Map<String, int> _userAnswers = {}; // questionId -> optionIndex
  final Set<String> _markedForReview = {};
  int _remainingTimeSeconds = 0;
  int _totalDurationSeconds = 0;
  Timer? _examTimer;
  bool _isSubmitting = false;
  TestResultModel? _lastResult;

  // Getters
  List<TestSeriesModel> get testSeriesList => _testSeriesList;
  List<TestResultModel> get userAttempts => _userAttempts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  TestItemModel? get activeTest => _activeTest;
  List<QuestionModel> get activeQuestions => _activeQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, int> get userAnswers => _userAnswers;
  Set<String> get markedForReview => _markedForReview;
  int get remainingTimeSeconds => _remainingTimeSeconds;
  int get totalDurationSeconds => _totalDurationSeconds;
  bool get isSubmitting => _isSubmitting;
  TestResultModel? get lastResult => _lastResult;

  QuestionModel? get currentQuestion =>
      _activeQuestions.isNotEmpty && _currentQuestionIndex < _activeQuestions.length
          ? _activeQuestions[_currentQuestionIndex]
          : null;

  /// Fetches test series list in parallel with instant fallback
  Future<void> fetchTestSeries({bool forceShowLoading = false}) async {
    if (forceShowLoading || _testSeriesList.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      final results = await Future.wait([
        _apiService.getTestSeries(
          category: _selectedCategory,
          search: _searchQuery,
        ),
        _apiService.getUserTestAttempts(),
      ]);
      _testSeriesList = results[0] as List<TestSeriesModel>;
      _userAttempts = results[1] as List<TestResultModel>;
    } catch (e) {
      if (_testSeriesList.isEmpty) {
        _errorMessage = 'Failed to load test series: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchTestSeries();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchTestSeries();
  }

  /// Purchase or unlock a test series
  Future<bool> unlockTestSeries(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.purchaseTestSeries(id);
      if (success) {
        await fetchTestSeries();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Unlock failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Starts a live CBT exam for a given test item
  Future<bool> startExam(TestItemModel test) async {
    _isLoading = true;
    _activeTest = test;
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _markedForReview.clear();
    _lastResult = null;
    notifyListeners();

    try {
      _activeQuestions = await _apiService.getTestQuestions(test.id);
      _totalDurationSeconds = test.durationMinutes * 60;
      _remainingTimeSeconds = _totalDurationSeconds;

      _startTimer();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to load questions: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _startTimer() {
    _examTimer?.cancel();
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeSeconds <= 1) {
        _remainingTimeSeconds = 0;
        timer.cancel();
        notifyListeners();
        // Auto-submit when time expires
        submitExam();
      } else {
        _remainingTimeSeconds--;
        notifyListeners();
      }
    });
  }

  void selectAnswer(String questionId, int optionIndex) {
    _userAnswers[questionId] = optionIndex;
    notifyListeners();
  }

  void clearAnswer(String questionId) {
    _userAnswers.remove(questionId);
    notifyListeners();
  }

  void toggleMarkForReview(String questionId) {
    if (_markedForReview.contains(questionId)) {
      _markedForReview.remove(questionId);
    } else {
      _markedForReview.add(questionId);
    }
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _activeQuestions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _activeQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Submits the CBT test
  Future<TestResultModel?> submitExam() async {
    if (_activeTest == null) return null;
    _examTimer?.cancel();
    _isSubmitting = true;
    notifyListeners();

    final timeTaken = _totalDurationSeconds - _remainingTimeSeconds;

    try {
      final result = await _apiService.submitTest(
        testId: _activeTest!.id,
        testTitle: _activeTest!.title,
        answers: _userAnswers,
        timeTakenSeconds: timeTaken,
      );

      _lastResult = result;
      _userAttempts = await _apiService.getUserTestAttempts();
      return result;
    } catch (e) {
      _errorMessage = 'Submission failed: $e';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    super.dispose();
  }
}
