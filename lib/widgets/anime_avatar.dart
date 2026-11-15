import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/character.dart';

class AnimeAvatar extends StatelessWidget {
  final CharacterId characterId;
  final double size;
  final bool showBadge;
  final bool isAnimated;
  final bool isWinner;

  const AnimeAvatar({
    super.key,
    required this.characterId,
    this.size = 64,
    this.showBadge = true,
    this.isAnimated = false,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    final character = Character.getById(characterId);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            character.primaryColor,
            character.secondaryColor,
          ],
        ),
        border: Border.all(
          color: isWinner ? const Color(0xFFFFD166) : character.accentColor,
          width: math.max(2.0, size * 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: (isWinner ? const Color(0xFFFFD166) : character.accentColor).withOpacity(0.4),
            blurRadius: size * 0.2,
            spreadRadius: size * 0.03,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: CustomPaint(
              size: Size(size, size),
              painter: AnimeCharacterPainter(
                characterId: characterId,
                primaryColor: character.primaryColor,
                secondaryColor: character.secondaryColor,
                accentColor: character.accentColor,
              ),
            ),
          ),
          if (showBadge && size >= 38)
            Positioned(
              bottom: -size * 0.05,
              right: -size * 0.05,
              child: Container(
                padding: EdgeInsets.all(size * 0.06),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: character.accentColor,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 4),
                  ],
                ),
                child: Icon(
                  character.badgeIcon,
                  size: size * 0.22,
                  color: Colors.black87,
                ),
              ),
            ),
          if (isWinner)
            Positioned(
              top: -size * 0.25,
              child: Icon(
                Icons.military_tech_rounded,
                size: size * 0.45,
                color: const Color(0xFFFFD166),
              ),
            ),
        ],
      ),
    );
  }
}

