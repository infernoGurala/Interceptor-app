import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

/// Specification for a typography pair (Head font for titles + Body font for content).
class FontPair {
  final String id;
  final String displayName;
  final String headFontName;
  final String bodyFontName;

  const FontPair({
    required this.id,
    required this.displayName,
    required this.headFontName,
    required this.bodyFontName,
  });

  /// Text style for file titles and markdown headings (H1-H4).
  TextStyle headStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    if (headFontName.toLowerCase() == 'zodiak') {
      return TextStyle(
        fontFamily: 'Zodiak',
        fontFamilyFallback: const ['serif'],
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w700,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      );
    }

    // Default to Inter
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  /// Text style for normal body text, lists, and blockquotes.
  TextStyle bodyStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
    Color? backgroundColor,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    if (bodyFontName.toLowerCase().contains('jakarta')) {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
        backgroundColor: backgroundColor,
        decoration: decoration,
        decorationColor: decorationColor,
      );
    }

    // Default to Inter
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      backgroundColor: backgroundColor,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
}

/// Font pair presets and loader utilities.
class AppFonts {
  AppFonts._();

  static const defaultPair = FontPair(
    id: 'default',
    displayName: 'Default',
    headFontName: 'Inter',
    bodyFontName: 'Inter',
  );

  static const zodiakPair = FontPair(
    id: 'zodiak_jakarta',
    displayName: 'Zodiak / Plus Jakarta',
    headFontName: 'Zodiak',
    bodyFontName: 'Plus Jakarta',
  );

  static const List<FontPair> presets = [
    defaultPair,
    zodiakPair,
  ];

  static FontPair getFontPair(String nameOrId) {
    final q = nameOrId.trim().toLowerCase();
    if (q.contains('zodiak') || q.contains('jakarta')) {
      return zodiakPair;
    }
    return defaultPair;
  }

  static bool _zodiakLoaded = false;

  /// Ensures Zodiak font is registered into Flutter engine.
  /// Tries local asset bundle first; if not yet in runtime bundle, fetches from Fontshare CDN.
  static Future<void> ensureFontsLoaded() async {
    if (_zodiakLoaded) return;
    try {
      final regData = await rootBundle.load('assets/fonts/Zodiak-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/Zodiak-Bold.ttf');
      final loader = FontLoader('Zodiak');
      loader.addFont(Future.value(regData));
      loader.addFont(Future.value(boldData));
      await loader.load();
      _zodiakLoaded = true;
    } catch (_) {
      try {
        final regFuture = http.get(Uri.parse(
          'https://cdn.fontshare.com/wf/ECUEQQ5BLZLFJS3PPLWOEEVS7SQONQMH/WNTXEMDDVWUVWDURRKDXCJC6G7TMP277/TBWKTFSYABV4KN4GNIJMAOQUOTYBUWB3.ttf',
        ));
        final boldFuture = http.get(Uri.parse(
          'https://cdn.fontshare.com/wf/63K42MQSJZ57SBX4XJ4J7L4M5IM6V2HQ/DTT4Y5AJV6DYRVZQST5O4K2E6SESQNV3/VGG36BIEB6ODAX4ZN7UV43FK742PFGDV.ttf',
        ));
        final responses = await Future.wait([regFuture, boldFuture]);
        if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
          final loader = FontLoader('Zodiak');
          loader.addFont(Future.value(ByteData.view(responses[0].bodyBytes.buffer)));
          loader.addFont(Future.value(ByteData.view(responses[1].bodyBytes.buffer)));
          await loader.load();
          _zodiakLoaded = true;
        }
      } catch (_) {}
    }
  }
}
