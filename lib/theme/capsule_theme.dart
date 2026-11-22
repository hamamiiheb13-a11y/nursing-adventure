import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CapsuleColors {
  static const Color darkNavy = Color(0xFF0A0E1A);
  static const Color surfaceNavy = Color(0xFF111827);
  static const Color cardNavy = Color(0xFF1E293B);
  static const Color electricBlue = Color(0xFF0066FF);
  static const Color cyanGlow = Color(0xFF00E5FF);
  static const Color turquoise = Color(0xFF00BCD4);
  static const Color purple = Color(0xFF7C3AED);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color dangerOrange = Color(0xFFF97316);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSubtle = Color(0xFF94A3B8);
  static const Color gold = Color(0xFFFFD166);
}

class CapsuleFonts {
  static TextStyle heading({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w900,
    Color color = CapsuleColors.textWhite,
    double letterSpacing = 1.2,
    double? height,
  }) {
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle subtitle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    Color color = CapsuleColors.turquoise,
    double letterSpacing = 1.0,
  }) {
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color color = CapsuleColors.textSubtle,
    double? height = 1.4,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle button({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w800,
    Color color = Colors.white,
    double letterSpacing = 1.2,
  }) {
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
