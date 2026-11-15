import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../audio/audio_service.dart';
import '../models/character.dart';
import '../widgets/anime_avatar.dart';
import '../widgets/anime_background.dart';
import 'main_menu_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPlayNow() {
    AudioService().init();
    AudioService().playClick();
    AudioService().startBgm();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      body: AnimeBackground(
        showFloatingElements: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Clinical Fleet Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.anchor_rounded, color: Color(0xFF00E5FF), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'GRAND LINE MEDICAL FLEET',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: Color(0xFF00E5FF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Animated Logo Emblem
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        final val = math.sin(_floatController.value * math.pi * 2);
                        return Transform.translate(
                          offset: Offset(0, val * 8),
                          child: child,
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glowing ring
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [
                                  Color(0xFF00E5FF),
                                  Color(0xFF0077B6),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF00E5FF), Color(0xFF003566)],
                              ),
                              border: Border.all(color: const Color(0xFFFFD166), width: 3),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.local_hospital_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Game Title: NURSING ADVENTURE
                    Text(
                      'NURSING ADVENTURE',
                      style: TextStyle(
                        fontSize: isMobile ? 32 : 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFF00E5FF),
                              Color(0xFFFFD166),
                            ],
                          ).createShader(const Rect.fromLTWH(0, 0, 350, 70)),
                        shadows: [
                          Shadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.8),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                          const Shadow(
                            color: Colors.black87,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Subtitle: LEARN, PLAY & CHALLENGE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 25, height: 1.5, color: const Color(0xFFFFD166)),
                        const SizedBox(width: 10),
                        const Text(
                          'LEARN • PLAY • CHALLENGE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3.5,
                            color: Color(0xFFFFD166),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(width: 25, height: 1.5, color: const Color(0xFFFFD166)),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Character Crew Showcase
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'MEET THE MEDICAL ADVENTURE CREW',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                              color: Color(0xFF90E0EF),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: Character.allCharacters.map((c) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  children: [
                                    AnimeAvatar(characterId: c.id, size: isMobile ? 54 : 64),
                                    const SizedBox(height: 6),
                                    Text(
                                      c.name.split(' ')[0],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Prominent Animated PLAY NOW Button
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (_pulseController.value * 0.06);
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD166).withOpacity(0.55),
                              blurRadius: 25,
                              spreadRadius: 3,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _onPlayNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD166),
                            foregroundColor: const Color(0xFF040D1A),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 48 : 64,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                              side: const BorderSide(color: Colors.white, width: 2),
                            ),
                            elevation: 8,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow_rounded, size: 28, color: Color(0xFF040D1A)),
                              SizedBox(width: 10),
                              Text(
                                'PLAY NOW',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.5,
                                  color: Color(0xFF040D1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mobile web friendly disclaimer
                    const Text(
                      'Free Mobile & Web Game for Nursing Students\nPlay Directly in Google Chrome • No Download Required',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
