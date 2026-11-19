import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:frontend/features/auth/presentation/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('first launch routes to onboarding', (tester) async {
    await tester.pumpWidget(_app(const SplashScreen()));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Find Local Services'), findsOneWidget);
  });

  testWidgets('returning launch skips onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
    await tester.pumpWidget(_app(const SplashScreen()));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Login screen'), findsOneWidget);
  });

  testWidgets('skipping onboarding saves completion', (tester) async {
    await tester.pumpWidget(_app(const OnboardingScreen()));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('has_seen_onboarding'), isTrue);
    expect(find.text('Login screen'), findsOneWidget);
  });
}

Widget _app(Widget home) {
  return MaterialApp(
    home: home,
    onGenerateRoute: (settings) {
      if (settings.name == '/onboarding') {
        return MaterialPageRoute<void>(
          builder: (_) => const OnboardingScreen(),
        );
      }
      if (settings.name == '/login') {
        return MaterialPageRoute<void>(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Login screen')),
          ),
        );
      }
      return null;
    },
  );
}
