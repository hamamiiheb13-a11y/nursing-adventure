import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'arcade_game_controller.dart';
import '../widgets/virtual_joystick.dart';
import '../widgets/tactile_button.dart';
import '../utils/fullscreen_util.dart';

class ArcadeHudOverlay extends StatefulWidget {
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
  State<ArcadeHudOverlay> createState() => _ArcadeHudOverlayState();
}

class _ArcadeHudOverlayState extends State<ArcadeHudOverlay> {
  ArcadeGameController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 850 || widget.isMobileTouch;
    final int progressPercent = (controller.progressFraction * 100).clamp(0, 100).toInt();

    return Stack(
      children: [
        // ====================================================================
        // 1. TOP LEFT: 3 HEARTS (Red hearts, grey when lost)
        // ====================================================================
        Positioned(
          top: 12,
          left: 14,
          child: _buildHearts(),
        ),

        // ====================================================================
        // 2. TOP LEFT SUB-BAR: Active Weapon Badge (docked below hearts)
        // ====================================================================
        Positioned(
          top: 48,
          left: 14,
          child: _buildWeaponBadge(),
        ),

        // ====================================================================
        // 3. TOP CENTER: Stage name + Progress bar (% completed)
        // ====================================================================
        Positioned(
          top: 12,
          left: 150,
          right: 200,
          child: Center(
            child: _buildStageProgress(progressPercent),
          ),
        ),

        // ====================================================================
        // 4. TOP RIGHT: Score + XP counter
        // ====================================================================
        Positioned(
          top: 12,
          right: 96,
          child: _buildScoreAndXp(),
        ),

        // ====================================================================
        // 5. TOP RIGHT ACTIONS: Fullscreen + Pause Button
        // ====================================================================
        Positioned(
          top: 12,
          right: 14,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFullscreenButton(),
              const SizedBox(width: 8),
              _buildPauseButton(),
            ],
          ),
        ),

        // ====================================================================
        // 6. KEYBOARD CONTROLS HINT (PC only, bottom center)
        // ====================================================================
        if (!isMobile)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: _buildKeyboardHint(),
            ),
          ),

        // ====================================================================
        // 7. BOTTOM CONTROLS (Mobile Touch: Analog Joystick Left + Skills/Fire Right)
        // ====================================================================
        if (isMobile)
          Positioned(
            bottom: 6,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left Virtual Analog Joystick (Analog vector 360°)
                VirtualAnalogJoystick(
                  radius: 56,
                  knobRadius: 26,
                  onMove: (vector) => controller.setMoveVector(vector),
                ),

                // Right Action Buttons (EMP Skill + Shield + Continuous Fire)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // EMP Shockwave Special Skill Button
                    _buildEmpSkillButton(),
                    const SizedBox(width: 10),

                    // Energy Shield Button
                    _buildShieldButton(),
                    const SizedBox(width: 12),

                    // Continuous Fire Button (Hold-to-shoot & Tap)
                    _buildFireButton(),
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

  // --- FULLSCREEN TOGGLE BUTTON ---
  Widget _buildFullscreenButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        FullscreenUtil.toggle();
        setState(() {});
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E1A).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 8),
          ],
        ),
        child: Icon(
          FullscreenUtil.isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
          color: const Color(0xFF38BDF8),
          size: 20,
        ),
      ),
    );
  }

  // --- EMP SPECIAL SKILL BUTTON ---
  Widget _buildEmpSkillButton() {
    final cd = controller.player.specialSkillCooldown;
    final maxCd = controller.player.specialSkillMaxCooldown;
    final isReady = cd <= 0;
    final progress = isReady ? 1.0 : (1.0 - (cd / maxCd)).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: isReady ? controller.triggerSpecialSkill : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isReady
                  ? const Color(0xFF3B0764).withValues(alpha: 0.9)
                  : const Color(0xFF1E1B4B).withValues(alpha: 0.75),
              border: Border.all(
                color: isReady ? const Color(0xFFA855F7) : const Color(0xFF4C1D95),
                width: 2.0,
              ),
              boxShadow: isReady
                  ? [
                      BoxShadow(
                        color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.electric_bolt_rounded,
                  color: isReady ? const Color(0xFFE9D5FF) : const Color(0xFF6B7280),
                  size: 22,
                ),
                Text(
                  isReady ? 'EMP' : '${cd.toStringAsFixed(0)}s',
                  style: GoogleFonts.inter(
                    color: isReady ? const Color(0xFFE9D5FF) : const Color(0xFF9CA3AF),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (!isReady)
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.5,
                color: const Color(0xFFA855F7),
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  // --- SHIELD BUTTON ---
  Widget _buildShieldButton() {
    final isActive = controller.player.isShieldActive;
    return GestureDetector(
      onTap: controller.activateShield,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? const Color(0xFF00E5FF).withValues(alpha: 0.85)
              : const Color(0xFF0B192C).withValues(alpha: 0.85),
          border: Border.all(
            color: const Color(0xFF00E5FF),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: isActive ? 0.75 : 0.35),
              blurRadius: isActive ? 16 : 10,
              spreadRadius: isActive ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_rounded,
              color: isActive ? const Color(0xFF0F172A) : Colors.white,
              size: 22,
            ),
            Text(
              'BOUCLIER',
              style: TextStyle(
                color: isActive ? const Color(0xFF0F172A) : const Color(0xFF00E5FF),
                fontSize: 6.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FIRE BUTTON (HOLD-TO-SHOOT & TAP) ---
  Widget _buildFireButton() {
    return Listener(
      onPointerDown: (_) {
        controller.setShooting(true);
        controller.shoot();
      },
      onPointerUp: (_) => controller.setShooting(false),
      onPointerCancel: (_) => controller.setShooting(false),
      child: Container(
        width: 68,
        height: 68,
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
              color: const Color(0xFFFF2A6D).withValues(alpha: 0.7),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on_rounded, color: Colors.white, size: 28),
            Text(
              'FEU',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
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
      onTap: widget.onPause,
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
        '⌨️ [WASD / Flèches] Navigation  •  [ESPACE / Clic] Tir  •  [Q / F] Onde EMP  •  [E] Bouclier  •  [F11] Plein écran  •  [ÉCHAP] Pause',
        style: GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 10.5,
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
                onPressed: widget.onResume,
              ),
              const SizedBox(height: 12),
              TactileButton(
                label: 'Quitter vers la carte',
                icon: Icons.map_rounded,
                style: TactileButtonStyle.secondary,
                height: 46,
                onPressed: widget.onExitToMap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
