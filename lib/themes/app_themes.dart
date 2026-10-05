import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Specification for an app theme definition.
class ThemeDefinition {
  final String name;
  final String category; // 'Dichrome', 'Trichrome', etc.
  final Color background;
  final Color surface;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Brightness brightness;

  const ThemeDefinition({
    required this.name,
    required this.category,
    required this.background,
    required this.surface,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.brightness,
  });
}

/// Preset themes for the Interceptor app.
class AppThemes {
  AppThemes._();

  // ─────────────────────────────────────
  // Theme definitions
  // ─────────────────────────────────────

  // Dichrome: Velvet Charcoal (Dark)
  // Background: #0D0D0D (RGB 13, 13, 13)
  // Accent & Text: #CEC0B3 (Almond Suede, RGB 206, 192, 179)
  static const velvetCharcoal = ThemeDefinition(
    name: 'Velvet Charcoal',
    category: 'Dichrome',
    background: Color(0xFF0D0D0D),
    surface: Color(0xFF161616),
    accent: Color(0xFFCEC0B3),
    textPrimary: Color(0xFFCEC0B3),
    textSecondary: Color(0xFF9E9287),
    brightness: Brightness.dark,
  );

  // Dichrome: Almond Suede (Light)
  // Background: #CEC0B3 (RGB 206, 192, 179)
  // Accent & Text: #0D0D0D (Velvet Charcoal, RGB 13, 13, 13)
  static const almondSuede = ThemeDefinition(
    name: 'Almond Suede',
    category: 'Dichrome',
    background: Color(0xFFCEC0B3),
    surface: Color(0xFFD6C8BB),
    accent: Color(0xFF0D0D0D),
    textPrimary: Color(0xFF0D0D0D),
    textSecondary: Color(0xFF3F3B37),
    brightness: Brightness.light,
  );

  // Dichrome: Our Étoile (Dark)
  // Background: #1C352D (Dark Forest Green)
  // Accent & Text: #F8F0E5 (Warm Linen Cream)
  static const ourEtoileDark = ThemeDefinition(
    name: 'Our Étoile',
    category: 'Dichrome',
    background: Color(0xFF1C352D),
    surface: Color(0xFF244239),
    accent: Color(0xFFF8F0E5),
    textPrimary: Color(0xFFF8F0E5),
    textSecondary: Color(0xFFAEB8B3),
    brightness: Brightness.dark,
  );

  // Dichrome: Our Étoile (Light)
  // Background: #F8F0E5 (Warm Linen Cream)
  // Accent & Text: #1C352D (Dark Forest Green)
  static const ourEtoileLight = ThemeDefinition(
    name: 'Our Étoile',
    category: 'Dichrome',
    background: Color(0xFFF8F0E5),
    surface: Color(0xFFEDE4D7),
    accent: Color(0xFF1C352D),
    textPrimary: Color(0xFF1C352D),
    textSecondary: Color(0xFF5A6E66),
    brightness: Brightness.light,
  );

  // Dichrome: Forest Moss (Dark) & Vanilla Silk (Light)
  static const forestMoss = ThemeDefinition(
    name: 'Forest Moss',
    category: 'Dichrome',
    background: Color(0xFF4E6B45),
    surface: Color(0xFF445E3C),
    accent: Color(0xFFF4E8D0),
    textPrimary: Color(0xFFF4E8D0),
    textSecondary: Color(0xFFD6C8AF),
    brightness: Brightness.dark,
  );

  static const vanillaSilk = ThemeDefinition(
    name: 'Vanilla Silk',
    category: 'Dichrome',
    background: Color(0xFFF4E8D0),
    surface: Color(0xFFE9DDC4),
    accent: Color(0xFF4E6B45),
    textPrimary: Color(0xFF4E6B45),
    textSecondary: Color(0xFF6F8965),
    brightness: Brightness.light,
  );

