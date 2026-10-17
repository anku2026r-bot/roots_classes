import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/educational_video_model.dart';
import '../models/home_banner_model.dart';
import '../models/team_member_model.dart';

class HomeApiService {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  static const String _keyLastVideoCategory = 'rc_last_video_category';

  HomeApiService(this._apiClient, this._prefs);

  /// Saves the last selected video category preference
  Future<void> savePreferredVideoCategory(String category) async {
    await _prefs.setString(_keyLastVideoCategory, category);
  }

  /// Gets the last selected video category preference
  String? getPreferredVideoCategory() {
    return _prefs.getString(_keyLastVideoCategory);
  }

  /// Pre-seeded instant initial banners
  List<HomeBannerModel> getDynamicBanners() => _getDynamicBanners();

  /// Pre-seeded instant initial faculty team
  List<TeamMemberModel> getDynamicTeamMembers() => _getDynamicTeamMembers();

  /// Pre-seeded instant initial educational videos
  List<EducationalVideoModel> getDynamicVideos({String? category}) =>
      _getDynamicEducationalVideos(category: category);

  /// Fetches home hero banners from API with offline dynamic fallback
  Future<List<HomeBannerModel>> getBanners() async {
    try {
      final response = await _apiClient.get(ApiConstants.homeBanners);
      final List<dynamic> data = response is Map && response['data'] != null
          ? response['data']
          : (response is List ? response : []);

      if (data.isNotEmpty) {
        return data
            .map((e) => HomeBannerModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // API offline fallback to dynamic catalog
    }
    return _getDynamicBanners();
  }

  /// Fetches faculty and leadership team members from API with offline fallback
  Future<List<TeamMemberModel>> getTeamMembers() async {
    try {
      final response = await _apiClient.get(ApiConstants.teamMembers);
      final List<dynamic> data = response is Map && response['data'] != null
          ? response['data']
          : (response is List ? response : []);

      if (data.isNotEmpty) {
        return data
            .map((e) => TeamMemberModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // API offline fallback
    }
    return _getDynamicTeamMembers();
  }

  /// Fetches free watch-to-learn educational lectures and masterclasses
  Future<List<EducationalVideoModel>> getEducationalVideos({String? category}) async {
    try {
      final query = <String, dynamic>{};
      if (category != null && category != 'All') query['category'] = category;

      final response = await _apiClient.get(
        ApiConstants.educationalVideos,
        queryParameters: query,
      );

      final List<dynamic> data = response is Map && response['data'] != null
          ? response['data']
          : (response is List ? response : []);

      if (data.isNotEmpty) {
        return data
            .map((e) => EducationalVideoModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      // API offline fallback
    }
    return _getDynamicEducationalVideos(category: category);
  }

  List<HomeBannerModel> _getDynamicBanners() {
    return const [
      HomeBannerModel(
        id: 'banner_roots_01',
        title: '100 दिनों में करें Board की तैयारी',
        subtitle: 'Percentage Booster Course',
        tag: 'ADMISSION OPEN',
        ctaText: 'Enroll in Booster Course',
        secondaryCtaText: 'Call 98775-15330',
        phone: '98775-15330',
        discountText: 'DISCOUNT UP TO 40% OFF',
        targetClass: 'Class: 10th & 12th',
        bannerType: 'booster_100_days',
        stats: ['Class: 10th & 12th', '10,000+ Enrolled', '98% Selection Rate'],
      ),
      HomeBannerModel(
        id: 'banner_roots_02',
        title: 'Master the Roots, Rule the Results.',
        subtitle: 'Class 9-12 • Foundation • NEET • JEE | Physics • Chemistry • Maths • Biology',
        tag: 'ROOTS CLASSES',
        ctaText: 'Explore All Courses',
        secondaryCtaText: 'Apply 100% Scholarship',
        phone: '98775-15330',
        targetClass: 'Class 9-12 • NEET • JEE',
        bannerType: 'roots_flagship',
        stats: ['Physics | Chemistry | Maths', '50+ Expert Faculty', '10+ Years Excellence'],
      ),
      HomeBannerModel(
        id: 'banner_roots_03',
        title: 'Board की तैयारी अब होगी Smart और Strong!',
        subtitle: 'Percentage Booster Course',
        tag: 'FOR SERIOUS STUDENTS ONLY!',
        ctaText: 'Start Learning Free',
        secondaryCtaText: 'Helpline: 98775-15330',
        phone: '98775-15330',
        targetClass: 'Class 10th & 12th Boards',
        bannerType: 'smart_and_strong',
        stats: ['NCERT Line By Line', 'Concept Clearing', 'Practice & PYQs', 'Score Higher'],
      ),
    ];
  }

  List<TeamMemberModel> _getDynamicTeamMembers() {
    return const [
      TeamMemberModel(
        id: 'team_akash',
        name: 'Akash Sir',
        designation: 'Faculty - Physics & Chemistry',
        subject: 'Physics & Chemistry',
        experience: '5+ Years',
        qualification: 'M.Sc. Physics, Gold Medalist',
        bio:
            'Knowledge can change the world. Let\'s build yours — one concept at a time. Celebrated for high-yield board problem hacks.',
        expertiseTags: ['Physics & Chemistry', 'Board Preparation', 'Concept Mastery'],
        rating: 5.0,
        studentsMentored: 12000,
      ),
      TeamMemberModel(
        id: 'team_maths_maam',
        name: 'Maths ma\'am',
        designation: 'Lead Faculty - Mathematics',
        subject: 'Mathematics',
        experience: '5+ Years',
        qualification: 'M.Sc. Mathematics, B.Ed.',
        bio:
            'Maths is easy. Proven pedagogy turning complex algebraic and calculus questions into intuitive steps for 95%+ marks.',
        expertiseTags: ['Mathematics', 'Board Strategy', 'NCERT Solutions'],
        rating: 5.0,
        studentsMentored: 11500,
      ),
      TeamMemberModel(
        id: 'team_01',
        name: 'Prof. Alok Aggarwal',
        designation: 'Head of Physics & Academic Director',
        subject: 'Physics & Advanced Mechanics',
        experience: '14+ Years',
        qualification: 'B.Tech IIT Kanpur',
        bio:
            'Celebrated physics mentor who has guided over 500+ students into top IITs. Known for intuitive derivations and problem visualization tricks.',
        expertiseTags: ['Rotational Dynamics', 'Electromagnetism', 'Optics'],
        rating: 4.9,
        studentsMentored: 18000,
      ),
      TeamMemberModel(
        id: 'team_02',
        name: 'Dr. Shweta Kashyap',
        designation: 'Dean of Medical Faculty',
        subject: 'Botany & Human Physiology',
        experience: '11+ Years',
        qualification: 'MBBS, AIIMS New Delhi',
        bio:
            'Medical practitioner turned educator specializing in high-retention biology mnemonics and 3D organ system animations.',
        expertiseTags: ['Genetics', 'Human Physiology', 'Cell Biology'],
        rating: 4.9,
        studentsMentored: 14500,
      ),
    ];
  }

  List<EducationalVideoModel> _getDynamicEducationalVideos({String? category}) {
    const list = [
      EducationalVideoModel(
        id: 'vid_roots_01',
        title: 'Meet the 3rd District Topper | Class 10th CBSE 99.2% Celebration',
        subject: 'Board Strategy',
        instructorName: 'Roots Classes Team',
        duration: '15:20',
        durationSeconds: 920,
        views: 28400,
        category: 'All',
        description:
            'Heartwarming celebration and strategy discussion with 3rd District Topper who scored 99.2% in Class 10th CBSE Board.',
        topicsCovered: [
          'Daily Study Routine',
          'How to Master NCERT',
          'Exam Day Time Management',
          'Revision & Mock Test Strategy',
        ],
      ),
      EducationalVideoModel(
        id: 'vid_roots_02',
        title: 'जानिए आख़िर कैसे लिखते हैं Toppers 🔥 | Average to Topper Journey',
        subject: 'Topper Strategy',
        instructorName: 'Akash Sir',
        duration: '12:45',
        durationSeconds: 765,
        views: 34100,
        category: 'All',
        description:
            'In-depth breakdown of answer presentation techniques, step marking advantages, and how average students score 95%+ in boards.',
        topicsCovered: [
          'Step-Wise Answer Presentation',
          'Diagram Presentation Rules',
          'Common Board Exam Mistakes',
          'PYQ Solving Shortcuts',
        ],
      ),
      EducationalVideoModel(
        id: 'vid_roots_03',
        title: 'How to Plan for CBSE Boards Exam & Strategy? अभी तक कुछ नहीं पढ़ा?',
        subject: 'Class 10th/12th',
        instructorName: 'Maths ma\'am',
        duration: '18:10',
        durationSeconds: 1090,
        views: 41200,
        category: 'All',
        description:
            'Zero to Hero study blueprint for Class 10th and 12th students. 100-Day Percentage Booster roadmap explained.',
        topicsCovered: [
          'High Weightage Chapter Priority',
          'NCERT Line By Line Breakdown',
          'Previous 10 Years Question Solving',
          'Formula Cheat Sheets',
        ],
      ),
      EducationalVideoModel(
        id: 'vid_roots_04',
        title: 'JEE Mains | Failure to Success Story & Comeback Strategy',
        subject: 'JEE (Main + Adv)',
        instructorName: 'Akash Sir',
        duration: '16:30',
        durationSeconds: 990,
        views: 22800,
        category: 'JEE (Main + Adv)',
        description:
            'Inspiring real journey of an engineering aspirant transforming low mock scores into 99+ percentile in JEE Mains.',
        topicsCovered: [
          'Overcoming Exam Anxiety',
          'Mock Test Analysis Protocol',
          'Physics & Chemistry Scoring Hacks',
        ],
      ),
      EducationalVideoModel(
        id: 'vid_02',
        title: 'Human Cardiac Cycle & ECG Line Diagram Decoded',
        subject: 'Biology',
        instructorName: 'Dr. Shweta Kashyap',
        duration: '32:10',
        durationSeconds: 1930,
        views: 31200,
        category: 'NEET',
        description:
            'High-yield NCERT biology lecture explaining atrial and ventricular systole, P-Q-R-S-T waves, heart sounds, and clinical questions.',
        topicsCovered: [
          'Phases of Cardiac Cycle',
          'ECG Waves Interpretation',
          'Heart Sounds (Lub-Dub)',
          'High Frequency NEET Questions',
        ],
      ),
      EducationalVideoModel(
        id: 'vid_03',
        title: 'Organic Chemistry: Sn1 vs Sn2 Mechanism Masterclass',
        subject: 'Chemistry',
        instructorName: 'Dr. Vivek Sengupta',
        duration: '24:18',
        durationSeconds: 1458,
        views: 19800,
        category: 'JEE (Main + Adv)',
        description:
            'Never get confused between substitution and elimination. Detailed solvent effects, carbocation stability, and stereochemical inversion.',
        topicsCovered: [
          'Carbocation Intermediate vs Transition State',
          'Walden Inversion in Sn2',
          'Solvent Protic vs Aprotic Impact',
          'Tricky Rearrangements',
        ],
      ),
      EducationalVideoModel(
        id: 'vid_04',
        title: 'Integration by Parts: The "ILATE" Rule with Advanced Cases',
        subject: 'Mathematics',
        instructorName: 'Prof. Ananya Rastogi',
        duration: '21:50',
        durationSeconds: 1310,
        views: 16400,
        category: 'JEE (Main + Adv)',
        description:
            'Master recurring integrals, reduction formulas, and tabular integration methods to solve definite integrals under 60 seconds.',
        topicsCovered: [
          'ILATE Rule Foundations',
          'Tabular Method for Fast Integration',
          'Euler Form Connections',
          'JEE Main Speed Shortcuts',
        ],
      ),
      EducationalVideoModel(
        id: 'vid_05',
        title: 'Current Affairs & Speed Math Shortcuts for CUET & SSC',
        subject: 'Aptitude & Reasoning',
        instructorName: 'Manish Chawla',
        duration: '19:35',
        durationSeconds: 1175,
        views: 14200,
        category: 'CUET',
        description:
            'Vedic math square root hacks, percentage fraction equivalents, and top monthly current affairs points for CUET General Test.',
        topicsCovered: [
          'Percentage Base Conversions',
          'Mental Arithmetic Techniques',
          'National & Global Summits',
          'Logical Puzzles',
        ],
      ),
    ];

    if (category != null && category.isNotEmpty && category != 'All') {
      return list.where((v) => v.category == category || v.subject == category).toList();
    }
    return list;
  }
}
