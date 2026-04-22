import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';

/// State for the active theme.
class ThemeState {
  final String themeName;
  final bool isDark;

  const ThemeState({
    this.themeName = 'Obsidian',
    this.isDark = true,
  });

  ThemeData get themeData => AppThemes.getTheme(themeName, isDark);

  ThemeState copyWith({String? themeName, bool? isDark}) {
    return ThemeState(
      themeName: themeName ?? this.themeName,
      isDark: isDark ?? this.isDark,
    );
  }
}

/// Notifier that manages theme state and persists to SharedPreferences.
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadFromPrefs();
  }

  static const _keyThemeName = 'theme_name';
  static const _keyIsDark = 'theme_is_dark';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyThemeName) ?? 'Obsidian';
    final isDark = prefs.getBool(_keyIsDark) ?? true;
    state = ThemeState(themeName: name, isDark: isDark);
  }

  Future<void> setTheme(String name) async {
    state = state.copyWith(themeName: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeName, name);
  }

  Future<void> toggleMode() async {
    state = state.copyWith(isDark: !state.isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDark, state.isDark);
  }

  Future<void> setDarkMode(bool isDark) async {
    state = state.copyWith(isDark: isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDark, isDark);
  }
}

/// Global theme provider.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