  // Dichrome: Terracotta Bloom (Dark) & Sand Dune (Light)
  static const terracottaBloom = ThemeDefinition(
    name: 'Terracotta Bloom',
    category: 'Dichrome',
    background: Color(0xFFC96A4A),
    surface: Color(0xFFB55D3E),
    accent: Color(0xFFEEDCC8),
    textPrimary: Color(0xFFEEDCC8),
    textSecondary: Color(0xFFDFCCB7),
    brightness: Brightness.dark,
  );

  static const sandDune = ThemeDefinition(
    name: 'Sand Dune',
    category: 'Dichrome',
    background: Color(0xFFEEDCC8),
    surface: Color(0xFFE2CFBA),
    accent: Color(0xFFC96A4A),
    textPrimary: Color(0xFFC96A4A),
    textSecondary: Color(0xFF8F432A),
    brightness: Brightness.light,
  );

  // Dichrome: Indigo Night (Dark) & Wisteria Glow (Light)
  static const indigoNight = ThemeDefinition(
    name: 'Indigo Night',
    category: 'Dichrome',
    background: Color(0xFF2D4275),
    surface: Color(0xFF243661),
    accent: Color(0xFFD6C6F7),
    textPrimary: Color(0xFFD6C6F7),
    textSecondary: Color(0xFFB7A5DC),
    brightness: Brightness.dark,
  );

  static const wisteriaGlow = ThemeDefinition(
    name: 'Wisteria Glow',
    category: 'Dichrome',
    background: Color(0xFFD6C6F7),
    surface: Color(0xFFC8B7EB),
    accent: Color(0xFF2D4275),
    textPrimary: Color(0xFF2D4275),
    textSecondary: Color(0xFF566997),
    brightness: Brightness.light,
  );

  // Dichrome: Dark Olive (Dark) & Off-White (Light)
  static const darkOlive = ThemeDefinition(
    name: 'Dark Olive',
    category: 'Dichrome',
    background: Color(0xFF4B4D39),
    surface: Color(0xFF3F4130),
    accent: Color(0xFFFEFBF6),
    textPrimary: Color(0xFFFEFBF6),
    textSecondary: Color(0xFFD2D0C9),
    brightness: Brightness.dark,
  );

  static const offWhite = ThemeDefinition(
    name: 'Off-White',
    category: 'Dichrome',
    background: Color(0xFFFEFBF6),
    surface: Color(0xFFF3EFE9),
    accent: Color(0xFF4B4D39),
    textPrimary: Color(0xFF4B4D39),
    textSecondary: Color(0xFF6F725A),
    brightness: Brightness.light,
  );

  // Dichrome: Brick Orange (Dark) & Light Yellow (Light)
  static const brickOrange = ThemeDefinition(
    name: 'Brick Orange',
    category: 'Dichrome',
    background: Color(0xFFC14A09),
    surface: Color(0xFFAD4006),
    accent: Color(0xFFFFFFC5),
    textPrimary: Color(0xFFFFFFC5),
    textSecondary: Color(0xFFE2E2A8),
    brightness: Brightness.dark,
  );

  static const lightYellow = ThemeDefinition(
    name: 'Light Yellow',
    category: 'Dichrome',
    background: Color(0xFFFFFFC5),
    surface: Color(0xFFF5F5B5),
    accent: Color(0xFFC14A09),
    textPrimary: Color(0xFFC14A09),
    textSecondary: Color(0xFF8E3403),
    brightness: Brightness.light,
  );

  // Dichrome: Palm Leaf (Dark) & Ambrosia Ivory (Light)
  static const palmLeaf = ThemeDefinition(
    name: 'Palm Leaf',
    category: 'Dichrome',
    background: Color(0xFF6F9940),
    surface: Color(0xFF608535),
    accent: Color(0xFFFFF4EB),
    textPrimary: Color(0xFFFFF4EB),
    textSecondary: Color(0xFFDED3C9),
    brightness: Brightness.dark,
  );

