import 'package:flutter/material.dart';

import 'accessibility_controller.dart';

class AccessibilitySheet extends StatelessWidget {
  const AccessibilitySheet({
    super.key,
    required this.controller,
  });

  final AccessibilityController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccessibilitySettings>(
      valueListenable: controller,
      builder: (context, settings, _) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            children: [
              Semantics(
                header: true,
                child: const Text(
                  'Accessibility',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              ListTile(
                title: const Text('Increase text size'),
                trailing: const Icon(Icons.text_increase),
                onTap: controller.increaseText,
              ),

              ListTile(
                title: const Text('Decrease text size'),
                trailing: const Icon(Icons.text_decrease),
                onTap: controller.decreaseText,
              ),

              SwitchListTile(
                title: const Text('High contrast'),
                value: settings.highContrast,
                onChanged: (_) {
                  controller.toggleHighContrast();
                },
              ),

              SwitchListTile(
                title: const Text('Reduce motion'),
                value: settings.reduceMotion,
                onChanged: (_) {
                  controller.toggleReduceMotion();
                },
              ),

              SwitchListTile(
                title: const Text('Dyslexia-friendly mode'),
                value: settings.dyslexiaFriendly,
                onChanged: (_) {
                  controller.toggleDyslexiaFriendly();
                },
              ),

              const SizedBox(height: 12),

              FilledButton.tonal(
                onPressed: controller.reset,
                child: const Text(
                  'Reset accessibility settings',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}