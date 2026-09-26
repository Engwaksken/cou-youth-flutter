import '../core/api/api_config.dart';
import '../core/config/app_config.dart';

class BrandingData {
  const BrandingData({
    required this.name,
    required this.shortName,
    required this.tagline,
    required this.primaryColor,
    required this.secondaryColor,
    this.logoUrl,
    this.supportEmail,
  });

  final String name;
  final String shortName;
  final String tagline;
  final String primaryColor;
  final String secondaryColor;
  final String? logoUrl;
  final String? supportEmail;

  static const fallback = BrandingData(
    name: 'Church of Uganda Youth Platform',
    shortName: 'COU Youth Platform',
    tagline: 'Connecting Young People. Growing Disciples. Transforming Nations.',
    primaryColor: '#4B2E83',
    secondaryColor: '#204F78',
  );
}

class BrandingService {
  BrandingService._();

  static Future<BrandingData>? _cached;

  static Future<BrandingData> load() {
    return _cached ??= _fetch();
  }

  static void clearCache() {
    _cached = null;
  }

  static String? resolveUrl(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;

    final uri = Uri.tryParse(text);
    if (uri != null && uri.hasScheme) return text;

    final api = Uri.parse(AppConfig.apiBaseUrl);
    final origin = '${api.scheme}://${api.authority}';
    return text.startsWith('/') ? '$origin$text' : '$origin/storage/$text';
  }

  static Future<BrandingData> _fetch() async {
    try {
      final response = await ApiConfig.client.get('/branding');
      final raw = response['data'];
      if (raw is! Map) return BrandingData.fallback;

      final data = Map<String, dynamic>.from(raw);
      final logo = resolveUrl('${data['logo_url'] ?? ''}'.trim());

      return BrandingData(
        name: _value(data['name'], BrandingData.fallback.name),
        shortName: _value(data['short_name'], BrandingData.fallback.shortName),
        tagline: _value(data['tagline'], BrandingData.fallback.tagline),
        primaryColor: _value(
          data['primary_color'],
          BrandingData.fallback.primaryColor,
        ),
        secondaryColor: _value(
          data['secondary_color'],
          BrandingData.fallback.secondaryColor,
        ),
        logoUrl: logo,
        supportEmail: '${data['support_email'] ?? ''}'.trim().isEmpty
            ? null
            : '${data['support_email']}'.trim(),
      );
    } catch (_) {
      return BrandingData.fallback;
    }
  }

  static String _value(dynamic value, String fallback) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? fallback : text;
  }
}