  static const ambrosiaIvory = ThemeDefinition(
    name: 'Ambrosia Ivory',
    category: 'Dichrome',
    background: Color(0xFFFFF4EB),
    surface: Color(0xFFF4E5D9),
    accent: Color(0xFF6F9940),
    textPrimary: Color(0xFF6F9940),
    textSecondary: Color(0xFF50722A),
    brightness: Brightness.light,
  );

  // Dichrome: Rich Black (Dark) & Gold (Light)
  static const richBlack = ThemeDefinition(
    name: 'Rich Black',
    category: 'Dichrome',
    background: Color(0xFF000812),
    surface: Color(0xFF0B1420),
    accent: Color(0xFFF5CE0A),
    textPrimary: Color(0xFFF5CE0A),
    textSecondary: Color(0xFFC7A708),
    brightness: Brightness.dark,
  );

  static const gold = ThemeDefinition(
    name: 'Gold',
    category: 'Dichrome',
    background: Color(0xFFF5CE0A),
    surface: Color(0xFFE5C009),
    accent: Color(0xFF000812),
    textPrimary: Color(0xFF000812),
    textSecondary: Color(0xFF2C3440),
    brightness: Brightness.light,
  );

  // Dichrome: Feldgrau (Dark) & Wheat (Light)
  static const feldgrau = ThemeDefinition(
    name: 'Feldgrau',
    category: 'Dichrome',
    background: Color(0xFF3A4B41),
    surface: Color(0xFF313F37),
    accent: Color(0xFFE6CFA7),
    textPrimary: Color(0xFFE6CFA7),
    textSecondary: Color(0xFFC4B08C),
    brightness: Brightness.dark,
  );

  static const wheat = ThemeDefinition(
    name: 'Wheat',
    category: 'Dichrome',
    background: Color(0xFFE6CFA7),
    surface: Color(0xFFD9C29A),
    accent: Color(0xFF3A4B41),
    textPrimary: Color(0xFF3A4B41),
    textSecondary: Color(0xFF55695C),
    brightness: Brightness.light,
  );

  // Dichrome: Noctis (Dark) & Marigold (Light)
  static const noctis = ThemeDefinition(
    name: 'Noctis',
    category: 'Dichrome',
    background: Color(0xFF1F2235),
    surface: Color(0xFF181A2A),
    accent: Color(0xFFE3A419),
    textPrimary: Color(0xFFE3A419),
    textSecondary: Color(0xFFBE8814),
    brightness: Brightness.dark,
  );

  static const marigold = ThemeDefinition(
    name: 'Marigold',
    category: 'Dichrome',
    background: Color(0xFFE3A419),
    surface: Color(0xFFD29614),
    accent: Color(0xFF1F2235),
    textPrimary: Color(0xFF1F2235),
    textSecondary: Color(0xFF45485E),
    brightness: Brightness.light,
  );

  // Dichrome: Noir de Vigne (Dark) & Champagne Vigne (Light)
  static const noirDeVigne = ThemeDefinition(
    name: 'Noir de Vigne',
    category: 'Dichrome',
    background: Color(0xFF111A19),
    surface: Color(0xFF192423),
    accent: Color(0xFFD5B97B),
    textPrimary: Color(0xFFD5B97B),
    textSecondary: Color(0xFFB89E66),
    brightness: Brightness.dark,
  );

  static const champagneVigne = ThemeDefinition(
    name: 'Champagne Vigne',
    category: 'Dichrome',
    background: Color(0xFFD5B97B),
    surface: Color(0xFFC7AB6E),
    accent: Color(0xFF111A19),
    textPrimary: Color(0xFF111A19),
    textSecondary: Color(0xFF3A4544),
    brightness: Brightness.light,
  );

  // Dichrome: Starry Green (Dark) & Starry Mint (Light)
  static const starryGreen = ThemeDefinition(
    name: 'Starry Green',
    category: 'Dichrome',
    background: Color(0xFF254637),
    surface: Color(0xFF1D382C),
    accent: Color(0xFFDCE7E1),
    textPrimary: Color(0xFFDCE7E1),
    textSecondary: Color(0xFFB5C5BD),
    brightness: Brightness.dark,
  );

