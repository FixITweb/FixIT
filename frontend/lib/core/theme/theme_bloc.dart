import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import 'app_theme.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(LightThemeState(themeData: AppTheme.lightTheme, isDarkMode: false)) {
    
    on<ToggleTheme>((event, emit) {
      if (state.isDarkMode) {
        emit(LightThemeState(themeData: AppTheme.lightTheme, isDarkMode: false));
      } else {
        emit(DarkThemeState(themeData: AppTheme.darkTheme, isDarkMode: true));
      }
    });

    on<SetLightTheme>((event, emit) {
      emit(LightThemeState(themeData: AppTheme.lightTheme, isDarkMode: false));
    });

    on<SetDarkTheme>((event, emit) {
      emit(DarkThemeState(themeData: AppTheme.darkTheme, isDarkMode: true));
    });

    on<LoadTheme>((event, emit) {
      // For now, default to light theme
      // In a real app, you'd load from SharedPreferences
      emit(LightThemeState(themeData: AppTheme.lightTheme, isDarkMode: false));
    });
  }
}