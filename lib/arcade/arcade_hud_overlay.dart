import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'arcade_game_controller.dart';
import '../widgets/virtual_joystick.dart';
import '../widgets/tactile_button.dart';

class ArcadeHudOverlay extends StatelessWidget {
  final ArcadeGameController controller;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onExitToMap;
  final bool isMobileTouch;

  const ArcadeHudOverlay({
    super.key,
    required this.controller,
    required this.onPause,
    required this.onResume,
    required this.onExitToMap,
    this.isMobileTouch = true,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 800 || isMobileTouch;
    final int progressPercent = (controller.progressFraction * 100).clamp(0, 100).toInt();

    return Stack(
      children: [
        // ====================================================================
        // 1. TOP LEFT: 3 HEARTS (Red hearts, grey when lost)
        // ====================================================================
        Positioned(
          top: 14,
          left: 16,
          child: _buildHearts(),
        ),

        // ====================================================================
        // 2. TOP CENTER: Stage name + Progress bar (% completed)
        // ====================================================================
        Positioned(
          top: 14,
          left: 150,
          right: 240,
          child: Center(
            child: _buildStageProgress(progressPercent),
          ),
        ),

        // ====================================================================
        // 3. TOP RIGHT: Score + XP counter
        // ====================================================================
        Positioned(
          top: 14,
          right: 68,
          child: _buildScoreAndXp(),
        ),

        // ====================================================================
        // 4. TOP RIGHT CORNER: Pause button (||)
        // ====================================================================
        Positioned(
          top: 14,
          right: 16,
          child: _buildPauseButton(),
        ),

        // ====================================================================
        // 5. BOTTOM LEFT: Weapon icon + Ammo / Power indicator
        // ====================================================================
        Positioned(
          bottom: isMobile ? 150 : 16,
          left: 16,
          child: _buildWeaponBadge(),
        ),

        // ====================================================================
        // 6. KEYBOARD CONTROLS HINT (PC only, bottom center)
        // ====================================================================
        if (!isMobile)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: _buildKeyboardHint(),
            ),
          ),

        // ====================================================================
        // 7. BOTTOM CONTROLS (Touch / Mobile: Joystick Left + Shoot/Shield Right)
        // ====================================================================
        if (isMobile)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left Virtual Joystick
                VirtualAnalogJoystick(
                  radius: 65,
                  knobRadius: 30,
                  onDirectionChanged: (up, down, left, right) {
                    controller.setThrust(up);
                    controller.setMoveDown(down);
                    controller.setMoveLeft(left);
                    controller.setMoveRight(right);
                  },
                ),

                // Right Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Shield Button
                    GestureDetector(
                      onTap: controller.activateShield,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.player.isShieldActive
                              ? const Color(0xFF00E5FF).withValues(alpha: 0.8)
                              : const Color(0xFF0B192C).withValues(alpha: 0.85),
                          border: Border.all(
                            color: const Color(0xFF00E5FF),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 26),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Fire Button (Red Neon)
                    GestureDetector(
                      onTapDown: (_) => controller.shoot(),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFFFF2A6D), Color(0xFF880E4F)],
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF2A6D).withValues(alpha: 0.65),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flash_on_rounded, color: Colors.white, size: 30),
                            Text(
                              'FEU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // ====================================================================
        // 8. PAUSE MODAL OVERLAY
        // ====================================================================
        if (controller.state == GameState.paused)
          _buildPauseModal(context),
      ],
    );
  }

  // --- 1. HEARTS WIDGET ---
  Widget _buildHearts() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(controller.player.maxHearts, (index) {
          final isFull = index < controller.player.hearts;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              isFull ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFull ? const Color(0xFFEF4444) : const Color(0xFF475569),
              size: 22,
            ),
          );
        }),
      ),
    );
  }

  // --- 2. STAGE PROGRESS WIDGET ---
  Widget _buildStageProgress(int percent) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STAGE ${controller.level} : ${controller.world.title.toUpperCase()}',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF00E5FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                '$percent%',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFFD166),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: const Color(0xFF1E293B),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: controller.progressFraction.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFF38BDF8), Color(0xFFFFD166)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. SCORE & XP WIDGET ---
  Widget _buildScoreAndXp() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SCORE',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
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
          const SizedBox(width: 12),

          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD166).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFFFFD166), size: 14),
                const SizedBox(width: 2),
                Text(
                  '+${controller.earnedXp} XP',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFFD166),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. PAUSE BUTTON (||) ---
  Widget _buildPauseButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPause,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E1A).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 10),
          ],
        ),
        child: const Icon(Icons.pause_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  // --- 5. WEAPON & AMMO BADGE ---
  Widget _buildWeaponBadge() {
    final weapon = controller.equippedWeaponConfig;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: weapon.glowColor.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(weapon.icon, color: weapon.glowColor, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ARME ACTIVE',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              Row(
                children: [
                  Text(
                    weapon.name,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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
                      child: const Text(
                        '2X',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Infinity Ammo symbol
          const Icon(Icons.all_inclusive_rounded, color: Color(0xFF38BDF8), size: 16),
        ],
      ),
    );
  }

  // --- 6. KEYBOARD CONTROLS HINT ---
  Widget _buildKeyboardHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        '⌨️ [WASD / Flèches] Navigation  •  [ESPACE / Clic Gauche] Tirer  •  [E] Bouclier  •  [ÉCHAP] Pause',
        style: GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // --- 8. PAUSE MODAL ---
  Widget _buildPauseModal(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF00E5FF), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                blurRadius: 30,
              ),
              const BoxShadow(color: Colors.black87, blurRadius: 24),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, color: Color(0xFF00E5FF), size: 54),
              const SizedBox(height: 10),
              Text(
                'PARTIE EN PAUSE',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Stage ${controller.level} • Score : ${controller.score}',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 22),
              TactileButton(
                label: 'Reprendre la partie',
                icon: Icons.play_arrow_rounded,
                style: TactileButtonStyle.primary,
                height: 48,
                onPressed: onResume,
              ),
              const SizedBox(height: 12),
              TactileButton(
                label: 'Quitter vers la carte',
                icon: Icons.map_rounded,
                style: TactileButtonStyle.secondary,
                height: 46,
                onPressed: onExitToMap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
