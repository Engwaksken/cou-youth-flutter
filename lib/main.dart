import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/auth_gate.dart';
import 'app/main_navigation_screen.dart';
import 'core/accessibility/accessibility_controller.dart';
import 'core/localization/app_locale_controller.dart';
import 'core/localization/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'widgets/connectivity_gate.dart';
import 'widgets/youth_decorated_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CouYouthApp());
}

class CouYouthApp extends StatelessWidget {
  const CouYouthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccessibilitySettings>(
      valueListenable: AccessibilityController.instance,
      builder: (context, accessibility, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.instance,
          builder: (context, _, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Church of Uganda Youth Platform',
              theme: buildYouthTheme(accessibility),
              locale: const Locale('en'),
              supportedLocales: const [Locale('en')],
              localizationsDelegates: const [
                AppStrings.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                if (child == null) return const SizedBox.shrink();

                final mediaQuery = MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(accessibility.textScale),
                  disableAnimations: accessibility.reduceMotion,
                );

                Widget result = YouthDecoratedBackground(
                  child: MediaQuery(data: mediaQuery, child: child),
                );

                if (accessibility.grayscale) {
                  result = ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: result,
                  );
                }

                return result;
              },
              home: const ConnectivityGate(
                child: AuthGate(
                  authenticatedBuilder: _buildMainNavigation,
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildMainNavigation(
    BuildContext context,
    Future<void> Function() exitSession,
  ) {
    return MainNavigationScreen(onExitSession: exitSession);
  }
}
