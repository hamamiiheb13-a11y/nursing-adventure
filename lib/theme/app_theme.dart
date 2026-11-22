import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Fond & Surfaces
  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Textes
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Couleurs d'action et médicales
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primaryTealPressed = Color(0xFF0F766E);
  static const Color primaryTealLight = Color(0xFFCCFBF1);
  static const Color primaryTealBorder = Color(0xFF0F766E);

  static const Color accentCobalt = Color(0xFF2563EB);
  static const Color accentCobaltPressed = Color(0xFF1D4ED8);
  static const Color accentCobaltLight = Color(0xFFDBEAFE);

  static const Color rewardAmber = Color(0xFFF59E0B);
  static const Color rewardAmberPressed = Color(0xFFD97706);
  static const Color rewardAmberLight = Color(0xFFFEF3C7);

  static const Color alertCoral = Color(0xFFE11D48);
  static const Color alertCoralPressed = Color(0xFFBE123C);
  static const Color alertCoralLight = Color(0xFFFFE4E6);

  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenLight = Color(0xFFD1FAE5);
}

class AppShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0C0F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x180F172A),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];
}

class AppTypography {
  static TextStyle titleLarge({Color color = AppColors.textPrimary, double size = 26, FontWeight weight = FontWeight.w800}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.5,
    );
  }

  static TextStyle titleMedium({Color color = AppColors.textPrimary, double size = 18, FontWeight weight = FontWeight.w700}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: -0.2,
    );
  }

  static TextStyle titleSmall({Color color = AppColors.textPrimary, double size = 15, FontWeight weight = FontWeight.w700}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle bodyLarge({Color color = AppColors.textPrimary, double size = 15, FontWeight weight = FontWeight.w500}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.45,
    );
  }

  static TextStyle bodyMedium({Color color = AppColors.textSecondary, double size = 13.5, FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle caption({Color color = AppColors.textMuted, double size = 11.5, FontWeight weight = FontWeight.w500}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 0.2,
    );
  }

  static TextStyle badge({Color color = AppColors.primaryTealPressed, double size = 11, FontWeight weight = FontWeight.w700}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: 0.5,
    );
  }
}
