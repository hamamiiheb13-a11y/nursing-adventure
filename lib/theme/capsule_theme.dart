import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CapsuleColors {
  // Core Luminous Ocean Sci-Med Arcade Surfaces (replaces harsh black/maroon)
  static const Color deepOcean = Color(0xFF0B253C);
  static const Color oceanSurface = Color(0xFF113552);
  static const Color cardOcean = Color(0xFF174266);
  static const Color cardBorder = Color(0x407DD3FC);

  // Semantic Aliases for clean compatibility across components
  static const Color darkNavy = deepOcean;
  static const Color surfaceNavy = oceanSurface;
  static const Color cardNavy = cardOcean;

  // Coherent Vibrant Arcade Palette
  static const Color oceanBlue = Color(0xFF0EA5E9);
  static const Color electricBlue = oceanBlue;
  static const Color cyanGlow = Color(0xFF22D3EE);
  static const Color turquoise = Color(0xFF14B8A6);
  static const Color mintGreen = Color(0xFF34D399);
  static const Color mintGlow = mintGreen;
  static const Color softViolet = Color(0xFFA78BFA);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color coral = Color(0xFFFB7185);
  static const Color dangerRed = Color(0xFFF43F5E);
  static const Color dangerOrange = Color(0xFFFB923C);
  static const Color successGreen = mintGreen;
  static const Color gold = Color(0xFFFBBF24);

  // High-Contrast Crisp Typography
  static const Color textWhite = Color(0xFFF8FAFC);
  static const Color textSubtle = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF94A3B8);
}

class CapsuleFonts {
  static TextStyle heading({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w900,
    Color color = CapsuleColors.textWhite,
    double letterSpacing = 1.0,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle arcadeNumber({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w800,
    Color color = CapsuleColors.textWhite,
    double letterSpacing = 0.8,
  }) {
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle subtitle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    Color color = CapsuleColors.cyanGlow,
    double letterSpacing = 0.6,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double fontSize = 13.5,
    FontWeight fontWeight = FontWeight.w500,
    Color color = CapsuleColors.textSubtle,
    double? height = 1.45,
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
    double letterSpacing = 1.0,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
