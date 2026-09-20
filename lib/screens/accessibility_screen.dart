import 'package:flutter/material.dart';

import '../core/accessibility/accessibility_controller.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AccessibilityController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility')),
      body: ValueListenableBuilder<AccessibilitySettings>(
        valueListenable: controller,
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Text size',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text('Current scale: ${(settings.textScale * 100).round()}%'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: controller.decreaseText,
                              icon: const Icon(Icons.text_decrease),
                              label: const Text('Smaller'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: controller.increaseText,
                              icon: const Icon(Icons.text_increase),
                              label: const Text('Larger'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.contrast_outlined),
                      title: const Text('High contrast'),
                      subtitle: const Text('Increase contrast for clearer reading.'),
                      value: settings.highContrast,
                      onChanged: (_) => controller.toggleHighContrast(),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.filter_b_and_w_outlined),
                      title: const Text('Grayscale'),
                      subtitle: const Text('Reduce reliance on colour.'),
                      value: settings.grayscale,
                      onChanged: (_) => controller.toggleGrayscale(),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.motion_photos_off_outlined),
                      title: const Text('Reduce motion'),
                      subtitle: const Text('Use simpler page transitions and animations.'),
                      value: settings.reduceMotion,
                      onChanged: (_) => controller.toggleReduceMotion(),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.menu_book_outlined),
                      title: const Text('Reading-friendly text'),
                      subtitle: const Text('Increase spacing to make text easier to follow.'),
                      value: settings.dyslexiaFriendly,
                      onChanged: (_) => controller.toggleDyslexiaFriendly(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: controller.reset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset accessibility settings'),
              ),
            ],
          );
        },
      ),
    );
  }
}
