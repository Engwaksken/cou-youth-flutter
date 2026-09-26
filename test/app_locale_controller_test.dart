import 'package:cou_youth_mobile/core/localization/app_locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('locale controller switches between English and Luganda', () {
    final controller = AppLocaleController.instance;

    controller.setLocale(const Locale('en'));
    expect(controller.value.languageCode, 'en');

    controller.toggle();
    expect(controller.value.languageCode, 'lg');

    controller.toggle();
    expect(controller.value.languageCode, 'en');
  });

  test('unsupported locale is ignored', () {
    final controller = AppLocaleController.instance;
    controller.setLocale(const Locale('en'));

    controller.setLocale(const Locale('fr'));

    expect(controller.value.languageCode, 'en');
  });
}
