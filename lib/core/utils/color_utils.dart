import 'package:flutter/material.dart';

/// Utility class for color-related operations.
class ColorUtils {
  /// Converts a hex color string to a Color object.
  ///
  /// The hex color string should start with # and be followed by either 6 or 8 characters.
  /// For example, "#FF0000" or "#FFFF0000".
  ///
  /// Returns a default color (Colors.grey) if the hex string is invalid.
  static Color fromHex(String hexString) {
    if (hexString.isEmpty || !hexString.startsWith('#')) {
      return Colors.grey;
    }

    hexString = hexString.toUpperCase().replaceAll('#', '');
    if (hexString.length == 6) {
      hexString = 'FF$hexString';
    }

    try {
      final int colorValue = int.parse(hexString, radix: 16);
      return Color(colorValue);
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Converts a Color object to a hex color string.
  ///
  /// The resulting string starts with # and contains 8 characters (including alpha).
  /// For example, "#FFFF0000" for Colors.red.
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Returns a list of predefined colors for use in the application.
  static List<Color> getPredefinedColors() {
    return [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];
  }

  /// Returns a list of predefined colors as hex strings.
  static List<String> getPredefinedColorHexes() {
    return getPredefinedColors().map((color) => toHex(color)).toList();
  }
}