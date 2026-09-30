class AnnualThemeContent {
  const AnnualThemeContent({
    required this.mission,
    required this.vision,
    required this.theme,
    required this.branding,
  });

  final String? mission;
  final String? vision;
  final AnnualThemeData? theme;
  final AnnualThemeBranding branding;

  factory AnnualThemeContent.fromJson(Map<String, dynamic> json) {
    return AnnualThemeContent(
      mission: _cleanString(json['mission']),
      vision: _cleanString(json['vision']),
      theme: json['annual_theme'] is Map
          ? AnnualThemeData.fromJson(
              Map<String, dynamic>.from(json['annual_theme'] as Map),
            )
          : null,
      branding: json['branding'] is Map
          ? AnnualThemeBranding.fromJson(
              Map<String, dynamic>.from(json['branding'] as Map),
            )
          : const AnnualThemeBranding(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mission': mission,
        'vision': vision,
        'annual_theme': theme?.toJson(),
        'branding': branding.toJson(),
      };
}

class AnnualThemeData {
  const AnnualThemeData({
    required this.id,
    required this.year,
    required this.title,
    required this.scriptureReference,
    required this.description,
    required this.imageUrl,
  });

  final int? id;
  final int? year;
  final String title;
  final String? scriptureReference;
  final String? description;
  final String? imageUrl;

  factory AnnualThemeData.fromJson(Map<String, dynamic> json) {
    return AnnualThemeData(
      id: _toInt(json['id']),
      year: _toInt(json['year']),
      title: _cleanString(json['theme']) ?? 'Annual Theme',
      scriptureReference: _cleanString(json['scripture_reference']),
      description: _cleanString(json['description']),
      imageUrl: _cleanString(json['image_url']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'year': year,
        'theme': title,
        'scripture_reference': scriptureReference,
        'description': description,
        'image_url': imageUrl,
      };
}

class AnnualThemeBranding {
  const AnnualThemeBranding({
    this.name = 'Church of Uganda Youth Platform',
    this.shortName = 'COU Youth Platform',
    this.tagline = 'Connecting Young People. Growing Disciples. Transforming Nations.',
    this.primaryColor = '#4B2E83',
    this.secondaryColor = '#204F78',
    this.logoUrl,
  });

  final String name;
  final String shortName;
  final String tagline;
  final String primaryColor;
  final String secondaryColor;
  final String? logoUrl;

  factory AnnualThemeBranding.fromJson(Map<String, dynamic> json) {
    return AnnualThemeBranding(
      name: _cleanString(json['name']) ?? 'Church of Uganda Youth Platform',
      shortName: _cleanString(json['short_name']) ?? 'COU Youth Platform',
      tagline: _cleanString(json['tagline']) ??
          'Connecting Young People. Growing Disciples. Transforming Nations.',
      primaryColor: _cleanString(json['primary_color']) ?? '#4B2E83',
      secondaryColor: _cleanString(json['secondary_color']) ?? '#204F78',
      logoUrl: _cleanString(json['logo_url']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'short_name': shortName,
        'tagline': tagline,
        'primary_color': primaryColor,
        'secondary_color': secondaryColor,
        'logo_url': logoUrl,
      };
}

String? _cleanString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
