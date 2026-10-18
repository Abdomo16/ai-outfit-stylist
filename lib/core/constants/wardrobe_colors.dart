import 'package:flutter/material.dart';

/// Garment color names. Mirrors `models/colors.py` in the AI backend.
class WardrobeColors {
  static const Map<String, Color> swatches = {
    'white': Color(0xFFFFFFFF),
    'cream': Color(0xFFF3E9D2),
    'beige': Color(0xFFE8DCC8),
    'tan': Color(0xFFC19A6B),
    'khaki': Color(0xFFC3B091),
    'brown': Color(0xFF6F4E37),
    'light grey': Color(0xFFD3D3D3),
    'grey': Color(0xFF8E8E8E),
    'charcoal': Color(0xFF404040),
    'black': Color(0xFF111111),
    'navy': Color(0xFF1F2A44),
    'blue': Color(0xFF2A52BE),
    'light blue': Color(0xFFA7C7E7),
    'teal': Color(0xFF2A7F86),
    'green': Color(0xFF2E8B57),
    'olive': Color(0xFF556B2F),
    'yellow': Color(0xFFF4D03F),
    'orange': Color(0xFFF28C28),
    'red': Color(0xFFC62828),
    'burgundy': Color(0xFF6D2135),
    'pink': Color(0xFFF4A6B8),
    'purple': Color(0xFF6A0DAD),
  };

  static List<String> get names => swatches.keys.toList();

  /// Values written by the old detector and the old edit screen.
  static const Map<String, String> _legacy = {
    'maroon': 'burgundy',
    'cyan': 'light blue',
    'indigo': 'navy',
    'gray': 'grey',
  };

  /// The current name for a stored color, or the trimmed lowercase value.
  static String canonical(String? name) {
    final key = (name ?? '').trim().toLowerCase();
    return _legacy[key] ?? key;
  }

  static bool isKnown(String? name) => swatches.containsKey(canonical(name));

  static Color? parseHex(String? hex) {
    if (hex == null) return null;
    var value = hex.trim().replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  /// The measured color when there is one, otherwise the name's swatch.
  static Color? swatchFor(String? name, String? hex) =>
      parseHex(hex) ?? swatches[canonical(name)];

  static String hexOf(String name) {
    final color = swatches[canonical(name)];
    if (color == null) return '';
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }
}
