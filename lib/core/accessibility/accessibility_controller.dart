import 'package:flutter/material.dart';

class AccessibilitySettings {
  const AccessibilitySettings({
    this.textScale = 1.0,
    this.highContrast = false,
    this.grayscale = false,
    this.reduceMotion = false,
    this.dyslexiaFriendly = false,
  });

  final double textScale;
  final bool highContrast;
  final bool grayscale;
  final bool reduceMotion;
  final bool dyslexiaFriendly;

  AccessibilitySettings copyWith({
    double? textScale,
    bool? highContrast,
    bool? grayscale,
    bool? reduceMotion,
    bool? dyslexiaFriendly,
  }) {
    return AccessibilitySettings(
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
      grayscale: grayscale ?? this.grayscale,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      dyslexiaFriendly: dyslexiaFriendly ?? this.dyslexiaFriendly,
    );
  }
}

class AccessibilityController extends ValueNotifier<AccessibilitySettings> {
  AccessibilityController._() : super(const AccessibilitySettings());

  static final AccessibilityController instance = AccessibilityController._();

  void increaseText() {
    final next = (value.textScale + .1).clamp(.8, 1.6).toDouble();
    value = value.copyWith(textScale: next);
  }

  void decreaseText() {
    final next = (value.textScale - .1).clamp(.8, 1.6).toDouble();
    value = value.copyWith(textScale: next);
  }

  void toggleHighContrast() {
    value = value.copyWith(highContrast: !value.highContrast);
  }

  void toggleGrayscale() {
    value = value.copyWith(grayscale: !value.grayscale);
  }

  void toggleReduceMotion() {
    value = value.copyWith(reduceMotion: !value.reduceMotion);
  }

  void toggleDyslexiaFriendly() {
    value = value.copyWith(dyslexiaFriendly: !value.dyslexiaFriendly);
  }

  void reset() {
    value = const AccessibilitySettings();
  }
}
