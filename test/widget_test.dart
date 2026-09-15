import 'package:cou_youth_mobile/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen renders core youth platform actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('COU Youth Platform'), findsOneWidget);
    expect(find.text('Quick Access'), findsOneWidget);
    expect(find.text('Discipleship'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Prayer'), findsOneWidget);
    expect(find.text('Church Locator'), findsOneWidget);
  });
}