class AnimeCharacterPainter extends CustomPainter {
  final CharacterId characterId;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  AnimeCharacterPainter({
    required this.characterId,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;
    final h = size.height;

    // Background glow inside avatar
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [accentColor.withOpacity(0.35), primaryColor],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(center, w / 2, bgPaint);

    switch (characterId) {
      case CharacterId.lyra:
        _drawCaptainLyra(canvas, size);
        break;
      case CharacterId.kai:
        _drawKai(canvas, size);
        break;
      case CharacterId.aria:
        _drawAria(canvas, size);
        break;
      case CharacterId.jin:
        _drawDocJin(canvas, size);
        break;
    }
  }

  // 1. Captain Lyra: Trauma Fleet Commander (Navy blue captain hat, blonde/gold hair, confident smile)
  void _drawCaptainLyra(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Uniform Coat Shoulders
    final coatPaint = Paint()..color = const Color(0xFF0F3057);
    final coatPath = Path()
      ..moveTo(w * 0.1, h)
      ..quadraticBezierTo(w * 0.5, h * 0.68, w * 0.9, h)
      ..close();
    canvas.drawPath(coatPath, coatPaint);

    // Gold Epaulets
    final goldPaint = Paint()..color = const Color(0xFFFFD166);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.78, w * 0.2, h * 0.1), const Radius.circular(4)),
      goldPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.68, h * 0.78, w * 0.2, h * 0.1), const Radius.circular(4)),
      goldPaint,
    );

    // Stethoscope around neck
    final stethPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.72), width: w * 0.36, height: h * 0.3),
      0,
      math.pi,
      false,
      stethPaint,
    );

    // Neck & Face
    final skinPaint = Paint()..color = const Color(0xFFFFDFC4);
    canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.58, w * 0.16, h * 0.16), skinPaint);

    // Face oval
    final facePath = Path()
      ..moveTo(w * 0.28, h * 0.45)
      ..quadraticBezierTo(w * 0.28, h * 0.68, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.72, h * 0.68, w * 0.72, h * 0.45)
      ..close();
    canvas.drawPath(facePath, skinPaint);

    // Golden Anime Hair Bangs
    final hairPaint = Paint()..color = const Color(0xFFFEE440);
    final hairPath = Path()
      ..moveTo(w * 0.22, h * 0.48)
      ..quadraticBezierTo(w * 0.3, h * 0.2, w * 0.5, h * 0.22)
      ..quadraticBezierTo(w * 0.7, h * 0.2, w * 0.78, h * 0.48)
      ..quadraticBezierTo(w * 0.65, h * 0.42, w * 0.5, h * 0.52)
      ..quadraticBezierTo(w * 0.35, h * 0.42, w * 0.22, h * 0.48)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Captain Navy / Nurse Hat
    final hatPaint = Paint()..color = const Color(0xFF001E3D);
    final hatPath = Path()
      ..moveTo(w * 0.18, h * 0.3)
      ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.82, h * 0.3)
      ..lineTo(w * 0.78, h * 0.35)
      ..quadraticBezierTo(w * 0.5, h * 0.22, w * 0.22, h * 0.35)
      ..close();
    canvas.drawPath(hatPath, hatPaint);

    // Hat gold anchor emblem
    canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.08, goldPaint);
    final crossPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.22), width: w * 0.09, height: w * 0.03), crossPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.22), width: w * 0.03, height: w * 0.09), crossPaint);

    // Anime Eyes (Large turquoise eyes)
    final eyePaint = Paint()..color = const Color(0xFF00B4D8);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.4, h * 0.54), width: w * 0.09, height: h * 0.08), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.6, h * 0.54), width: w * 0.09, height: h * 0.08), eyePaint);

    // Eye sparkles
    final sparkPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.39, h * 0.52), w * 0.025, sparkPaint);
    canvas.drawCircle(Offset(w * 0.59, h * 0.52), w * 0.025, sparkPaint);

    // Confident smile
    final smilePaint = Paint()
      ..color = const Color(0xFFD90429)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.025;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.12, height: h * 0.06),
      0.2,
      math.pi - 0.4,
      false,
      smilePaint,
    );
  }

  // 2. Kai Swift: Surgical Ninja Medic (Turquoise headband, spiky black hair, intense eyes, mask/scrubs)
  void _drawKai(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scrubs Shoulders
    final scrubPaint = Paint()..color = const Color(0xFF0077B6);
    final scrubPath = Path()
      ..moveTo(w * 0.1, h)
      ..quadraticBezierTo(w * 0.5, h * 0.7, w * 0.9, h)
      ..close();
    canvas.drawPath(scrubPath, scrubPaint);

    // Skin
    final skinPaint = Paint()..color = const Color(0xFFFFDFBA);
    canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.58, w * 0.16, h * 0.16), skinPaint);

    // Face
    final facePath = Path()
      ..moveTo(w * 0.28, h * 0.45)
      ..quadraticBezierTo(w * 0.28, h * 0.68, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.72, h * 0.68, w * 0.72, h * 0.45)
      ..close();
    canvas.drawPath(facePath, skinPaint);

    // Spiky dark hair
    final hairPaint = Paint()..color = const Color(0xFF1D2D44);
    final hairPath = Path()
      ..moveTo(w * 0.18, h * 0.5)
      ..lineTo(w * 0.25, h * 0.2)
      ..lineTo(w * 0.38, h * 0.26)
      ..lineTo(w * 0.5, h * 0.12) // tall spike
      ..lineTo(w * 0.62, h * 0.26)
      ..lineTo(w * 0.75, h * 0.2)
      ..lineTo(w * 0.82, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.35, w * 0.18, h * 0.5)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Ninja Bandana (Turquoise / Cyan)
    final bandPaint = Paint()..color = const Color(0xFF00FFF5);
    canvas.drawRect(Rect.fromLTWH(w * 0.24, h * 0.36, w * 0.52, h * 0.1), bandPaint);

    // Metal forehead plate with red cross
    final platePaint = Paint()..color = const Color(0xFFE0E1DD);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.4, h * 0.37, w * 0.2, h * 0.08), const Radius.circular(3)),
      platePaint,
    );
    final redPaint = Paint()..color = const Color(0xFFEF233C);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.41), width: w * 0.08, height: w * 0.02), redPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.41), width: w * 0.02, height: w * 0.08), redPaint);

    // Surgical mask pulled down or sharp eyes
    final eyePaint = Paint()..color = const Color(0xFF0077B6);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.38, h * 0.54), width: w * 0.08, height: h * 0.06), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.62, h * 0.54), width: w * 0.08, height: h * 0.06), eyePaint);

    final sparkPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.37, h * 0.53), w * 0.02, sparkPaint);
    canvas.drawCircle(Offset(w * 0.61, h * 0.53), w * 0.02, sparkPaint);

    // Smirk
    final smirkPaint = Paint()
      ..color = const Color(0xFF2B2D42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;
    canvas.drawLine(Offset(w * 0.44, h * 0.64), Offset(w * 0.56, h * 0.63), smirkPaint);
  }

  // 3. Aria Blossom: Pediatric Navigator (Pink coral ribbons, gentle pink eyes, caring smile)
  void _drawAria(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Coral Nurse Uniform
    final uniformPaint = Paint()..color = const Color(0xFFD81159);
    final uniPath = Path()
      ..moveTo(w * 0.1, h)
      ..quadraticBezierTo(w * 0.5, h * 0.7, w * 0.9, h)
      ..close();
    canvas.drawPath(uniPath, uniformPaint);

    // White collar
    final collarPaint = Paint()..color = Colors.white;
    final collarPath = Path()
      ..moveTo(w * 0.35, h * 0.72)
      ..lineTo(w * 0.5, h * 0.85)
      ..lineTo(w * 0.65, h * 0.72)
      ..close();
    canvas.drawPath(collarPath, collarPaint);

    // Skin
    final skinPaint = Paint()..color = const Color(0xFFFFE0D2);
    canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.58, w * 0.16, h * 0.16), skinPaint);

    // Face
    final facePath = Path()
      ..moveTo(w * 0.28, h * 0.45)
      ..quadraticBezierTo(w * 0.28, h * 0.68, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.72, h * 0.68, w * 0.72, h * 0.45)
      ..close();
    canvas.drawPath(facePath, skinPaint);

    // Gentle flowing pink-auburn hair
    final hairPaint = Paint()..color = const Color(0xFFFF758F);
    final hairPath = Path()
      ..moveTo(w * 0.2, h * 0.6)
      ..quadraticBezierTo(w * 0.25, h * 0.18, w * 0.5, h * 0.18)
      ..quadraticBezierTo(w * 0.75, h * 0.18, w * 0.8, h * 0.6)
      ..quadraticBezierTo(w * 0.7, h * 0.38, w * 0.5, h * 0.46)
      ..quadraticBezierTo(w * 0.3, h * 0.38, w * 0.2, h * 0.6)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Nurse Headband with Flower/Cross
    final headBandPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.24, w * 0.44, h * 0.08), const Radius.circular(4)),
      headBandPaint,
    );
    final flowerPaint = Paint()..color = const Color(0xFFFF4D6D);
    canvas.drawCircle(Offset(w * 0.5, h * 0.28), w * 0.04, flowerPaint);

    // Large Anime Eyes (Rose Violet)
    final eyePaint = Paint()..color = const Color(0xFFC9184A);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.39, h * 0.53), width: w * 0.09, height: h * 0.08), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.61, h * 0.53), width: w * 0.09, height: h * 0.08), eyePaint);

    // Highlights
    final sparkPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.38, h * 0.51), w * 0.025, sparkPaint);
    canvas.drawCircle(Offset(w * 0.60, h * 0.51), w * 0.025, sparkPaint);

    // Warm Blush Cheeks
    final blushPaint = Paint()..color = const Color(0xFFFF758F).withOpacity(0.5);
    canvas.drawCircle(Offset(w * 0.34, h * 0.58), w * 0.035, blushPaint);
    canvas.drawCircle(Offset(w * 0.66, h * 0.58), w * 0.035, blushPaint);

    // Gentle smile
    final smilePaint = Paint()
      ..color = const Color(0xFFA4133C)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.025;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.63), width: w * 0.1, height: h * 0.05),
      0.1,
      math.pi - 0.2,
      false,
      smilePaint,
    );
  }

  // 4. Doc Jin: Pharmacology Sage (Deep purple coat, sleek anime doctor glasses, intellectual smirk)
  void _drawDocJin(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Doctor Lab Coat
    final coatPaint = Paint()..color = const Color(0xFF3C096C);
    final coatPath = Path()
      ..moveTo(w * 0.1, h)
      ..quadraticBezierTo(w * 0.5, h * 0.68, w * 0.9, h)
      ..close();
    canvas.drawPath(coatPath, coatPaint);

    // Shirt & Tie
    final shirtPaint = Paint()..color = const Color(0xFFE0AAFF);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.8), width: w * 0.18, height: h * 0.2), shirtPaint);
    final tiePaint = Paint()..color = const Color(0xFF9D4EDD);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.06, height: h * 0.15), tiePaint);

    // Skin
    final skinPaint = Paint()..color = const Color(0xFFFFDFC4);
    canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.58, w * 0.16, h * 0.16), skinPaint);

    // Face
    final facePath = Path()
      ..moveTo(w * 0.28, h * 0.45)
      ..quadraticBezierTo(w * 0.28, h * 0.68, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.72, h * 0.68, w * 0.72, h * 0.45)
      ..close();
    canvas.drawPath(facePath, skinPaint);

    // Sleek Dark Purple / Indigo Anime Hair
    final hairPaint = Paint()..color = const Color(0xFF240046);
    final hairPath = Path()
      ..moveTo(w * 0.22, h * 0.52)
      ..quadraticBezierTo(w * 0.28, h * 0.16, w * 0.5, h * 0.18)
      ..quadraticBezierTo(w * 0.72, h * 0.16, w * 0.78, h * 0.52)
      ..lineTo(w * 0.68, h * 0.38)
      ..lineTo(w * 0.52, h * 0.46)
      ..lineTo(w * 0.44, h * 0.38)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // Doctor Glasses (Sleek modern frames with cyan glare)
    final framePaint = Paint()
      ..color = const Color(0xFFFFD166)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;
    final glassGlass = Paint()..color = const Color(0x6600E5FF);

    final leftLens = Rect.fromCenter(center: Offset(w * 0.39, h * 0.52), width: w * 0.15, height: h * 0.08);
    final rightLens = Rect.fromCenter(center: Offset(w * 0.61, h * 0.52), width: w * 0.15, height: h * 0.08);

    canvas.drawRect(leftLens, glassGlass);
    canvas.drawRect(rightLens, glassGlass);
    canvas.drawRect(leftLens, framePaint);
    canvas.drawRect(rightLens, framePaint);
    canvas.drawLine(Offset(w * 0.465, h * 0.52), Offset(w * 0.535, h * 0.52), framePaint);

    // Eyes behind glasses
    final eyePaint = Paint()..color = const Color(0xFF7B2CBF);
    canvas.drawCircle(Offset(w * 0.39, h * 0.52), w * 0.03, eyePaint);
    canvas.drawCircle(Offset(w * 0.61, h * 0.52), w * 0.03, eyePaint);

    // Glasses Glare streak
    final glarePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(w * 0.34, h * 0.5), Offset(w * 0.42, h * 0.54), glarePaint);
    canvas.drawLine(Offset(w * 0.56, h * 0.5), Offset(w * 0.64, h * 0.54), glarePaint);

    // Wise Smirk
    final smirkPaint = Paint()
      ..color = const Color(0xFF10002B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025;
    canvas.drawLine(Offset(w * 0.46, h * 0.63), Offset(w * 0.55, h * 0.62), smirkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
