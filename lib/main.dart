import 'package:flutter/material.dart';

import 'app/auth_gate.dart';
import 'app/main_navigation_screen.dart';
import 'core/accessibility/accessibility_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CouYouthApp());
}

class CouYouthApp extends StatelessWidget {
  const CouYouthApp({super.key});

  static const _primary = Color(0xFF4B2E83);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccessibilitySettings>(
      valueListenable: AccessibilityController.instance,
      builder: (context, accessibility, _) {
        final theme = _buildTheme(accessibility);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Church of Uganda Youth Platform',
          theme: theme,
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();

            final mediaQuery = MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(accessibility.textScale),
              disableAnimations: accessibility.reduceMotion,
            );

            Widget result = MediaQuery(
              data: mediaQuery,
              child: child,
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
          home: const AuthGate(
            authenticatedBuilder: _buildMainNavigation,
          ),
        );
      },
    );
  }

  static ThemeData _buildTheme(AccessibilitySettings accessibility) {
    final scheme = accessibility.highContrast
        ? const ColorScheme.light(
            primary: Color(0xFF2A0A55),
            onPrimary: Colors.white,
            secondary: Color(0xFF003B5C),
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
            error: Color(0xFF8B0000),
            onError: Colors.white,
          )
        : ColorScheme.fromSeed(seedColor: _primary);

    var theme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          accessibility.highContrast ? Colors.white : const Color(0xFFF7F8FC),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor:
            accessibility.highContrast ? Colors.black : const Color(0xFF1F2937),
        elevation: accessibility.highContrast ? 1 : 0,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: accessibility.highContrast ? 1 : 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: accessibility.highContrast
                ? Colors.black
                : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: accessibility.highContrast
            ? const Color(0xFFD1C4E9)
            : const Color(0xFFEDE9FE),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: accessibility.highContrast
                ? Colors.black
                : const Color(0xFFD1D5DB),
          ),
        ),
        border: const OutlineInputBorder(),
      ),
      pageTransitionsTheme: accessibility.reduceMotion
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _NoTransitionsBuilder(),
                TargetPlatform.iOS: _NoTransitionsBuilder(),
                TargetPlatform.macOS: _NoTransitionsBuilder(),
                TargetPlatform.windows: _NoTransitionsBuilder(),
                TargetPlatform.linux: _NoTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(),
    );

    if (accessibility.dyslexiaFriendly) {
      theme = theme.copyWith(
        textTheme: theme.textTheme.copyWith(
          bodyLarge: theme.textTheme.bodyLarge?.copyWith(
            letterSpacing: .45,
            height: 1.6,
          ),
          bodyMedium: theme.textTheme.bodyMedium?.copyWith(
            letterSpacing: .45,
            height: 1.55,
          ),
          bodySmall: theme.textTheme.bodySmall?.copyWith(
            letterSpacing: .35,
            height: 1.5,
          ),
          titleLarge: theme.textTheme.titleLarge?.copyWith(letterSpacing: .3),
          titleMedium: theme.textTheme.titleMedium?.copyWith(letterSpacing: .3),
        ),
      );
    }

    return theme;
  }

  static Widget _buildMainNavigation(
    BuildContext context,
    Future<void> Function() exitSession,
  ) {
    return MainNavigationScreen(onExitSession: exitSession);
  }
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
