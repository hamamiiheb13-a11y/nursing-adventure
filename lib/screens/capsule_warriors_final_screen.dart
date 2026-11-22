import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../models/gastro_question.dart';
import '../widgets/tactile_button.dart';
import 'capsule_warriors_review_screen.dart';

class CapsuleWarriorsFinalScreen extends StatelessWidget {
  final GameProgress progress;

  const CapsuleWarriorsFinalScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 750;
    final masteredCount = progress.masteredQuestions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          'DIPLÔME PFE & CERTIFICATION CLINIQUE',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 14 : 17,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 32,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              children: [
                // Formal Diploma Certificate Card
                Container(
                  padding: EdgeInsets.all(isMobile ? 20 : 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1329),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFFFD166), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.25),
                        blurRadius: 36,
                      ),
                      const BoxShadow(color: Colors.black54, blurRadius: 24),
                    ],
                  ),
                  child: Column(
                    children: [
                      // University / Institute Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school_rounded, color: Color(0xFFFFD166), size: 28),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'INSTITUT SUPÉRIEUR DES SCIENCES INFIRMIÈRES DE TUNIS',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFFFD166),
                                fontSize: isMobile ? 11 : 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF334155), thickness: 1.2),
                      const SizedBox(height: 16),

                      Text(
                        'CERTIFICAT D\'EXCELLENCE CLINIQUE',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: isMobile ? 20 : 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Prise en Charge Infirmière des Maladies Inflammatoires Chroniques de l\'Intestin (MICI)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
                          fontSize: isMobile ? 12 : 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Ce diplôme certifie que le candidat a accompli avec brio l\'exploration complète des 7 secteurs du tractus digestif au sein de CAPSULE WARRIORS – THE STOMACH MISSION, en répondant avec rigueur aux 33 questions cliniques validées du Projet de Fin d\'Études.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFCBD5E1),
                          fontSize: isMobile ? 12 : 13.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Golden Seal & Stats
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF030712).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCertStat('SCORE TOTAL', '${progress.totalScore} PTS'),
                            _buildCertStat('EXPÉRIENCE', '${progress.totalXp} XP'),
                            _buildCertStat('QUESTIONS', '$masteredCount / ${allGastroQuestions.length}'),
                            _buildCertStat('MONDES', '7 / 7 VALIDÉS'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Signatures & Official Stamp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Présidence du Jury ISSIT',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pr. Gastro-Entérologie & Soins',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFD166), width: 2),
                            ),
                            child: const Icon(Icons.verified_rounded, color: Color(0xFFFFD166), size: 38),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Date de Validation',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Session Officielle 2026',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TactileButton(
                        label: 'Consulter les 33 Questions',
                        icon: Icons.menu_book_rounded,
                        style: TactileButtonStyle.secondary,
                        height: 52,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CapsuleWarriorsReviewScreen(progress: progress),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TactileButton(
                        label: 'Retour à l\'Accueil',
                        icon: Icons.home_rounded,
                        style: TactileButtonStyle.primary,
                        height: 52,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFFFD166),
            fontSize: 14.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