  static const starryMint = ThemeDefinition(
    name: 'Starry Mint',
    category: 'Dichrome',
    background: Color(0xFFDCE7E1),
    surface: Color(0xFFCDDAD4),
    accent: Color(0xFF254637),
    textPrimary: Color(0xFF254637),
    textSecondary: Color(0xFF456B59),
    brightness: Brightness.light,
  );

  // Dichrome: Dark Turquoise (Dark) & Pale Turquoise (Light)
  static const darkTurquoise = ThemeDefinition(
    name: 'Dark Turquoise',
    category: 'Dichrome',
    background: Color(0xFF020B09),
    surface: Color(0xFF0A1513),
    accent: Color(0xFFD8E6E2),
    textPrimary: Color(0xFFD8E6E2),
    textSecondary: Color(0xFFB0C4BF),
    brightness: Brightness.dark,
  );

  static const paleTurquoise = ThemeDefinition(
    name: 'Pale Turquoise',
    category: 'Dichrome',
    background: Color(0xFFD8E6E2),
    surface: Color(0xFFCAD9D5),
    accent: Color(0xFF020B09),
    textPrimary: Color(0xFF020B09),
    textSecondary: Color(0xFF2A3D38),
    brightness: Brightness.light,
  );

  // Dichrome: Dark Olive Green (Dark) & Cream (Light)
  static const darkOliveGreen = ThemeDefinition(
    name: 'Dark Olive Green',
    category: 'Dichrome',
    background: Color(0xFF556B2F),
    surface: Color(0xFF495C27),
    accent: Color(0xFFFFFDD0),
    textPrimary: Color(0xFFFFFDD0),
    textSecondary: Color(0xFFD6D4A8),
    brightness: Brightness.dark,
  );

  static const cream = ThemeDefinition(
    name: 'Cream',
    category: 'Dichrome',
    background: Color(0xFFFFFDD0),
    surface: Color(0xFFF3F1C2),
    accent: Color(0xFF556B2F),
    textPrimary: Color(0xFF556B2F),
    textSecondary: Color(0xFF425424),
    brightness: Brightness.light,
  );

  // Dichrome: Astorath Red (Dark) & Spirited Yellow (Light)
  static const astorathRed = ThemeDefinition(
    name: 'Astorath Red',
    category: 'Dichrome',
    background: Color(0xFFDF4D2E),
    surface: Color(0xFFC83F22),
    accent: Color(0xFFFEDD81),
    textPrimary: Color(0xFFFEDD81),
    textSecondary: Color(0xFFE4C56E),
    brightness: Brightness.dark,
  );

  static const spiritedYellow = ThemeDefinition(
    name: 'Spirited Yellow',
    category: 'Dichrome',
    background: Color(0xFFFEDD81),
    surface: Color(0xFFF0CE71),
    accent: Color(0xFFDF4D2E),
    textPrimary: Color(0xFFDF4D2E),
    textSecondary: Color(0xFF9E2C14),
    brightness: Brightness.light,
  );

  // Dichrome: Noir Fiction (Dark) & Aurora Red (Light)
  static const noirFiction = ThemeDefinition(
    name: 'Noir Fiction',
    category: 'Dichrome',
    background: Color(0xFF120B13),
    surface: Color(0xFF1D141F),
    accent: Color(0xFFDF4D2E),
    textPrimary: Color(0xFFDF4D2E),
    textSecondary: Color(0xFFB53E24),
    brightness: Brightness.dark,
  );

  static const auroraRed = ThemeDefinition(
    name: 'Aurora Red',
    category: 'Dichrome',
    background: Color(0xFFC43433),
    surface: Color(0xFFB32F2E),
    accent: Color(0xFFFEDD81),
    textPrimary: Color(0xFFFEDD81),
    textSecondary: Color(0xFFE2C470),
    brightness: Brightness.light,
  );

