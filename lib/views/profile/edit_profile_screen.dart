import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel? user;

  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _dobController;
  late String _selectedClass;
  late String _selectedGender;
  late String _selectedCourse;
  bool _isSaving = false;

  final List<String> _classes = [
    '8th Standard',
    '9th Standard',
    '10th Standard',
    '11th Standard',
    '12th Standard',
    'Repeater / Dropper Batch',
  ];

  final List<String> _courses = [
    'Engineering (JEE Main & Advanced)',
    'Medical (NEET UG)',
    'Foundation & NTSE (8th-10th)',
    'Board Booster (10th/12th)',
  ];

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u?.name ?? '');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _addressController = TextEditingController(text: u?.address ?? '');
    _dobController = TextEditingController(text: u?.dateofBirth ?? '2005-04-15');
    _selectedClass = (u?.currentClass?.isNotEmpty == true) ? u!.currentClass! : '11th Standard';
    if (!_classes.contains(_selectedClass)) _selectedClass = _classes[3];
    _selectedGender = (u?.gender?.isNotEmpty == true) ? u!.gender! : 'Male';
    _selectedCourse = (u?.interestedCourse?.isNotEmpty == true) ? u!.interestedCourse! : _courses.first;
    if (!_courses.contains(_selectedCourse)) _selectedCourse = _courses.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final auth = context.read<AuthController>();
    final current = auth.currentUser;
    if (current != null) {
      await auth.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        dateofBirth: _dobController.text.trim(),
        currentClass: _selectedClass,
        gender: _selectedGender,
        interestedCourse: _selectedCourse,
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      AppNavigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          'Edit Student Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Reload Profile',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              final auth = context.read<AuthController>();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reloading student profile...'), duration: Duration(milliseconds: 600)),
              );
              await Future.delayed(const Duration(milliseconds: 350));
              if (mounted) {
                final u = auth.currentUser;
                setState(() {
                  _nameController.text = u?.name ?? '';
                  _phoneController.text = u?.phone ?? '';
                  _addressController.text = u?.address ?? '';
                  _dobController.text = u?.dateofBirth ?? '2005-04-15';
                  _selectedClass = (u?.currentClass?.isNotEmpty == true) ? u!.currentClass! : '11th Standard';
                  if (!_classes.contains(_selectedClass)) _selectedClass = _classes[3];
                  _selectedGender = (u?.gender?.isNotEmpty == true) ? u!.gender! : 'Male';
                  _selectedCourse = (u?.interestedCourse?.isNotEmpty == true) ? u!.interestedCourse! : _courses.first;
                  if (!_courses.contains(_selectedCourse)) _selectedCourse = _courses.first;
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
            final auth = context.read<AuthController>();
            await Future.delayed(const Duration(milliseconds: 350));
            if (mounted) {
              final u = auth.currentUser;
              setState(() {
                _nameController.text = u?.name ?? '';
                _phoneController.text = u?.phone ?? '';
                _addressController.text = u?.address ?? '';
                _dobController.text = u?.dateofBirth ?? '2005-04-15';
                _selectedClass = (u?.currentClass?.isNotEmpty == true) ? u!.currentClass! : '11th Standard';
                if (!_classes.contains(_selectedClass)) _selectedClass = _classes[3];
                _selectedGender = (u?.gender?.isNotEmpty == true) ? u!.gender! : 'Male';
                _selectedCourse = (u?.interestedCourse?.isNotEmpty == true) ? u!.interestedCourse! : _courses.first;
                if (!_courses.contains(_selectedCourse)) _selectedCourse = _courses.first;
              });
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Header
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'S',
                          style: GoogleFonts.outfit(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 20, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('Full Legal Name *', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter student name' : null,
                ),
                const SizedBox(height: 18),

                Text('Phone Number *', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone' : null,
                ),
                const SizedBox(height: 18),

                Text('Current Class / Standard *', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedClass,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.school_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedClass = val);
                  },
                ),
                const SizedBox(height: 18),

                Text('Target Stream / Competitive Goal *', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCourse,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCourse = val);
                  },
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender *', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedGender,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGender = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date of Birth', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dobController,
                            decoration: InputDecoration(
                              hintText: 'YYYY-MM-DD',
                              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Text('Residential Address', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'City, State, Country',
                    prefixIcon: const Icon(Icons.home_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
                    onPressed: _isSaving ? null : _handleSave,
                    child: _isSaving
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Save Changes', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
