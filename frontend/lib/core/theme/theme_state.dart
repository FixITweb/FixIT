import 'package:flutter/material.dart';

abstract class ThemeState {
  final ThemeData themeData;
  final bool isDarkMode;

  const ThemeState({required this.themeData, required this.isDarkMode});
}

class LightThemeState extends ThemeState {
  const LightThemeState({required super.themeData, required super.isDarkMode});
}

class DarkThemeState extends ThemeState {
  const DarkThemeState({required super.themeData, required super.isDarkMode});
}