  // Dichrome: Sinister (Dark) & Solar Fusion (Light)
  static const sinister = ThemeDefinition(
    name: 'Sinister',
    category: 'Dichrome',
    background: Color(0xFF11120A),
    surface: Color(0xFF1A1C10),
    accent: Color(0xFFDC9D4A),
    textPrimary: Color(0xFFDC9D4A),
    textSecondary: Color(0xFFBC843C),
    brightness: Brightness.dark,
  );

  static const solarFusion = ThemeDefinition(
    name: 'Solar Fusion',
    category: 'Dichrome',
    background: Color(0xFFDC9D4A),
    surface: Color(0xFFCD8E3C),
    accent: Color(0xFF11120A),
    textPrimary: Color(0xFF11120A),
    textSecondary: Color(0xFF383A26),
    brightness: Brightness.light,
  );

  // Dichrome: Black Pearl (Dark) & Burnt Orange (Light)
  static const blackPearl = ThemeDefinition(
    name: 'Black Pearl',
    category: 'Dichrome',
    background: Color(0xFF1A2C30),
    surface: Color(0xFF142327),
    accent: Color(0xFFFE7E3C),
    textPrimary: Color(0xFFFE7E3C),
    textSecondary: Color(0xFFD6692E),
    brightness: Brightness.dark,
  );

  static const burntOrange = ThemeDefinition(
    name: 'Burnt Orange',
    category: 'Dichrome',
    background: Color(0xFFFE7E3C),
    surface: Color(0xFFE86F2F),
    accent: Color(0xFF1A2C30),
    textPrimary: Color(0xFF1A2C30),
    textSecondary: Color(0xFF2C4349),
    brightness: Brightness.light,
  );

