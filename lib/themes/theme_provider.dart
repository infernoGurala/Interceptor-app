import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_fonts.dart';
import 'app_themes.dart';

/// State for active theme and typography.
class ThemeState {
  final String themeName;
  final bool isDark;
  final String fontName;

  const ThemeState({
    this.themeName = 'Default',
    this.isDark = true,
    this.fontName = 'Default',
  });

  ThemeData get themeData => AppThemes.getTheme(themeName, isDark);

  FontPair get fontPair => AppFonts.getFontPair(fontName);

  ThemeState copyWith({
    String? themeName,
    bool? isDark,
    String? fontName,
  }) {
    return ThemeState(
      themeName: themeName ?? this.themeName,
      isDark: isDark ?? this.isDark,
      fontName: fontName ?? this.fontName,
    );
  }
}

/// Notifier that manages theme and font settings and persists to SharedPreferences.
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadFromPrefs();
  }

  static const _keyThemeName = 'theme_name';
  static const _keyIsDark = 'theme_is_dark';
  static const _keyFontName = 'font_name';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_keyIsDark) ?? true;
    final validThemes = isDark ? AppThemes.darkThemes : AppThemes.lightThemes;
    var name = prefs.getString(_keyThemeName) ?? 'Default';
    if (!validThemes.contains(name)) {
      name = validThemes.first;
    }
    final font = prefs.getString(_keyFontName) ?? 'Default';
    state = ThemeState(themeName: name, isDark: isDark, fontName: font);
    AppFonts.ensureFontsLoaded();
  }

  Future<void> setTheme(String name) async {
    state = state.copyWith(themeName: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeName, name);
  }

  Future<void> toggleMode() async {
    await setDarkMode(!state.isDark);
  }

  Future<void> setDarkMode(bool isDark) async {
    final name = AppThemes.getCounterpart(state.themeName, isDark);
    state = state.copyWith(isDark: isDark, themeName: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDark, isDark);
    await prefs.setString(_keyThemeName, name);
  }

  Future<void> setFont(String fontName) async {
    state = state.copyWith(fontName: fontName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFontName, fontName);
    AppFonts.ensureFontsLoaded();
  }
}

/// Global theme provider.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
