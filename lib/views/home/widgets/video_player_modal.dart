import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_navigator.dart';
import '../../../models/educational_video_model.dart';
import '../../videos/video_lecture_screen.dart';

class VideoPlayerModal extends StatefulWidget {
  final EducationalVideoModel video;
  final List<EducationalVideoModel> relatedVideos;
  final Function(EducationalVideoModel)? onSelectRelated;

  const VideoPlayerModal({
    super.key,
    required this.video,
    this.relatedVideos = const [],
    this.onSelectRelated,
  });

  static void show(
    BuildContext context, {
    required EducationalVideoModel video,
    List<EducationalVideoModel> relatedVideos = const [],
  }) {
    AppNavigator.push(
      context,
      VideoLectureScreen(
        video: video,
        relatedVideos: relatedVideos,
      ),
    );
  }

  @override
  State<VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<VideoPlayerModal> {
  bool _isPlaying = true;
  double _currentPositionSeconds = 0.0;
  double _playbackSpeed = 1.0;
  bool _isMuted = false;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _startSimulatedPlayback();
  }

  void _startSimulatedPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPlaying) {
        setState(() {
          _currentPositionSeconds += 1.0 * _playbackSpeed;
          if (_currentPositionSeconds >= widget.video.durationSeconds) {
            _currentPositionSeconds = widget.video.durationSeconds.toDouble();
            _isPlaying = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  String _formatTime(double seconds) {
    final s = seconds.toInt();
    final m = s ~/ 60;
    final remainingS = s % 60;
    return '${m.toString().padLeft(2, '0')}:${remainingS.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.90,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Video Player Screen Viewport
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video Mock Visual / Backdrop with Subject gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          AppColors.primaryDark.withValues(alpha: 0.7),
                          Colors.black,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.ondemand_video_rounded,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.video.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center Play/Pause Floating Button
                  IconButton(
                    iconSize: 52,
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                      });
                    },
                  ),

                  // Top controls overlay (Close, Subject tag)
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.video.subject.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Controls Overlay (Scrubber, time, speed, mute)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Scrubber slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                              trackHeight: 3,
                              activeTrackColor: AppColors.primaryLight,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: AppColors.primaryLight,
                            ),
                            child: Slider(
                              value: _currentPositionSeconds.clamp(0.0, widget.video.durationSeconds.toDouble()),
                              min: 0.0,
                              max: widget.video.durationSeconds.toDouble(),
                              onChanged: (val) {
                                setState(() {
                                  _currentPositionSeconds = val;
                                });
                              },
                            ),
                          ),

                          // Controls row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Time indicator
                              Text(
                                '${_formatTime(_currentPositionSeconds)} / ${widget.video.duration}',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Row(
                                children: [
                                  // Speed Switcher
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (_playbackSpeed == 1.0) {
                                          _playbackSpeed = 1.25;
                                        } else if (_playbackSpeed == 1.25) {
                                          _playbackSpeed = 1.5;
                                        } else if (_playbackSpeed == 1.5) {
                                          _playbackSpeed = 2.0;
                                        } else {
                                          _playbackSpeed = 1.0;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${_playbackSpeed}x',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Mute button
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isMuted = !_isMuted;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details & Related Videos Scrollable View
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.video.title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Instructor & Views row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          widget.video.instructorName.isNotEmpty
                              ? widget.video.instructorName[0]
                              : 'M',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.video.instructorName,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 12),
                      Text(
                        '${widget.video.views} Views',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Description
                  Text(
                    widget.video.description,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      height: 1.45,
                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Topics covered
                  if (widget.video.topicsCovered.isNotEmpty) ...[
                    Text(
                      'Key Topics in This Lecture',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: widget.video.topicsCovered.map((topic) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 16, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  topic,
                                  style: GoogleFonts.outfit(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Related videos section
                  if (widget.relatedVideos.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'More From Watch to Learn',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.relatedVideos
                          .where((v) => v.id != widget.video.id)
                          .take(3)
                          .length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final rel = widget.relatedVideos
                            .where((v) => v.id != widget.video.id)
                            .toList()[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                            ),
                            title: Text(
                              rel.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            subtitle: Text(
                              '${rel.instructorName} • ${rel.duration}',
                              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                            onTap: () => widget.onSelectRelated?.call(rel),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