  // Dichrome: Blue Lagoon (Dark) & Lust (Light)
  static const blueLagoon = ThemeDefinition(
    name: 'Blue Lagoon',
    category: 'Dichrome',
    background: Color(0xFF0E6873),
    surface: Color(0xFF0B555E),
    accent: Color(0xFFFE7E3C),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA5CFD4),
    brightness: Brightness.dark,
  );

  static const lust = ThemeDefinition(
    name: 'Lust',
    category: 'Dichrome',
    background: Color(0xFFE4201B),
    surface: Color(0xFFCF1D18),
    accent: Color(0xFF0E6873),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFFFB8B5),
    brightness: Brightness.light,
  );

  // Dichrome: Copper (Dark)
  static const copper = ThemeDefinition(
    name: 'Copper',
    category: 'Dichrome',
    background: Color(0xFF61413C),
    surface: Color(0xFF523631),
    accent: Color(0xFFFE7E3C),
    textPrimary: Color(0xFFFE7E3C),
    textSecondary: Color(0xFFD6ABA3),
    brightness: Brightness.dark,
  );

  static const defaultDark = ThemeDefinition(
    name: 'Default',
    category: 'Dichrome',
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF141414),
    accent: Color(0xFFE0E0E0),
    textPrimary: Color(0xFFE8E8E8),
    textSecondary: Color(0xFF888888),
    brightness: Brightness.dark,
  );

  static const defaultLight = ThemeDefinition(
    name: 'Default',
    category: 'Dichrome',
    background: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    accent: Color(0xFF2A2A2A),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF6B6B6B),
    brightness: Brightness.light,
  );

  static const List<ThemeDefinition> darkThemeDefs = [
    velvetCharcoal,
    ourEtoileDark,
    forestMoss,
    terracottaBloom,
    indigoNight,
    darkOlive,
    brickOrange,
    palmLeaf,
    richBlack,
    feldgrau,
    noctis,
    noirDeVigne,
    starryGreen,
    darkTurquoise,
    darkOliveGreen,
    astorathRed,
    noirFiction,
    sinister,
    blackPearl,
    blueLagoon,
    copper,
    defaultDark,
  ];

  static const List<ThemeDefinition> lightThemeDefs = [
    almondSuede,
    ourEtoileLight,
    vanillaSilk,
    sandDune,
    wisteriaGlow,
    offWhite,
    lightYellow,
    ambrosiaIvory,
    gold,
    wheat,
    marigold,
    champagneVigne,
    starryMint,
    paleTurquoise,
    cream,
    spiritedYellow,
    auroraRed,
    solarFusion,
    burntOrange,
    lust,
    defaultLight,
  ];

  static const Map<String, String> _darkToLight = {
    'Velvet Charcoal': 'Almond Suede',
    'Our Étoile': 'Our Étoile',
    'Forest Moss': 'Vanilla Silk',
    'Terracotta Bloom': 'Sand Dune',
    'Indigo Night': 'Wisteria Glow',
    'Dark Olive': 'Off-White',
    'Brick Orange': 'Light Yellow',
    'Palm Leaf': 'Ambrosia Ivory',
    'Rich Black': 'Gold',
    'Feldgrau': 'Wheat',
    'Noctis': 'Marigold',
    'Noir de Vigne': 'Champagne Vigne',
    'Starry Green': 'Starry Mint',
    'Dark Turquoise': 'Pale Turquoise',
    'Dark Olive Green': 'Cream',
    'Astorath Red': 'Spirited Yellow',
    'Noir Fiction': 'Aurora Red',
    'Sinister': 'Solar Fusion',
    'Black Pearl': 'Burnt Orange',
    'Blue Lagoon': 'Lust',
    'Copper': 'Burnt Orange',
    'Default': 'Default',
  };

  static const Map<String, String> _lightToDark = {
    'Almond Suede': 'Velvet Charcoal',
    'Our Étoile': 'Our Étoile',
    'Vanilla Silk': 'Forest Moss',
    'Sand Dune': 'Terracotta Bloom',
    'Wisteria Glow': 'Indigo Night',
    'Off-White': 'Dark Olive',
    'Light Yellow': 'Brick Orange',
    'Ambrosia Ivory': 'Palm Leaf',
    'Gold': 'Rich Black',
    'Wheat': 'Feldgrau',
    'Marigold': 'Noctis',
    'Champagne Vigne': 'Noir de Vigne',
    'Starry Mint': 'Starry Green',
    'Pale Turquoise': 'Dark Turquoise',
    'Cream': 'Dark Olive Green',
    'Spirited Yellow': 'Astorath Red',
    'Aurora Red': 'Noir Fiction',
    'Solar Fusion': 'Sinister',
    'Burnt Orange': 'Black Pearl',
    'Lust': 'Blue Lagoon',
    'Default': 'Default',
  };

  static String getCounterpart(String name, bool targetIsDark) {
    if (targetIsDark) {
      return _lightToDark[name] ??
          (_darkToLight.containsKey(name) ? name : darkThemes.first);
    } else {
      return _darkToLight[name] ??
          (_lightToDark.containsKey(name) ? name : lightThemes.first);
    }
  }

  static List<String> get darkThemes =>
      darkThemeDefs.map((t) => t.name).toList();

  static List<String> get lightThemes =>
      lightThemeDefs.map((t) => t.name).toList();

  static List<String> getThemes(bool isDark) =>
      isDark ? darkThemes : lightThemes;

  /// Returns theme names filtered by mode and category (All, Dichrome, Trichrome).
  static List<String> getFilteredThemes(bool isDark, String filter) {
    final list = isDark ? darkThemeDefs : lightThemeDefs;
    final normalized = filter.trim().toLowerCase();
    if (normalized == 'all') {
      return list.map((t) => t.name).toList();
    }
    return list
        .where((t) => t.category.toLowerCase() == normalized)
        .map((t) => t.name)
        .toList();
  }

  static ThemeDefinition findTheme(String name, bool isDark) {
    final list = isDark ? darkThemeDefs : lightThemeDefs;
    final normalized = name.toLowerCase().replaceAll('é', 'e');

    // First try direct match
    final direct = list.where(
      (t) => t.name.toLowerCase().replaceAll('é', 'e') == normalized,
    );
    if (direct.isNotEmpty) return direct.first;

    // Check counterpart match (e.g. user selected 'Forest Moss' and switched to light mode -> gives 'Vanilla Silk')
    final counterpartName = getCounterpart(name, isDark);
    final counterpartNormalized =
        counterpartName.toLowerCase().replaceAll('é', 'e');
    final match = list.where(
      (t) => t.name.toLowerCase().replaceAll('é', 'e') == counterpartNormalized,
    );
    if (match.isNotEmpty) return match.first;

    return list.first;
  }

  // ─────────────────────────────────────
  // Theme builder
  // ─────────────────────────────────────
  static ThemeData _buildTheme(ThemeDefinition def) {
    final colorScheme = ColorScheme(
      brightness: def.brightness,
      primary: def.accent,
      onPrimary: def.brightness == Brightness.dark ? Colors.black : Colors.white,
      secondary: def.accent.withValues(alpha: 0.7),
      onSecondary: def.brightness == Brightness.dark ? Colors.black : Colors.white,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: def.surface,
      onSurface: def.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: def.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: def.background,
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge:
              TextStyle(color: def.textPrimary, fontWeight: FontWeight.w700),
          displayMedium:
              TextStyle(color: def.textPrimary, fontWeight: FontWeight.w600),
          displaySmall:
              TextStyle(color: def.textPrimary, fontWeight: FontWeight.w600),
          headlineLarge:
              TextStyle(color: def.textPrimary, fontWeight: FontWeight.w600),
          headlineMedium:
              TextStyle(color: def.textPrimary, fontWeight: FontWeight.w500),
          headlineSmall:
              TextStyle(color: def.textPrimary, fontWeight: FontWeight.w500),
          titleLarge:
              TextStyle(color: def.textPrimary, fontWeight: FontWeight.w600),
          titleMedium:
              TextStyle(color: def.textPrimary, fontWeight: FontWeight.w500),
          titleSmall:
              TextStyle(color: def.textSecondary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: def.textPrimary, height: 1.6),
          bodyMedium: TextStyle(color: def.textPrimary, height: 1.5),
          bodySmall: TextStyle(color: def.textSecondary, height: 1.4),
          labelLarge:
              TextStyle(color: def.textPrimary, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(color: def.textSecondary),
          labelSmall: TextStyle(color: def.textSecondary),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: def.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: def.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: def.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: def.accent,
          foregroundColor:
              def.brightness == Brightness.dark ? Colors.black : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: def.accent,
          side: BorderSide(color: def.accent.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: def.surface,
        hintStyle: TextStyle(color: def.textSecondary.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: def.accent.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: def.accent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: def.accent,
        unselectedItemColor: def.textSecondary.withValues(alpha: 0.4),
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: def.textSecondary.withValues(alpha: 0.15),
        thickness: 0.5,
      ),
      iconTheme: IconThemeData(color: def.textSecondary),
      chipTheme: ChipThemeData(
        backgroundColor: def.surface,
        selectedColor: def.accent.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: def.textPrimary, fontSize: 13),
        side: BorderSide(color: def.accent.withValues(alpha: 0.15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // ─────────────────────────────────────
  // Getters by name and mode
  // ─────────────────────────────────────
  static ThemeData getTheme(String name, bool isDark) {
    final def = findTheme(name, isDark);
    return _buildTheme(def);
  }

  /// Get the accent color for a theme by name.
  static Color getAccentColor(String name, bool isDark) {
    return findTheme(name, isDark).accent;
  }

  /// Get the base background color for a theme by name.
  static Color getBaseColor(String name, bool isDark) {
    return findTheme(name, isDark).background;
  }
}
