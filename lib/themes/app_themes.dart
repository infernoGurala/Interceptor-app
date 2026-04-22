import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All preset themes for the Interceptor app.
/// Each theme has a light and dark variant with a single accent color.
class AppThemes {
  AppThemes._();

  // ─────────────────────────────────────
  // Theme names
  // ─────────────────────────────────────
  static const List<String> themeNames = [
    'Obsidian',
    'Ash',
    'Ink',
    'Paper',
    'Ember',
  ];

  // ─────────────────────────────────────
  // Color definitions
  // ─────────────────────────────────────
  static const _obsidianDark = Color(0xFF0A0A0A);
  static const _obsidianLight = Color(0xFFF5F5F5);
  static const _obsidianAccent = Color(0xFFE0E0E0);

  static const _ashDark = Color(0xFF2A2A2A);
  static const _ashLight = Color(0xFFF0EDE8);
  static const _ashAccent = Color(0xFFD4CFC8);

  static const _inkDark = Color(0xFF0D1B2A);
  static const _inkLight = Color(0xFFEDF2F7);
  static const _inkAccent = Color(0xFF4FD1C5);

  static const _paperDark = Color(0xFF1A1A1A);
  static const _paperLight = Color(0xFFFDF6E3);
  static const _paperAccent = Color(0xFF3C3C3C);

  static const _emberDark = Color(0xFF1C1410);
  static const _emberLight = Color(0xFFFFF8F0);
  static const _emberAccent = Color(0xFFD4915E);

