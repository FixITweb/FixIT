import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import 'app_theme.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(LightThemeState(themeData: AppTheme.lightTheme, isDarkMode: false)) {
    
    on<ToggleTheme>((event, emit) async {
      final newDarkMode = !state.isDarkMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', newDarkMode);
      if (newDarkMode) {
        emit(DarkThemeState(themeData: AppTheme.darkTheme, isDarkMode: true));
      } else {
        emit(LightThemeState(themeData: AppTheme.lightTheme, isDarkMode: false));
      }
    });

    on<SetLightTheme>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', false);
      emit(LightThemeState(themeData: AppTheme.lightTheme, isDarkMode: false));
    });

    on<SetDarkTheme>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', true);
      emit(DarkThemeState(themeData: AppTheme.darkTheme, isDarkMode: true));
    });

    on<LoadTheme>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('is_dark_mode') ?? false;
      if (isDark) {
        emit(DarkThemeState(themeData: AppTheme.darkTheme, isDarkMode: true));
      } else {
        emit(LightThemeState(themeData: AppTheme.lightTheme, isDarkMode: false));
      }
    });
  }
}