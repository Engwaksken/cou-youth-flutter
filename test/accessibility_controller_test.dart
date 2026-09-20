import 'package:cou_youth_mobile/core/accessibility/accessibility_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final controller = AccessibilityController.instance;

  setUp(controller.reset);
  tearDown(controller.reset);

  test('text scale stays within supported limits', () {
    for (var i = 0; i < 20; i++) {
      controller.increaseText();
    }
    expect(controller.value.textScale, 1.6);

    for (var i = 0; i < 20; i++) {
      controller.decreaseText();
    }
    expect(controller.value.textScale, 0.8);
  });

  test('accessibility toggles can be enabled and reset', () {
    controller.toggleHighContrast();
    controller.toggleGrayscale();
    controller.toggleReduceMotion();
    controller.toggleDyslexiaFriendly();

    expect(controller.value.highContrast, isTrue);
    expect(controller.value.grayscale, isTrue);
    expect(controller.value.reduceMotion, isTrue);
    expect(controller.value.dyslexiaFriendly, isTrue);

    controller.reset();

    expect(controller.value.highContrast, isFalse);
    expect(controller.value.grayscale, isFalse);
    expect(controller.value.reduceMotion, isFalse);
    expect(controller.value.dyslexiaFriendly, isFalse);
    expect(controller.value.textScale, 1.0);
  });
}
