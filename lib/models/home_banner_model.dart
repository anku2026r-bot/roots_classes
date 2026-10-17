class HomeBannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String ctaText;
  final String? secondaryCtaText;
  final String? imageUrl;
  final List<String> stats;
  final String? phone;
  final String? discountText;
  final String? targetClass;
  final String bannerType;

  const HomeBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.tag = 'ADMISSION OPEN',
    this.ctaText = 'Enroll Now',
    this.secondaryCtaText,
    this.imageUrl,
    this.stats = const [],
    this.phone = '98775-15330',
    this.discountText,
    this.targetClass,
    this.bannerType = 'booster_100_days',
  });

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    return HomeBannerModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      tag: json['tag'] as String? ?? 'ADMISSION OPEN',
      ctaText: json['ctaText'] as String? ?? 'Enroll Now',
      secondaryCtaText: json['secondaryCtaText'] as String?,
      imageUrl: json['imageUrl'] as String?,
      stats: (json['stats'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      phone: json['phone'] as String? ?? '98775-15330',
      discountText: json['discountText'] as String?,
      targetClass: json['targetClass'] as String?,
      bannerType: json['bannerType'] as String? ?? 'booster_100_days',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'tag': tag,
    'ctaText': ctaText,
    'secondaryCtaText': secondaryCtaText,
    'imageUrl': imageUrl,
    'stats': stats,
    'phone': phone,
    'discountText': discountText,
    'targetClass': targetClass,
    'bannerType': bannerType,
  };
}
