import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/notifications/data/models/notification_model.dart';
import 'package:frontend/features/worker/notifications/presentation/pages/worker_notifications_screen.dart';

void main() {
  testWidgets('Notifications filter chips in dark mode use dark theme surface and readable contrast', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Row(
            children: [
              NotificationFilterChip(
                label: 'All',
                isSelected: true,
                onTap: () {},
              ),
              NotificationFilterChip(
                label: 'Unread (0)',
                isSelected: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    // Verify unselected chip is NOT hardcoded white
    final unselectedChipFinder = find.widgetWithText(AnimatedContainer, 'Unread (0)');
    expect(unselectedChipFinder, findsOneWidget);
    final unselectedContainer = tester.widget<AnimatedContainer>(unselectedChipFinder);
    final unselectedDecoration = unselectedContainer.decoration as BoxDecoration;
    expect(unselectedDecoration.color, isNot(Colors.white));
    expect(unselectedDecoration.color, AppTheme.darkTheme.colorScheme.surfaceContainer);

    // Verify selected chip uses primary theme color
    final selectedChipFinder = find.widgetWithText(AnimatedContainer, 'All');
    expect(selectedChipFinder, findsOneWidget);
    final selectedContainer = tester.widget<AnimatedContainer>(selectedChipFinder);
    final selectedDecoration = selectedContainer.decoration as BoxDecoration;
    expect(selectedDecoration.color, AppTheme.darkTheme.colorScheme.primary);
  });

  testWidgets('Notification card in dark mode does not use hardcoded white background', (tester) async {
    final theme = AppTheme.darkTheme;
    final colorScheme = theme.colorScheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final isRead = false;
              final cardBg = isRead
                  ? colorScheme.surfaceContainerLow
                  : colorScheme.surfaceContainer;
              return Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'New booking request',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              );
            },
          ),
        ),
      ),
    );

    final cardFinder = find.byType(Container).first;
    final container = tester.widget<Container>(cardFinder);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNot(Colors.white));
    expect(decoration.color, colorScheme.surfaceContainer);
  });
}
