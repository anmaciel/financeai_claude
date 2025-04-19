// Tests for the ColorUtils functionality

import 'package:financeai/core/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorUtils Tests', () {
    test('fromHex converts valid hex colors correctly', () {
      // Test with full hex format #RRGGBB
      expect(ColorUtils.fromHex('#FF0000'), equals(Color(0xFFFF0000)));
      expect(ColorUtils.fromHex('#00FF00'), equals(Color(0xFF00FF00)));
      expect(ColorUtils.fromHex('#0000FF'), equals(Color(0xFF0000FF)));
    });

    test('fromHex handles hex values with and without hash', () {
      expect(ColorUtils.fromHex('FF0000'), equals(Colors.grey)); // Should return grey for invalid format
      expect(ColorUtils.fromHex('#FF0000'), equals(Color(0xFFFF0000)));
    });
    
    test('toHex converts Color objects to hex strings correctly', () {
      expect(ColorUtils.toHex(Color(0xFFFF0000)), '#FFFF0000');
      expect(ColorUtils.toHex(Color(0xFF00FF00)), '#FF00FF00');
      expect(ColorUtils.toHex(Color(0xFF0000FF)), '#FF0000FF');
    });
    
    test('getPredefinedColors returns a list of colors', () {
      final colors = ColorUtils.getPredefinedColors();
      expect(colors, isA<List<Color>>());
      expect(colors.isNotEmpty, true);
      expect(colors.contains(Colors.red), true);
      expect(colors.contains(Colors.green), true);
      expect(colors.contains(Colors.blue), true);
    });
    
    test('getPredefinedColorHexes returns a list of hex strings', () {
      final hexColors = ColorUtils.getPredefinedColorHexes();
      expect(hexColors, isA<List<String>>());
      expect(hexColors.isNotEmpty, true);
      expect(hexColors.every((hex) => hex.startsWith('#')), true);
    });
  });
}