class TeamMemberModel {
  final String id;
  final String name;
  final String designation;
  final String subject;
  final String experience;
  final String qualification;
  final String bio;
  final String? avatarUrl;
  final List<String> expertiseTags;
  final double rating;
  final int studentsMentored;

  const TeamMemberModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.subject,
    required this.experience,
    required this.qualification,
    required this.bio,
    this.avatarUrl,
    this.expertiseTags = const [],
    this.rating = 4.9,
    this.studentsMentored = 8500,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Faculty Member',
      designation: json['designation'] as String? ?? 'Senior Faculty',
      subject: json['subject'] as String? ?? 'Subject Specialist',
      experience: json['experience'] as String? ?? '5+ Years',
      qualification: json['qualification'] as String? ?? 'M.Sc., B.Ed.',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      expertiseTags: (json['expertiseTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      studentsMentored: json['studentsMentored'] as int? ?? 5000,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'designation': designation,
    'subject': subject,
    'experience': experience,
    'qualification': qualification,
    'bio': bio,
    'avatarUrl': avatarUrl,
    'expertiseTags': expertiseTags,
    'rating': rating,
    'studentsMentored': studentsMentored,
  };
}
