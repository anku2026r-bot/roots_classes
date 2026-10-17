import 'package:flutter/foundation.dart';
import '../models/class_model.dart';
import '../models/educational_video_model.dart';
import '../models/home_banner_model.dart';
import '../models/team_member_model.dart';
import '../services/classes_api_service.dart';
import '../services/home_api_service.dart';

class HomeController extends ChangeNotifier {
  final HomeApiService _homeApiService;
  final ClassesApiService _classesApiService;

  HomeController({
    required HomeApiService homeApiService,
    required ClassesApiService classesApiService,
  })  : _homeApiService = homeApiService,
        _classesApiService = classesApiService {
    // Instant pre-population for 0ms initial load
    _banners = _homeApiService.getDynamicBanners();
    _teamMembers = _homeApiService.getDynamicTeamMembers();
    _videos = _homeApiService.getDynamicVideos();
    _programs = _classesApiService.getDynamicClassesCatalog();
  }

  List<HomeBannerModel> _banners = [];
  List<TeamMemberModel> _teamMembers = [];
  List<EducationalVideoModel> _videos = [];
  List<ClassModel> _programs = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedProgramCategory = 'All';
  String _selectedVideoCategory = 'All';
  int _activeBannerIndex = 0;

  List<HomeBannerModel> get banners => _banners;
  List<TeamMemberModel> get teamMembers => _teamMembers;
  List<EducationalVideoModel> get videos => _videos;
  List<ClassModel> get programs => _programs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedProgramCategory => _selectedProgramCategory;
  String get selectedVideoCategory => _selectedVideoCategory;
  int get activeBannerIndex => _activeBannerIndex;

  List<ClassModel> get filteredPrograms {
    if (_selectedProgramCategory == 'All') {
      return _programs;
    }
    return _programs.where((p) => p.category == _selectedProgramCategory).toList();
  }

  List<EducationalVideoModel> get filteredVideos {
    if (_selectedVideoCategory == 'All') {
      return _videos;
    }
    return _videos
        .where((v) =>
            v.category == _selectedVideoCategory ||
            v.subject.toLowerCase() == _selectedVideoCategory.toLowerCase())
        .toList();
  }

  /// Initial fetch or refresh of all home sections (non-blocking when data is cached)
  Future<void> fetchHomeData({bool forceShowLoading = false}) async {
    if (forceShowLoading || (_banners.isEmpty && _programs.isEmpty)) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      final bannersFuture = _homeApiService.getBanners();
      final teamFuture = _homeApiService.getTeamMembers();
      final videosFuture = _homeApiService.getEducationalVideos(category: _selectedVideoCategory);
      final programsFuture = _classesApiService.getClasses();

      final results = await Future.wait([
        bannersFuture,
        teamFuture,
        videosFuture,
        programsFuture,
      ]);

      _banners = results[0] as List<HomeBannerModel>;
      _teamMembers = results[1] as List<TeamMemberModel>;
      _videos = results[2] as List<EducationalVideoModel>;
      _programs = results[3] as List<ClassModel>;
    } catch (e) {
      if (_banners.isEmpty && _programs.isEmpty) {
        _errorMessage = 'Could not load home page data. Please check connection.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActiveBannerIndex(int index) {
    if (_activeBannerIndex != index) {
      _activeBannerIndex = index;
      notifyListeners();
    }
  }

  void setProgramCategory(String category) {
    if (_selectedProgramCategory == category) return;
    _selectedProgramCategory = category;
    notifyListeners();
  }

  void setVideoCategory(String category) {
    if (_selectedVideoCategory == category) return;
    _selectedVideoCategory = category;
    notifyListeners();
  }

  Future<void> refreshHomeData() async {
    await fetchHomeData();
  }
}
