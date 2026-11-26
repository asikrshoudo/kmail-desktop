import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme textTheme(Color primary, Color secondary) {
    const font = 'Segoe UI';
    return TextTheme(
      displaySmall: TextStyle(fontFamily: font, fontSize: 32, height: 1.2, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: TextStyle(fontFamily: font, fontSize: 24, height: 1.25, fontWeight: FontWeight.w600, color: primary),
      titleLarge: TextStyle(fontFamily: font, fontSize: 20, height: 1.3, fontWeight: FontWeight.w600, color: primary),
      titleMedium: TextStyle(fontFamily: font, fontSize: 16, height: 1.35, fontWeight: FontWeight.w600, color: primary),
      titleSmall: TextStyle(fontFamily: font, fontSize: 14, height: 1.35, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontFamily: font, fontSize: 15, height: 1.5, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: TextStyle(fontFamily: font, fontSize: 14, height: 1.5, fontWeight: FontWeight.w400, color: primary),
      bodySmall: TextStyle(fontFamily: font, fontSize: 12, height: 1.45, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: TextStyle(fontFamily: font, fontSize: 13, height: 1.3, fontWeight: FontWeight.w600, color: primary),
      labelMedium: TextStyle(fontFamily: font, fontSize: 12, height: 1.3, fontWeight: FontWeight.w500, color: secondary),
      labelSmall: TextStyle(fontFamily: font, fontSize: 11, height: 1.3, fontWeight: FontWeight.w500, color: secondary),
    );
  }
}
