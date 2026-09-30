class AnnualThemeContent {
  const AnnualThemeContent({
    required this.mission,
    required this.vision,
    required this.theme,
  });

  final String? mission;
  final String? vision;
  final AnnualThemeData? theme;

  factory AnnualThemeContent.fromJson(Map<String, dynamic> json) {
    return AnnualThemeContent(
      mission: _cleanString(json['mission']),
      vision: _cleanString(json['vision']),
      theme: json['annual_theme'] is Map
          ? AnnualThemeData.fromJson(
              Map<String, dynamic>.from(json['annual_theme'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mission': mission,
        'vision': vision,
        'annual_theme': theme?.toJson(),
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

String? _cleanString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
