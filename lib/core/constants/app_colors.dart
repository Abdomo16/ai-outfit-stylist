import 'package:flutter/material.dart';

/// Core design tokens that do not change between light and dark modes.
///
/// For theme-aware surface, background, and text colors use
/// `Theme.of(context).colorScheme` instead.
class AppColors {
  AppColors._();

  // ─── Accents ───
  static const Color primary = Color(0xFF8A3FFC); // vibrant purple
  static const Color primaryMuted = Color(0xFF6C2BD9);
  static const Color secondary = Color(0xFFFF7B6B); // coral
  static const Color tertiary = Color(0xFFB388FF); // soft lavender

  // ─── Utility ───
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // ─── Gradients ───
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8A3FFC), Color(0xFFB066FF)],
  );
}
