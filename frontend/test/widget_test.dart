// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/main.dart';
import 'package:frontend/core/network/api_client.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(FixITApp(apiClient: ApiClient()));

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);

    // Advance past splash screen delay and finish all pending timers
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
  });
}
