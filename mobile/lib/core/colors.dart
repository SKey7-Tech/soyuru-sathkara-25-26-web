import 'package:flutter/material.dart';

/// SHARED — frozen after Phase 0.
///
/// Pulled from the website so the app and the site look like one product.
/// The site is Tailwind-based, so these are Tailwind's palette values that
/// app/components/* actually use (blue-600 for primary actions, green-600
/// for short notes, indigo-600 for the subject default).
class AppColors {
  const AppColors._();

  /// Tailwind blue-600 — the site's primary action colour.
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);

  /// Tailwind indigo-600 — the schema's default subjects.color_hex.
  static const Color secondary = Color(0xFF4F46E5);

  /// Tailwind green-600 — the site's short-notes accent.
  static const Color accent = Color(0xFF16A34A);

  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);

  /// Tailwind gray-50 — the site's page background.
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color surfaceDark = Color(0xFF0A0A0A);

  /// From globals.css :root.
  static const Color foregroundLight = Color(0xFF171717);
  static const Color foregroundDark = Color(0xFFEDEDED);

  /// Parses subjects.color_hex. The column is free text, so a content-entry
  /// typo must not take the home screen down — anything unparseable falls
  /// back to the schema default rather than throwing.
  ///
  /// Accepts '#RRGGBB', 'RRGGBB', '#AARRGGBB'.
  static Color fromHex(String? hex, {Color fallback = secondary}) {
    if (hex == null) return fallback;
    var value = hex.trim().replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return fallback;
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? fallback : Color(parsed);
  }
}
