import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ??
      AppStrings(const Locale('en'));

  static const delegate = _AppStringsDelegate();

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'app_title': 'Church of Uganda Youth Platform',
      'home': 'Home',
      'discover': 'Discover',
      'discipleship': 'Discipleship',
      'events': 'Events',
      'profile': 'Profile',
      'welcome': 'Welcome',
      'tagline': 'Connecting Young People. Growing Disciples. Transforming Nations.',
      'quick_access': 'Quick Access',
      'prayer': 'Prayer',
      'church_locator': 'Church Locator',
      'donate': 'Donate',
      'youth_assistant': 'Youth Assistant',
      'notifications': 'Notifications',
      'safe_support': 'Safe Support',
      'life_groups': 'Life Groups',
      'media_resources': 'Media & Resources',
      'opportunities': 'Opportunities',
      'missions': 'Missions & Evangelism',
      'talent_hub': 'Talent Hub',
      'youth_businesses': 'Youth Business Directory',
      'youth_hubs': 'Youth Hubs',
      'search_youth_hubs': 'Search missions, talents and youth businesses',
      'missions_description': 'Discover mission activities, evangelism opportunities and outreach stories.',
      'talent_description': 'Celebrate and discover youth talent in music, arts, sports, media and technology.',
      'business_description': 'Discover youth-led businesses, enterprises and entrepreneurship stories.',
      'no_youth_hub_items': 'No matching items are available yet.',
      'youth_hubs_load_failed': 'Youth hub content could not be loaded.',
      'search': 'Search',
      'language': 'Language',
      'english': 'English',
      'luganda': 'Luganda',
      'accessibility': 'Accessibility',
      'certificates': 'Certificates',
      'notification_preferences': 'Notification preferences',
      'sign_out': 'Sign out',
      'sign_in_create': 'Sign in / create account',
      'search_opportunities': 'Search jobs, scholarships, training and volunteering',
      'no_opportunities': 'No matching opportunities are available yet.',
      'try_again': 'Try again',
      'latest_opportunities': 'Latest opportunities',
      'all': 'All',
      'jobs': 'Jobs',
      'scholarships': 'Scholarships',
      'training': 'Training',
      'volunteering': 'Volunteering',
      'language_updated': 'Language updated.',
    },
    'lg': {
      'app_title': 'Omukutu gw’Abavubuka ogw’Ekkanisa ya Uganda',
      'home': 'Awaka',
      'discover': 'Zuula',
      'discipleship': 'Okuyigirizibwa',
      'events': 'Emikolo',
      'profile': 'Ebikukwatako',
      'welcome': 'Tukwaniriza',
      'tagline': 'Okuyunga Abavubuka. Okukuza Abayigirizwa. Okukyusa Amawanga.',
      'quick_access': 'Yingira Mangu',
      'prayer': 'Okusaba',
      'church_locator': 'Noonya Ekkanisa',
      'donate': 'Waayo',
      'youth_assistant': 'Omuyambi w’Abavubuka',
      'notifications': 'Obubaka',
      'safe_support': 'Obuyambi obw’Obukuumi',
      'life_groups': 'Ebibiina by’Obulamu',
      'media_resources': 'Amawulire n’Ebikozesebwa',
      'opportunities': 'Emikisa',
      'missions': 'Obuminsani n’Okubuulira Enjiri',
      'talent_hub': 'Ekifo ky’Ebitone',
      'youth_businesses': 'Bizineesi z’Abavubuka',
      'youth_hubs': 'Ebifo by’Abavubuka',
      'search_youth_hubs': 'Noonya obuminsani, ebitone ne bizineesi z’abavubuka',
      'missions_description': 'Zuula emirimu gy’obuminsani, okubuulira Enjiri n’emboozi z’okutuuka ku bantu.',
      'talent_description': 'Zuula era okuza ebitone by’abavubuka mu muziki, eby’emikono, emizannyo, amawulire ne tekinologiya.',
      'business_description': 'Zuula bizineesi ezikulemberwa abavubuka n’emboozi z’obusuubuzi.',
      'no_youth_hub_items': 'Tewali bintu bituukana n’okunoonya kuno kati.',
      'youth_hubs_load_failed': 'Ebiri mu bifo by’abavubuka tebisobodde kutikkibwa.',
      'search': 'Noonya',
      'language': 'Olulimi',
      'english': 'Olungereza',
      'luganda': 'Luganda',
      'accessibility': 'Okutuukirira Bonna',
      'certificates': 'Satifiketi',
      'notification_preferences': 'Enteekateeka z’Obubaka',
      'sign_out': 'Fuluma',
      'sign_in_create': 'Yingira / kola akawunti',
      'search_opportunities': 'Noonya emirimu, scholarship, okutendekebwa n’obwannakyewa',
      'no_opportunities': 'Tewali mikisa gituukana n’okunoonya kuno kati.',
      'try_again': 'Ddamu ogezeeko',
      'latest_opportunities': 'Emikisa emipya',
      'all': 'Byonna',
      'jobs': 'Emirimu',
      'scholarships': 'Scholarship',
      'training': 'Okutendekebwa',
      'volunteering': 'Obwannakyewa',
      'language_updated': 'Olulimi lukyusiddwa.',
    },
  };

  String text(String key) =>
      _values[locale.languageCode]?[key] ??
      _values['en']?[key] ??
      key;
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => const ['en', 'lg'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) => SynchronousFuture(AppStrings(locale));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
