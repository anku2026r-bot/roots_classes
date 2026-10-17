import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';
import '../../models/educational_video_model.dart';

class VideoLectureScreen extends StatefulWidget {
  final EducationalVideoModel video;
  final List<EducationalVideoModel> relatedVideos;

  const VideoLectureScreen({
    super.key,
    required this.video,
    this.relatedVideos = const [],
  });

  @override
  State<VideoLectureScreen> createState() => _VideoLectureScreenState();
}

class _VideoLectureScreenState extends State<VideoLectureScreen> {
  late EducationalVideoModel _currentVideo;
  bool _isPlaying = true;
  double _currentPositionSeconds = 0.0;
  double _playbackSpeed = 1.0;
  bool _isMuted = false;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _startSimulatedPlayback();
  }

  void _startSimulatedPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_isPlaying) {
        setState(() {
          _currentPositionSeconds += 1.0 * _playbackSpeed;
          final totalSec = _currentVideo.durationSeconds > 0
              ? _currentVideo.durationSeconds.toDouble()
              : 1800.0;
          if (_currentPositionSeconds >= totalSec) {
            _currentPositionSeconds = totalSec;
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

  String _formatDuration(double seconds) {
    final int totalSec = seconds.toInt();
    final int minutes = totalSec ~/ 60;
    final int sec = totalSec % 60;
    final String sMinutes = minutes < 10 ? '0$minutes' : '$minutes';
    final String sSec = sec < 10 ? '0$sec' : '$sec';
    return '$sMinutes:$sSec';
  }

  void _switchVideo(EducationalVideoModel newVideo) {
    setState(() {
      _currentVideo = newVideo;
      _currentPositionSeconds = 0.0;
      _isPlaying = true;
    });
    _startSimulatedPlayback();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSec = _currentVideo.durationSeconds > 0
        ? _currentVideo.durationSeconds.toDouble()
        : 1800.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentVideo.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Video & Lectures',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing lecture stream...'), duration: Duration(milliseconds: 600)),
              );
              await Future.delayed(const Duration(milliseconds: 350));
              if (mounted) setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing lecture link for "${_currentVideo.title}"'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. High-Tech Simulated Video Player
            Container(
              width: double.infinity,
              height: 230,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video Thumbnail Backdrop
                    Opacity(
                      opacity: 0.65,
                      child: Image.network(
                        _currentVideo.thumbnailUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF0F172A),
                          child: const Center(
                            child: Icon(Icons.videocam_rounded, size: 64, color: Colors.white24),
                          ),
                        ),
                      ),
                    ),


                  // Player Controls Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Bar: Stream tag & Speed
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.fiber_manual_record_rounded, size: 10, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ROOTS HD',
                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<double>(
                              initialValue: _playbackSpeed,
                              tooltip: 'Playback Speed',
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_playbackSpeed}x',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              onSelected: (speed) => setState(() => _playbackSpeed = speed),
                              itemBuilder: (_) => [0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                                return PopupMenuItem(value: s, child: Text('${s}x Speed'));
                              }).toList(),
                            ),
                          ],
                        ),

                        // Center Controls (Rewind, Play/Pause, Forward)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 30),
                              onPressed: () {
                                setState(() {
                                  _currentPositionSeconds = (_currentPositionSeconds - 10).clamp(0.0, totalSec);
                                });
                              },
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                                color: Colors.white,
                                size: 54,
                              ),
                              onPressed: () => setState(() => _isPlaying = !_isPlaying),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 30),
                              onPressed: () {
                                setState(() {
                                  _currentPositionSeconds = (_currentPositionSeconds + 10).clamp(0.0, totalSec);
                                });
                              },
                            ),
                          ],
                        ),

                        // Bottom Player Timeline & Duration
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: Colors.white30,
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: _currentPositionSeconds.clamp(0.0, totalSec),
                                min: 0.0,
                                max: totalSec,
                                onChanged: (v) => setState(() => _currentPositionSeconds = v),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_formatDuration(_currentPositionSeconds)} / ${_formatDuration(totalSec)}',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 11),
                                ),
                                IconButton(
                                  icon: Icon(_isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white, size: 18),
                                  onPressed: () => setState(() => _isMuted = !_isMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Lecture Information & Related Videos
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 350));
                  if (mounted) setState(() {});
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    _currentVideo.title,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _currentVideo.category,
                          style: GoogleFonts.outfit(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Faculty: ${_currentVideo.instructorName} • ${_currentVideo.views} views',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                      ),

                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _currentVideo.description,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Study Materials Download Bar
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 24),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lecture Notes & Problem DPP',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'High-resolution PDF with key derivations',
                                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: Text(
                            'Download',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Downloading Lecture Notes PDF...'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Related Lectures
                  if (widget.relatedVideos.isNotEmpty) ...[
                    Text(
                      'More Free Lectures in this Series',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...widget.relatedVideos
                        .where((v) => v.id != _currentVideo.id)
                        .map((rv) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _switchVideo(rv),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    rv.thumbnailUrl ?? '',
                                    width: 90,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 90,
                                      height: 60,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.videocam_rounded),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rv.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${rv.instructorName} • ${rv.duration}',
                                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
