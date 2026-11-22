import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HospitalPagerWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const HospitalPagerWidget({
    super.key,
    this.onTap,
  });

  @override
  State<HospitalPagerWidget> createState() => _HospitalPagerWidgetState();
}

class _HospitalPagerWidgetState extends State<HospitalPagerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark rugged slate casing
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE11D48).withValues(alpha: 0.3 + 0.4 * _glowAnimation.value),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withValues(alpha: 0.15 * _glowAnimation.value),
                blurRadius: 18,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              const BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pager top bar: Clip detail + blinking urgency LED
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MED-PAGER V4 • RX-700',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),

                  // Blinking Red LED
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48).withValues(alpha: _glowAnimation.value),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ALERTE',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFFDA4AF),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Backlit LCD Screen
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF042F2E), // Deep medical LCD teal
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LCD Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📟 TRANSMISSION ENTRANTE',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2DD4BF),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'CANAL 01 • URGENT',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF99F6E4),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Service alert line
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF134E4A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'APPEL URGENT — UNITÉ D\'ENDOSCOPIE',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF5EEAD4),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Patient message body
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Patient : ',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFCCFBF1)),
                          ),
                          TextSpan(
                            text: 'Sami, 24 ans\n',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Douleurs abdominales aiguës, suspicion de MICI. Examen endoscopique requis immédiatement.',
                            style: TextStyle(color: Color(0xFFE2E8F0)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
