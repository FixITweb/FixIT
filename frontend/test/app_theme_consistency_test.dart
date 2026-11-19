import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_theme.dart';

void main() {
  test('light and dark themes share the same app bar heading treatment', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      expect(theme.appBarTheme.backgroundColor, AppTheme.brandHeaderColor);
      expect(theme.appBarTheme.foregroundColor, Colors.white);
      expect(theme.appBarTheme.centerTitle, isFalse);
      expect(
        theme.appBarTheme.titleTextStyle,
        AppTheme.brandHeaderTitleStyle,
      );
    }
  });

  test('button variants share the same tap target and corner radius', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final styles = [
        theme.elevatedButtonTheme.style,
        theme.filledButtonTheme.style,
        theme.outlinedButtonTheme.style,
        theme.textButtonTheme.style,
      ];

      expect(
        styles.map((style) => style?.minimumSize?.resolve({})),
        everyElement(const Size(48, 48)),
      );
      expect(
        styles.map((style) {
          final shape = style?.shape?.resolve({});
          return shape is RoundedRectangleBorder ? shape.borderRadius : null;
        }),
        everyElement(BorderRadius.circular(14)),
      );
    }
  });
}
