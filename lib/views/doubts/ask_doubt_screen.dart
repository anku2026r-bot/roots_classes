import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';

class AskDoubtScreen extends StatefulWidget {
  final String? initialSubject;

  const AskDoubtScreen({super.key, this.initialSubject});

  @override
  State<AskDoubtScreen> createState() => _AskDoubtScreenState();
}

class _AskDoubtScreenState extends State<AskDoubtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _questionController = TextEditingController();
  late String _selectedSubject;
  bool _hasImageAttached = false;
  bool _isSubmitted = false;

  final List<String> _subjects = [
    'Physics (Mechanics, Optics & Electrodynamics)',
    'Chemistry (Organic, Inorganic & Physical)',
    'Mathematics (Calculus, Algebra & Geometry)',
    'Biology (Zoology & Botany)',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.initialSubject ?? _subjects.first;
    if (!_subjects.contains(_selectedSubject)) _selectedSubject = _subjects.first;
  }

  @override
  void dispose() {
    _topicController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ask a Doubt & Mentorship',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset / Refresh Form',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing doubt forum...'), duration: Duration(milliseconds: 600)),
              );
              await Future.delayed(const Duration(milliseconds: 350));
              if (mounted) {
                setState(() {
                  _topicController.clear();
                  _questionController.clear();
                  _hasImageAttached = false;
                  _isSubmitted = false;
                });
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 350));
            if (mounted) {
              setState(() {
                _topicController.clear();
                _questionController.clear();
                _hasImageAttached = false;
                _isSubmitted = false;
              });
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: _isSubmitted ? _buildSuccessView(isDark) : _buildFormView(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [AppColors.primary, const Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.question_answer_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instant Academic Doubt Counter',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submit your questions or derivations. Our senior faculty answers within 24 hours with step-by-step video solutions.',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Subject Domain *', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.menu_book_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.outfit(fontSize: 13)))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedSubject = val);
            },
          ),
          const SizedBox(height: 18),

          Text('Chapter / Topic Name *', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _topicController,
            decoration: InputDecoration(
              hintText: 'e.g. Rotational Mechanics, Aldehydes, Integration',
              prefixIcon: const Icon(Icons.tag_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please specify chapter' : null,
          ),
          const SizedBox(height: 18),

          Text('Describe Your Doubt in Detail *', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _questionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Type your question, formula, or describe where you got stuck in the derivation...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe your doubt' : null,
          ),
          const SizedBox(height: 18),

          // Attach Photo / Diagram Button
          InkWell(
            onTap: () {
              setState(() => _hasImageAttached = !_hasImageAttached);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_hasImageAttached ? 'Question photo attached successfully!' : 'Photo removed.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _hasImageAttached
                    ? Colors.green.withValues(alpha: 0.1)
                    : (isDark ? AppColors.surfaceDark : Colors.grey.shade50),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _hasImageAttached
                      ? Colors.green
                      : (isDark ? AppColors.borderDark : Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _hasImageAttached ? Icons.check_circle_rounded : Icons.add_photo_alternate_rounded,
                    color: _hasImageAttached ? Colors.green : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasImageAttached ? 'Photo Attached (question_snapshot.jpg)' : 'Attach Question Snapshot / Handwritten Work',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          'Upload photo of textbook problem or your rough calculation',
                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _handleSubmit,
              child: Text('Submit Doubt to Faculty', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_read_rounded, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 24),
            Text('Doubt Submitted!', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Your doubt for ${_topicController.text.trim()} has been assigned to our faculty team.\nYou will receive a detailed solution and notification soon.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => AppNavigator.pop(context),
                child: Text('Back to Dashboard', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
