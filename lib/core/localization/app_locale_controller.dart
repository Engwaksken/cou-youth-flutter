import 'package:flutter/material.dart';

class AppLocaleController extends ValueNotifier<Locale> {
  AppLocaleController._() : super(const Locale('en'));

  static final AppLocaleController instance = AppLocaleController._();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('lg'),
  ];

  void setLocale(Locale locale) {
    if (!supportedLocales.any((item) => item.languageCode == locale.languageCode)) {
      return;
    }
    if (value.languageCode == locale.languageCode) return;
    value = Locale(locale.languageCode);
  }

  void toggle() {
    value = value.languageCode == 'en' ? const Locale('lg') : const Locale('en');
  }
}
