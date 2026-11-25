import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CapsuleColors {
  // Luminous Radiant Oceanic Cerulean Palette (Vibrant, bright, zero near-black surfaces)
  static const Color deepOcean = Color(0xFF0E4170);
  static const Color oceanSurface = Color(0xFF165B94);
  static const Color cardOcean = Color(0xFF1E6FA8);
  static const Color cardBorder = Color(0x665EEAD4);

  // Bright Clinical Reading Surfaces (High-contrast book-grade readability for Questions & Modals)
  static const Color frostSurface = Color(0xFFF4F9FF);
  static const Color frostCard = Color(0xFFE6F2FE);
  static const Color inkDark = Color(0xFF0C3154);
  static const Color inkMuted = Color(0xFF3A5F82);

  // Semantic Aliases for clean compatibility across components
  static const Color darkNavy = deepOcean;
  static const Color surfaceNavy = oceanSurface;
  static const Color cardNavy = cardOcean;

  // Coherent Vibrant Arcade Palette
  static const Color oceanBlue = Color(0xFF0EA5E9);
  static const Color electricBlue = Color(0xFF0284C7);
  static const Color cyanGlow = Color(0xFF22D3EE);
  static const Color turquoise = Color(0xFF2DD4BF);
  static const Color mintGreen = Color(0xFF34D399);
  static const Color mintGlow = mintGreen;
  static const Color softViolet = Color(0xFFA78BFA);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color coral = Color(0xFFFB7185);
  static const Color dangerRed = Color(0xFFF43F5E);
  static const Color dangerOrange = Color(0xFFFBBF24);
  static const Color successGreen = Color(0xFF10B981);
  static const Color gold = Color(0xFFFBBF24);
  static const Color amberGold = gold;

  // High-Contrast Crisp Typography
  static const Color textWhite = Color(0xFFF8FBFF);
  static const Color textSubtle = Color(0xFFD6E7F7);
  static const Color textMuted = Color(0xFFA6C3DF);
}

/// Smooth modern transition between GASTRO QUEST screens
Route<T> buildCapsuleRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.03, 0.0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
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
