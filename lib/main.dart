import 'package:flutter/material.dart';

import 'app/auth_gate.dart';
import 'app/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CouYouthApp());
}

class CouYouthApp extends StatelessWidget {
  const CouYouthApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4B2E83);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Church of Uganda Youth Platform',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1F2937),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFEDE9FE),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const AuthGate(
        authenticatedBuilder: _buildMainNavigation,
      ),
    );
  }

  static Widget _buildMainNavigation(BuildContext context) {
    return const MainNavigationScreen();
  }
}
