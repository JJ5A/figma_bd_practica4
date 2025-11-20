// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:figmahotels/main.dart';
import 'package:figmahotels/home_page.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Splash screen shows primary CTA', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('Home page renders primary sections', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Popular'), findsWidgets);
    expect(find.text('Nearby'), findsOneWidget);
  });
}
