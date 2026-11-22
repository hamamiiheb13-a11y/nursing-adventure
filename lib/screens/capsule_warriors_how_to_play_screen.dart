import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../arcade/weapon_system.dart';

class CapsuleWarriorsHowToPlayScreen extends StatelessWidget {
  const CapsuleWarriorsHowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 750;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          'GUIDE DU PILOTE • COMMENT JOUER',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: isMobile ? 15 : 18,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 32,
          vertical: 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Controls Section
                _buildSectionTitle('1. COMMANDES DU VÉHICULE MÉDICAL'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        title: 'Commandes Ordinateur (PC)',
                        icon: Icons.computer_rounded,
                        color: const Color(0xFF00E5FF),
                        items: const [
                          'Flèches ou [A / D] : Naviguer horizontalement',
                          'Flèche Haut ou [W] : Monter (Propulsion)',
                          'Flèche Bas ou [S] : Descendre',
                          '[ESPACE] : Tirer avec l\'arme équipée',
                          '[E] ou [Shift] : Activer le bouclier énergétique',
                          '[P] ou [Échap] : Mettre en pause',
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildInfoCard(
                        title: 'Commandes Tactiles (Mobile)',
                        icon: Icons.smartphone_rounded,
                        color: const Color(0xFF38BDF8),
                        items: const [
                          'Flèches tactiles gauches : Avancer / Reculer',
                          'Bouton Fusée (vert) : Propulseur vertical',
                          'Bouton Cible (cyan) : Tir laser',
                          'Bouton Bouclier (indigo) : Défense biomagnétique',
                          'Bouton Pause en haut à droite',
                          'Commandes optimisées 60 FPS réactives',
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 2. Arsenal Section
                _buildSectionTitle('2. ARSENAL DES 6 ARMES ÉVOLUTIVES'),
                const SizedBox(height: 12),
                ...WeaponConfig.allWeapons.map((weapon) => _buildWeaponCard(weapon)),
                const SizedBox(height: 28),

                // 3. Bestiary Section
                _buildSectionTitle('3. BESTIAIRE DES 5 PATHOGÈNES GASTRIQUES'),
                const SizedBox(height: 12),
                _buildBestiary(),
                const SizedBox(height: 28),

                // 4. Pedagogical Rules Section
                _buildSectionTitle('4. SYSTÈME DE RÉPÉTITION ESPACÉE INTELLIGENTE'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology_rounded, color: Color(0xFF10B981), size: 28),
                          const SizedBox(width: 10),
                          Text(
                            'Apprentissage Actif & Consolidation Mémorielle',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• Chaque bonne réponse aux nanoportes de contrôle rapporte +100 XP, un boost de propulsion et recharge vos armes.\n'
                        '• Une mauvaise réponse retire 1 cœur, affiche la justification clinique complète issue du mémoire de l\'ISSIT Tunis, et place la question dans votre File de Révision.\n'
                        '• Les questions erronées réapparaissent intelligemment plus tard dans les mondes suivants jusqu\'à être parfaitement maîtrisées !\n'
                        '• À la fin de chaque secteur, le Boss vous défie sur un ensemble de questions cliniques du monde pour valider votre avancement.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFCBD5E1),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF00E5FF),
        fontSize: 13.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeaponCard(WeaponConfig weapon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: weapon.glowColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: weapon.glowColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: weapon.glowColor.withValues(alpha: 0.5)),
            ),
            child: Icon(weapon.icon, color: weapon.glowColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      weapon.name,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Dégâts: ${weapon.damage}  •  Cadence: ${(1.0 / weapon.cooldownSeconds).toStringAsFixed(1)}/s',
                      style: GoogleFonts.inter(
                        color: weapon.glowColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  weapon.description,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestiary() {
    final enemies = [
      {
        'name': 'Helico-Grub',
        'sub': 'Bactérie gastrique spiralée (Helicobacter pylori)',
        'desc': 'Ondule dans le flux gastrique et libère des toxines qui affaiblissent la barrière muqueuse.',
        'hp': '2 - 4 HP',
        'color': Color(0xFF10B981),
      },
      {
        'name': 'Spike-Virion',
        'sub': 'Pathogène viral à pointes rotatives',
        'desc': 'Capside hautement instable tourbillonnant à grande vitesse pour percer les défenses de la capsule.',
        'hp': '2 - 3 HP',
        'color': Color(0xFFEC4899),
      },
      {
        'name': 'Cytokine-Blob',
        'sub': 'Médiateur de l\'inflammation muqueuse',
        'desc': 'Sécrète et crache des globules acides corrosifs ciblant directement la trajectoire de vol.',
        'hp': '3 - 5 HP',
        'color': Color(0xFFF59E0B),
      },
      {
        'name': 'Acid Sentry',
        'sub': 'Sentinelle blindée résistante',
        'desc': 'Balaye verticalement les plis de l\'estomac et projette des salves énergétiques doubles.',
        'hp': '4 - 6 HP',
        'color': Color(0xFF38BDF8),
      },
      {
        'name': 'Toxic Spore',
        'sub': 'Mine biologique flottante',
        'desc': 'Flotte au gré des sécrétions digestives et explose violemment au contact.',
        'hp': '2 HP',
        'color': Color(0xFF34D399),
      },
    ];

    return Column(
      children: enemies.map((e) {
        final col = e['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: col.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: col, width: 1.5),
                ),
                child: Icon(Icons.coronavirus_rounded, color: col, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          e['name'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            e['hp'] as String,
                            style: GoogleFonts.inter(
                              color: col,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e['sub'] as String,
                      style: GoogleFonts.inter(
                        color: col,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e['desc'] as String,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
