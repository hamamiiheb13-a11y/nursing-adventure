import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'arcade_game_controller.dart';

class ArcadeHudOverlay extends StatelessWidget {
  final ArcadeGameController controller;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onExitToMap;

  const ArcadeHudOverlay({
    super.key,
    required this.controller,
    required this.onPause,
    required this.onResume,
    required this.onExitToMap,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 700;

    return Stack(
      children: [
        // --- 1. TOP ARCADE STATUS BAR ---
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // Three Hearts (Life)
                  _buildHearts(),
                  const SizedBox(width: 14),

                  // Score & Combo
                  _buildScoreAndCombo(),
                  const SizedBox(width: 10),

                  // Equipped Weapon Badge
                  if (!isMobile) _buildWeaponBadge(),
                  const Spacer(),

                  // Progress Mini-track (Capsule -> Boss)
                  if (!isMobile) ...[
                    _buildProgressTrack(),
                    const SizedBox(width: 14),
                  ],

                  // XP Badge
                  _buildXpBadge(),
                  const SizedBox(width: 10),

                  // Pause Button
                  _buildPauseButton(),
                ],
              ),
            ),
          ),
        ),

        // Mobile Mini-Progress Track (if mobile)
        if (isMobile)
          Positioned(
            top: 56,
            left: 14,
            right: 14,
            child: Row(
              children: [
                Expanded(child: _buildProgressTrack()),
                const SizedBox(width: 8),
                _buildWeaponBadge(),
              ],
            ),
          ),

        // --- 2. BOTTOM CONTROLS (TOUCH / MOBILE & KEYBOARD HINTS) ---
        Positioned(
          bottom: 12,
          left: 14,
          right: 14,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Directional Left / Right Touch Buttons
                _buildDirectionalTouchButtons(),

                // Keyboard controls hint (PC)
                if (!isMobile)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Text(
                      '⌨️ [A / D] Naviguer  •  [W / ▲] Monter  •  [ESPACE] Tirer  •  [E] Bouclier  •  [P] Pause',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Action Touch Buttons (Shoot, Thrust, Shield)
                _buildActionTouchButtons(),
              ],
            ),
          ),
        ),

        // --- 3. PAUSE MODAL OVERLAY ---
        if (controller.state == GameState.paused)
          _buildPauseModal(context),
      ],
    );
  }

  Widget _buildHearts() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(controller.player.maxHearts, (index) {
          final isFull = index < controller.player.hearts;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Icon(
              isFull ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFull ? const Color(0xFFEF4444) : const Color(0xFF64748B),
              size: 20,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildScoreAndCombo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SCORE',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                '${controller.score}',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (controller.combo > 1) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'x${controller.combo}',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressTrack() {
    final progress = controller.progressFraction;

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.world.title} • N${controller.level}',
                style: GoogleFonts.inter(
                  color: controller.world.primaryColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.coronavirus_rounded, color: Color(0xFFEF4444), size: 12),
                  const SizedBox(width: 3),
                  Text(
                    'BOSS',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFEF4444),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [controller.world.primaryColor, const Color(0xFF00E5FF)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXpBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFFFD166), size: 16),
          const SizedBox(width: 4),
          Text(
            '+${controller.earnedXp}',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFFD166),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPause,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Icon(Icons.pause_rounded, color: Colors.white70, size: 20),
      ),
    );
  }

  // --- TOUCH CONTROLS ---
  Widget _buildDirectionalTouchButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => controller.setMoveLeft(true),
          onTapUp: (_) => controller.setMoveLeft(false),
          onTapCancel: () => controller.setMoveLeft(false),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF00E5FF), size: 28),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTapDown: (_) => controller.setMoveRight(true),
          onTapUp: (_) => controller.setMoveRight(false),
          onTapCancel: () => controller.setMoveRight(false),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF00E5FF), size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildWeaponBadge() {
    final weapon = controller.equippedWeaponConfig;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: weapon.glowColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(weapon.icon, color: weapon.glowColor, size: 16),
          const SizedBox(width: 5),
          Text(
            weapon.name,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (controller.player.hasDoubleShot) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '2X',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionTouchButtons() {
    final weapon = controller.equippedWeaponConfig;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Shield Button
        GestureDetector(
          onTap: controller.activateShield,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: controller.player.isShieldActive
                  ? const Color(0xFF818CF8)
                  : const Color(0xFF1E1B4B).withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA5B4FC), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF818CF8).withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 10),

        // Shoot Button
        GestureDetector(
          onTapDown: (_) => controller.shoot(),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF0369A1).withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: weapon.glowColor, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: weapon.glowColor.withValues(alpha: 0.45),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Icon(Icons.my_location_rounded, color: weapon.glowColor, size: 28),
          ),
        ),
        const SizedBox(width: 10),

        // Thrust Button
        GestureDetector(
          onTapDown: (_) => controller.setThrust(true),
          onTapUp: (_) => controller.setThrust(false),
          onTapCancel: () => controller.setThrust(false),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2DD4BF), width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.4),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  // --- PAUSE MODAL ---
  Widget _buildPauseModal(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 380,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00E5FF), width: 1.8),
            boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 24)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, color: Color(0xFF00E5FF), size: 54),
              const SizedBox(height: 12),
              Text(
                'EXPLORATION EN PAUSE',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Capsule en vol stationnaire au sein de la muqueuse digestive.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  'Reprendre l\'exploration',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
                onPressed: onResume,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Color(0xFF334155)),
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.map_rounded),
                label: Text(
                  'Retour à la Carte des Mondes',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                onPressed: onExitToMap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