  // ─────────────────────────────────────
  // Theme builder
  // ─────────────────────────────────────
  static ThemeData _buildTheme({
    required Color background,
    required Color surface,
    required Color accent,
    required Color textPrimary,
    required Color textSecondary,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
      secondary: accent.withValues(alpha: 0.7),
      onSecondary: brightness == Brightness.dark ? Colors.black : Colors.white,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textPrimary, height: 1.6),
          bodyMedium: TextStyle(color: textPrimary, height: 1.5),
          bodySmall: TextStyle(color: textSecondary, height: 1.4),
          labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(color: textSecondary),
          labelSmall: TextStyle(color: textSecondary),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: brightness == Brightness.dark ? Colors.black : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary.withValues(alpha: 0.4),
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: textSecondary.withValues(alpha: 0.1),
        thickness: 0.5,
      ),
      iconTheme: IconThemeData(color: textSecondary),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: accent.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: textPrimary, fontSize: 13),
        side: BorderSide(color: accent.withValues(alpha: 0.15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // ─────────────────────────────────────
  // OBSIDIAN
  // ─────────────────────────────────────
  static ThemeData get obsidianDark => _buildTheme(
        background: _obsidianDark,
        surface: const Color(0xFF141414),
        accent: _obsidianAccent,
        textPrimary: const Color(0xFFE8E8E8),
        textSecondary: const Color(0xFF888888),
        brightness: Brightness.dark,
      );

  static ThemeData get obsidianLight => _buildTheme(
        background: _obsidianLight,
        surface: Colors.white,
        accent: const Color(0xFF2A2A2A),
        textPrimary: const Color(0xFF1A1A1A),
        textSecondary: const Color(0xFF6B6B6B),
        brightness: Brightness.light,
      );

  // ─────────────────────────────────────
  // ASH
  // ─────────────────────────────────────
  static ThemeData get ashDark => _buildTheme(
        background: _ashDark,
        surface: const Color(0xFF363636),
        accent: _ashAccent,
        textPrimary: const Color(0xFFE8E4DE),
        textSecondary: const Color(0xFF9A9590),
        brightness: Brightness.dark,
      );

  static ThemeData get ashLight => _buildTheme(
        background: _ashLight,
        surface: const Color(0xFFFAF8F5),
        accent: const Color(0xFF5C5650),
        textPrimary: const Color(0xFF2A2520),
        textSecondary: const Color(0xFF8A8580),
        brightness: Brightness.light,
      );

  // ─────────────────────────────────────
  // INK
  // ─────────────────────────────────────
  static ThemeData get inkDark => _buildTheme(
        background: _inkDark,
        surface: const Color(0xFF162538),
        accent: _inkAccent,
        textPrimary: const Color(0xFFE2E8F0),
        textSecondary: const Color(0xFF718096),
        brightness: Brightness.dark,
      );

  static ThemeData get inkLight => _buildTheme(
        background: _inkLight,
        surface: Colors.white,
        accent: const Color(0xFF319795),
        textPrimary: const Color(0xFF1A202C),
        textSecondary: const Color(0xFF718096),
        brightness: Brightness.light,
      );

  // ─────────────────────────────────────
  // PAPER
  // ─────────────────────────────────────
  static ThemeData get paperDark => _buildTheme(
        background: _paperDark,
        surface: const Color(0xFF262626),
        accent: const Color(0xFFD4CFC8),
        textPrimary: const Color(0xFFE8E4DE),
        textSecondary: const Color(0xFF8A8580),
        brightness: Brightness.dark,
      );

  static ThemeData get paperLight => _buildTheme(
        background: _paperLight,
        surface: const Color(0xFFFFFDF5),
        accent: _paperAccent,
        textPrimary: const Color(0xFF2D2D2D),
        textSecondary: const Color(0xFF7A7A7A),
        brightness: Brightness.light,
      );

  // ─────────────────────────────────────
  // EMBER
  // ─────────────────────────────────────
  static ThemeData get emberDark => _buildTheme(
        background: _emberDark,
        surface: const Color(0xFF261E18),
        accent: _emberAccent,
        textPrimary: const Color(0xFFF0E6DC),
        textSecondary: const Color(0xFF9A8878),
        brightness: Brightness.dark,
      );

  static ThemeData get emberLight => _buildTheme(
        background: _emberLight,
        surface: Colors.white,
        accent: const Color(0xFFC07B3F),
        textPrimary: const Color(0xFF2D2420),
        textSecondary: const Color(0xFF8A7A6A),
        brightness: Brightness.light,
      );

  // ─────────────────────────────────────
  // Getters by name
  // ─────────────────────────────────────
  static ThemeData getTheme(String name, bool isDark) {
    switch (name.toLowerCase()) {
      case 'obsidian':
        return isDark ? obsidianDark : obsidianLight;
      case 'ash':
        return isDark ? ashDark : ashLight;
      case 'ink':
        return isDark ? inkDark : inkLight;
      case 'paper':
        return isDark ? paperDark : paperLight;
      case 'ember':
        return isDark ? emberDark : emberLight;
      default:
        return isDark ? obsidianDark : obsidianLight;
    }
  }

  /// Get the accent color for a theme by name.
  static Color getAccentColor(String name, bool isDark) {
    switch (name.toLowerCase()) {
      case 'obsidian':
        return isDark ? _obsidianAccent : const Color(0xFF2A2A2A);
      case 'ash':
        return isDark ? _ashAccent : const Color(0xFF5C5650);
      case 'ink':
        return isDark ? _inkAccent : const Color(0xFF319795);
      case 'paper':
        return isDark ? const Color(0xFFD4CFC8) : _paperAccent;
      case 'ember':
        return isDark ? _emberAccent : const Color(0xFFC07B3F);
      default:
        return isDark ? _obsidianAccent : const Color(0xFF2A2A2A);
    }
  }

  /// Get the base background color for a theme by name.
  static Color getBaseColor(String name, bool isDark) {
    switch (name.toLowerCase()) {
      case 'obsidian':
        return isDark ? _obsidianDark : _obsidianLight;
      case 'ash':
        return isDark ? _ashDark : _ashLight;
      case 'ink':
        return isDark ? _inkDark : _inkLight;
      case 'paper':
        return isDark ? _paperDark : _paperLight;
      case 'ember':
        return isDark ? _emberDark : _emberLight;
      default:
        return isDark ? _obsidianDark : _obsidianLight;
    }
  }
}
