import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/home_banner_model.dart';

class HeroBannerSection extends StatefulWidget {
  final List<HomeBannerModel> banners;
  final VoidCallback? onPrimaryCta;
  final VoidCallback? onSecondaryCta;

  const HeroBannerSection({
    super.key,
    required this.banners,
    this.onPrimaryCta,
    this.onSecondaryCta,
  });

  @override
  State<HeroBannerSection> createState() => _HeroBannerSectionState();
}

class _HeroBannerSectionState extends State<HeroBannerSection> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    if (widget.banners.length <= 1) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) return;
      final nextIndex = (_currentIndex + 1) % widget.banners.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Main Hero Banner Carousel
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Carousel View
                SizedBox(
                  height: isDesktop ? 360 : (isTablet ? 340 : 380),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.banners.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = widget.banners[index];
                      if (item.bannerType == 'roots_flagship') {
                        return _SlideRootsFlagship(
                          banner: item,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                          onPrimaryCta: widget.onPrimaryCta,
                        );
                      } else if (item.bannerType == 'smart_and_strong') {
                        return _SlideSmartAndStrong(
                          banner: item,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                          onPrimaryCta: widget.onPrimaryCta,
                        );
                      } else {
                        // Default: Slide 1 - 100 Dino me Board ki Taiyari
                        return _Slide100DaysBooster(
                          banner: item,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                          onPrimaryCta: widget.onPrimaryCta,
                        );
                      }
                    },
                  ),
                ),

                // Indicators and Desktop Arrows
                Positioned(
                  bottom: 14,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          widget.banners.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            width: _currentIndex == i ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == i
                                  ? const Color(0xFF38BDF8)
                                  : Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      // Desktop Prev/Next Arrows
                      if (isDesktop && widget.banners.length > 1)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ArrowBtn(
                              icon: Icons.chevron_left_rounded,
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _ArrowBtn(
                              icon: Icons.chevron_right_rounded,
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Statistics Bar directly from rootsclasses.in
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
            vertical: 12,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _StatItem(
                  value: '10,000+',
                  label: 'STUDENTS ENROLLED',
                  color: const Color(0xFFEF4444), // Red
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatItem(
                  value: '98%',
                  label: 'SELECTION RATE',
                  color: const Color(0xFF2563EB), // Blue
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatItem(
                  value: '50+',
                  label: 'EXPERT FACULTY',
                  color: const Color(0xFF10B981), // Green
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatItem(
                  value: '10+',
                  label: 'YEARS OF EXCELLENCE',
                  color: const Color(0xFFF59E0B), // Gold
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Slide 1: 100 दिनों में करें Board की तैयारी (Percentage Booster Course)
class _Slide100DaysBooster extends StatelessWidget {
  final HomeBannerModel banner;
  final bool isDesktop;
  final bool isTablet;
  final VoidCallback? onPrimaryCta;

  const _Slide100DaysBooster({
    required this.banner,
    required this.isDesktop,
    required this.isTablet,
    this.onPrimaryCta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF071126), // Deep midnight navy
            Color(0xFF0F265C), // Royal navy blue
            Color(0xFF1B3B8B), // Saturated blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background ambient lights & sparkle stars
          Positioned(
            right: 80,
            top: 20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              ),
            ),
          ),

          // Discount Ribbon top right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                'DISCOUNT UP TO 40% OFF',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: isDesktop ? 12 : 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Slide Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 36 : (isTablet ? 24 : 18),
              vertical: 22,
            ),
            child: Row(
              children: [
                // Left content
                Expanded(
                  flex: 3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isDesktop ? 600 : (isTablet ? 450 : 340)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // RC Emblem Header
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1E3A8A),
                            ),
                            child: const Text(
                              'RC',
                              style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: List.generate(
                              5,
                              (index) => const Icon(Icons.star_rounded,
                                  color: Color(0xFFF59E0B), size: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Main Hindi Headline: "100 दिनों में करें Board की तैयारी"
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '100 दिनों में करें ',
                              style: GoogleFonts.outfit(
                                fontSize: isDesktop ? 30 : (isTablet ? 24 : 20),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFACC15), // Yellow
                                height: 1.2,
                              ),
                            ),
                            TextSpan(
                              text: 'Board ',
                              style: GoogleFonts.outfit(
                                fontSize: isDesktop ? 32 : (isTablet ? 26 : 22),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'की तैयारी',
                              style: GoogleFonts.outfit(
                                fontSize: isDesktop ? 30 : (isTablet ? 24 : 20),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFACC15),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Percentage Booster Course Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Percentage ',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isDesktop ? 18 : 15,
                                ),
                              ),
                              TextSpan(
                                text: 'Booster ',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFB923C),
                                  fontWeight: FontWeight.w900,
                                  fontSize: isDesktop ? 18 : 15,
                                ),
                              ),
                              TextSpan(
                                text: 'Course',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isDesktop ? 18 : 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Class: 10th & 12th + ADMISSION OPEN row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFACC15)),
                            ),
                            child: Text(
                              'Class: 10th & 12th',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626), // Red
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ADMISSION OPEN',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Contact Number 98775-15330 & CTA
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF22C55E),
                                ),
                                child: const Icon(Icons.phone_rounded,
                                    color: Colors.white, size: 14),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '98775-15330',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isDesktop ? 16 : 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E3A8A),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.touch_app_rounded, size: 16),
                            label: Text(
                              'Enroll Now',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: onPrimaryCta,
                          ),
                        ],
                      ),
                    ],
                      ),
                    ),
                  ),
                ),

                // Right side visual avatar / badge
                if (isDesktop || isTablet)
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                                width: 2,
                              ),
                            ),
                          ),
                          Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person_pin_rounded,
                                      size: 54, color: Colors.white),
                                  SizedBox(height: 4),
                                  Text(
                                    'Faculty Guided',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Slide 2: Master the Roots, Rule the Results. (Roots Classes Flagship)
class _SlideRootsFlagship extends StatelessWidget {
  final HomeBannerModel banner;
  final bool isDesktop;
  final bool isTablet;
  final VoidCallback? onPrimaryCta;

  const _SlideRootsFlagship({
    required this.banner,
    required this.isDesktop,
    required this.isTablet,
    this.onPrimaryCta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE2E8F0), // Clean slate light
            Color(0xFFF8FAFC), // White
            Color(0xFFEFF6FF), // Soft blue tint
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
          vertical: 20,
        ),
        child: Row(
          children: [
            // Left Streams (Class 9-12, Foundation, NEET, JEE)
            if (isDesktop || isTablet)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StreamBadge(icon: Icons.school_rounded, label: 'Class 9-12'),
                  const SizedBox(height: 8),
                  _StreamBadge(icon: Icons.menu_book_rounded, label: 'Foundation'),
                  const SizedBox(height: 8),
                  _StreamBadge(icon: Icons.local_hospital_rounded, label: 'NEET'),
                  const SizedBox(height: 8),
                  _StreamBadge(icon: Icons.architecture_rounded, label: 'JEE'),
                ],
              ),

            if (isDesktop || isTablet) const SizedBox(width: 24),

            // Center: RC Roots Classes Logo + Motto
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 600 : (isTablet ? 450 : 340)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  // RC Emblem
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'RC',
                          style: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Roots Classes',
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 30 : (isTablet ? 24 : 22),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Tagline Pill: "Master the Roots, Rule the Results."
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '“Master the Roots, Rule the Results.”',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: isDesktop ? 15 : 12,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subject Pill: 🎯 Physics | Chemistry | Maths
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          'Physics  |  Chemistry  |  Maths',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w800,
                            fontSize: isDesktop ? 14 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onPrimaryCta,
                    child: Text(
                      'Explore Courses',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

            if (isDesktop || isTablet) const SizedBox(width: 24),

            // Right Subjects
            if (isDesktop || isTablet)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _SubjectBadge(icon: Icons.science_rounded, label: 'Physics'),
                  const SizedBox(height: 8),
                  _SubjectBadge(icon: Icons.biotech_rounded, label: 'Chemistry'),
                  const SizedBox(height: 8),
                  _SubjectBadge(icon: Icons.calculate_rounded, label: 'Maths'),
                  const SizedBox(height: 8),
                  _SubjectBadge(icon: Icons.eco_rounded, label: 'Biology'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Slide 3: Board की तैयारी अब होगी Smart और Strong!
class _SlideSmartAndStrong extends StatelessWidget {
  final HomeBannerModel banner;
  final bool isDesktop;
  final bool isTablet;
  final VoidCallback? onPrimaryCta;

  const _SlideSmartAndStrong({
    required this.banner,
    required this.isDesktop,
    required this.isTablet,
    this.onPrimaryCta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Yellow ambient glow
          Positioned(
            left: 20,
            bottom: 20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFACC15).withValues(alpha: 0.08),
              ),
            ),
          ),

          // For Serious Students Only! Badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_rounded, color: Color(0xFF0F172A), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'For Serious Students Only!',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 36 : (isTablet ? 24 : 18),
              vertical: 22,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 600 : (isTablet ? 450 : 340)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                // Headline: Board की तैयारी अब होगी Smart और Strong!
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Board ',
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 28 : (isTablet ? 22 : 19),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFACC15),
                        ),
                      ),
                      TextSpan(
                        text: 'की तैयारी\nअब होगी ',
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 26 : (isTablet ? 20 : 18),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      TextSpan(
                        text: 'Smart ',
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 26 : (isTablet ? 20 : 18),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFACC15),
                        ),
                      ),
                      TextSpan(
                        text: 'और ',
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 26 : (isTablet ? 20 : 18),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'Strong!',
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 28 : (isTablet ? 22 : 19),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFACC15),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Percentage Booster Course
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Percentage ',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: 'Booster ',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFB923C),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: 'Course',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 4 Pillars Row from website: NCERT Line By Line, Concept Clearing, Practice & PYQs, Score Higher
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      _PillarBadge(icon: Icons.menu_book_rounded, label: 'NCERT\nLine By Line'),
                      SizedBox(width: 8),
                      _PillarBadge(icon: Icons.track_changes_rounded, label: 'Concept\nClearing'),
                      SizedBox(width: 8),
                      _PillarBadge(icon: Icons.edit_note_rounded, label: 'Practice\n& PYQs'),
                      SizedBox(width: 8),
                      _PillarBadge(icon: Icons.trending_up_rounded, label: 'Score\nHigher'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Helpline & CTA
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFACC15),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onPrimaryCta,
                      child: Text(
                        'Start Learning Free',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Text(
                      'Helpline: 98775-15330',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
  }
}

class _PillarBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PillarBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFACC15), size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StreamBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SubjectBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF97316),
            ),
            child: Icon(icon, size: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 28,
      width: 1,
      color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ArrowBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 18),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
