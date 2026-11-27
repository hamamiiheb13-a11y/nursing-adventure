import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/capsule_theme.dart';
import '../utils/fullscreen_util.dart';
import '../widgets/tactile_button.dart';
import '../widgets/virtual_joystick.dart';
import 'arcade_game_controller.dart';

class ArcadeHudOverlay extends StatefulWidget {
  final ArcadeGameController controller;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onExitToMap;
  final VoidCallback? onTutorialComplete;
  final bool isMobileTouch;

  const ArcadeHudOverlay({
    super.key,
    required this.controller,
    required this.onPause,
    required this.onResume,
    required this.onExitToMap,
    this.onTutorialComplete,
    this.isMobileTouch = true,
  });

  @override
  State<ArcadeHudOverlay> createState() => _ArcadeHudOverlayState();
}

class _ArcadeHudOverlayState extends State<ArcadeHudOverlay> {
  bool _firePressed = false;
  bool _shieldPressed = false;
  bool _specialPressed = false;
  int _tutorialStep = 0;

  ArcadeGameController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(covariant ArcadeHudOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerTick);
      widget.controller.addListener(_onControllerTick);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerTick);
    super.dispose();
  }

  void _completeTutorial() {
    if (controller.progress.hasSeenTutorial && _tutorialStep >= 3) return;
    controller.progress.hasSeenTutorial = true;
    widget.onTutorialComplete?.call();
    if (mounted) {
      setState(() => _tutorialStep = 3);
    }
  }

  void _onControllerTick() {
    if (!mounted ||
        controller.progress.hasSeenTutorial ||
        _tutorialStep >= 3 ||
        controller.state != GameState.playing) {
      return;
    }
    if (_tutorialStep == 0 && controller.player.moveInput.distance > 0.15) {
      setState(() => _tutorialStep = 1);
    } else if (_tutorialStep == 1 &&
        (controller.player.isShooting || controller.playerProjectiles.isNotEmpty)) {
      setState(() => _tutorialStep = 2);
    } else if (_tutorialStep == 2 &&
        (controller.player.isShieldActive || controller.player.specialSkillCooldown > 0)) {
      _completeTutorial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 920 || widget.isMobileTouch;
    final isTightHeight = media.size.height < 420;
    final int progressPercent = (controller.progressFraction * 100).clamp(0, 100).toInt();
    final bool isBossActive = controller.state == GameState.bossIntro ||
        controller.state == GameState.bossFight ||
        controller.state == GameState.bossDefeatAnim;

    return SafeArea(
      child: Stack(
        children: [
          // ====================================================================
          // TOP BAR: HEARTS + STAGE / BOSS BAR + SCORE/XP + ACTIONS
          // ====================================================================
          Positioned(
            top: isTightHeight ? 6 : 10,
            left: 12,
            right: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP LEFT: Hearts + Active Weapon & Knowledge Multiplier
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHearts(isTightHeight),
                    const SizedBox(height: 5),
                    _buildWeaponBadge(isTightHeight),
                  ],
                ),
                const SizedBox(width: 10),

                // 2. TOP CENTER: Mission Progress OR Live Boss Health Bar
                Expanded(
                  child: Center(
                    child: isBossActive
                        ? _buildBossHpHeader(isTightHeight)
                        : _buildStageProgress(progressPercent, isTightHeight),
                  ),
                ),
                const SizedBox(width: 10),

                // 3. TOP RIGHT: Score + XP + Fullscreen + Pause
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildScoreAndXp(isTightHeight),
                    const SizedBox(width: 6),
                    _buildIconCircleButton(
                      icon: FullscreenUtil.isFullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      iconColor: CapsuleColors.cyanGlow,
                      onTap: () {
                        FullscreenUtil.toggle();
                        setState(() {});
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildIconCircleButton(
                      icon: Icons.pause_rounded,
                      iconColor: Colors.white,
                      onTap: widget.onPause,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ====================================================================
          // DESKTOP KEYBOARD / MOUSE HINT (Bottom Center, unobtrusive)
          // ====================================================================
          if (!isMobile)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: _buildKeyboardHint(),
              ),
            ),

          // ====================================================================
          // TOUCH CONTROLS (Mobile / Tablet: Analog Joystick + Special / Shield / Fire)
          // ====================================================================
          if (isMobile)
            Positioned(
              bottom: isTightHeight ? 4 : 10,
              left: 8,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Ergonomic 360° Responsive Analog Joystick
                  VirtualAnalogJoystick(
                    radius: isTightHeight ? 46 : 54,
                    knobRadius: isTightHeight ? 21 : 25,
                    onMove: (vector) => controller.setMoveVector(vector),
                  ),

                  // Action Cluster: Special (Anti-Inflammatory) + Defense Shield + Fire
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildSpecialSkillButton(isTightHeight),
                      const SizedBox(width: 10),
                      _buildShieldButton(isTightHeight),
                      const SizedBox(width: 12),
                      _buildFireButton(isTightHeight),
                    ],
                  ),
                ],
              ),
            ),

          // ====================================================================
          // INTERACTIVE ONBOARDING TUTORIAL (First run until practiced/skipped)
          // ====================================================================
          if (!controller.progress.hasSeenTutorial &&
              _tutorialStep < 3 &&
              controller.state == GameState.playing)
            Positioned(
              top: isTightHeight ? 58 : 72,
              left: 16,
              right: 16,
              child: Center(
                child: _buildTutorialBanner(isMobile, isTightHeight),
              ),
            ),

          // ====================================================================
          // BOSS INTRO WARNING BANNER
          // ====================================================================
          if (controller.state == GameState.bossIntro)
            _buildBossIntroBanner(),

          // ====================================================================
          // PAUSE MODAL (Fallback when HUD renders directly)
          // ====================================================================
          if (controller.state == GameState.paused)
            _buildPauseModal(context),
        ],
      ),
    );
  }

  Widget _buildHearts(bool isTight) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTight ? 8 : 11, vertical: isTight ? 4 : 6),
      decoration: BoxDecoration(
        color: CapsuleColors.deepOcean.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CapsuleColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(controller.player.maxHearts, (index) {
          final isFull = index < controller.player.hearts;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFull ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFull ? CapsuleColors.coral : CapsuleColors.textMuted.withValues(alpha: 0.45),
              size: isTight ? 18 : 21,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWeaponBadge(bool isTight) {
    final weapon = controller.equippedWeaponConfig;
    final dmgMult = controller.player.knowledgeDamageMultiplier;
    final hasPowerBonus = dmgMult > 1.05;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTight ? 8 : 10, vertical: isTight ? 4 : 5),
      decoration: BoxDecoration(
        color: CapsuleColors.deepOcean.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.player.isMaxSynergy
              ? CapsuleColors.gold
              : weapon.glowColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            weapon.icon,
            color: controller.player.isMaxSynergy ? CapsuleColors.gold : weapon.glowColor,
            size: isTight ? 14 : 16,
          ),
          const SizedBox(width: 6),
          Text(
            weapon.shortName,
            style: GoogleFonts.plusJakartaSans(
              color: CapsuleColors.textWhite,
              fontSize: isTight ? 10.5 : 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (hasPowerBonus) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: controller.player.isMaxSynergy
                    ? CapsuleColors.gold
                    : CapsuleColors.mintGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'x${dmgMult.toStringAsFixed(1)}',
                style: GoogleFonts.orbitron(
                  color: CapsuleColors.deepOcean,
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

  Widget _buildStageProgress(int percent, bool isTight) {
    final totalQuestions = controller.checkpoints.length;
    final answeredQuestions = controller.checkpoints.where((c) => c.isCompleted).length;
    final nextCp = controller.checkpoints.where((c) => !c.isCompleted).firstOrNull;
    final bool isQuestionNear = nextCp != null &&
        (nextCp.worldX - controller.player.position.dx) > 0 &&
        (nextCp.worldX - controller.player.position.dx) < 280.0;

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: isTight ? 5 : 7),
      decoration: BoxDecoration(
        color: CapsuleColors.deepOcean.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isQuestionNear ? CapsuleColors.cyanGlow : CapsuleColors.cardBorder,
          width: isQuestionNear ? 1.6 : 1.0,
        ),
        boxShadow: isQuestionNear
            ? [
                BoxShadow(
                  color: CapsuleColors.cyanGlow.withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  controller.world.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: CapsuleColors.cyanGlow,
                    fontSize: isTight ? 10 : 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (totalQuestions > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isQuestionNear
                        ? CapsuleColors.cyanGlow
                        : CapsuleColors.oceanSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CapsuleColors.cyanGlow.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.quiz_rounded,
                        size: isTight ? 11 : 12,
                        color: isQuestionNear
                            ? CapsuleColors.deepOcean
                            : CapsuleColors.cyanGlow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isQuestionNear
                            ? 'QUESTION !'
                            : 'Q $answeredQuestions/$totalQuestions',
                        style: GoogleFonts.plusJakartaSans(
                          color: isQuestionNear
                              ? CapsuleColors.deepOcean
                              : Colors.white,
                          fontSize: isTight ? 9.5 : 10.2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                '$percent%',
                style: GoogleFonts.orbitron(
                  color: CapsuleColors.gold,
                  fontSize: isTight ? 10 : 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: controller.progressFraction.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: CapsuleColors.oceanSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(CapsuleColors.mintGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBossHpHeader(bool isTight) {
    final boss = controller.boss;
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: isTight ? 5 : 7),
      decoration: BoxDecoration(
        color: CapsuleColors.deepOcean.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: boss.isPhase2 ? CapsuleColors.coral : CapsuleColors.dangerOrange,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${boss.name.toUpperCase()} • ${boss.isPhase2 ? "PHASE 2" : "DANGER ${boss.dangerLevel}"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: boss.isPhase2 ? CapsuleColors.coral : CapsuleColors.gold,
                    fontSize: isTight ? 10 : 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${boss.currentHp}/${boss.maxHp}',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: isTight ? 10 : 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: boss.healthRatio,
              minHeight: 7,
              backgroundColor: CapsuleColors.oceanSurface,
              valueColor: AlwaysStoppedAnimation<Color>(
                boss.isPhase2 ? CapsuleColors.coral : CapsuleColors.dangerOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreAndXp(bool isTight) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTight ? 9 : 11, vertical: isTight ? 4 : 6),
      decoration: BoxDecoration(
        color: CapsuleColors.deepOcean.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CapsuleColors.cardBorder),
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
                  color: CapsuleColors.textSubtle,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${controller.score}',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: isTight ? 11.5 : 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: CapsuleColors.gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CapsuleColors.gold.withValues(alpha: 0.5)),
            ),
            child: Text(
              '+${controller.earnedXp} XP',
              style: GoogleFonts.plusJakartaSans(
                color: CapsuleColors.gold,
                fontSize: isTight ? 10 : 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCircleButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: CapsuleColors.deepOcean.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CapsuleColors.cardBorder),
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
    );
  }

  Widget _buildSpecialSkillButton(bool isTight) {
    final cd = controller.player.specialSkillCooldown;
    final maxCd = math.max(1.0, controller.player.specialSkillMaxCooldown);
    final isReady = cd <= 0;
    final bool isSuper = controller.player.hasSuperAttack;
    final progress = isReady ? 1.0 : (1.0 - (cd / maxCd)).clamp(0.0, 1.0);
    final double size = isTight ? 46 : 52;
    final Color activeColor = isSuper ? CapsuleColors.gold : CapsuleColors.mintGreen;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        if (isReady) {
          setState(() => _specialPressed = true);
          controller.triggerSpecialSkill();
        }
      },
      onPointerUp: (_) => setState(() => _specialPressed = false),
      onPointerCancel: (_) => setState(() => _specialPressed = false),
      child: AnimatedScale(
        scale: _specialPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isReady
                    ? activeColor.withValues(alpha: isSuper ? 0.30 : 0.25)
                    : CapsuleColors.deepOcean.withValues(alpha: 0.80),
                border: Border.all(
                  color: isReady ? activeColor : CapsuleColors.textMuted.withValues(alpha: 0.4),
                  width: isReady && isSuper ? 2.4 : 2.0,
                ),
                boxShadow: isReady && isSuper
                    ? [
                        BoxShadow(
                          color: CapsuleColors.gold.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSuper ? Icons.auto_awesome_rounded : Icons.waves_rounded,
                      color: isReady ? activeColor : CapsuleColors.textMuted,
                      size: isTight ? 18 : 21,
                    ),
                    SizedBox(
                      width: size - 8,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isReady ? (isSuper ? 'FRAPPE MAX' : 'SPÉCIAL') : '${cd.ceil()}s',
                          style: GoogleFonts.plusJakartaSans(
                            color: isReady
                                ? (isSuper ? CapsuleColors.gold : Colors.white)
                                : CapsuleColors.textMuted,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isReady)
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.5,
                  color: activeColor,
                  backgroundColor: Colors.transparent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShieldButton(bool isTight) {
    final isActive = controller.player.isShieldActive;
    final double size = isTight ? 46 : 52;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        setState(() => _shieldPressed = true);
        controller.activateShield();
      },
      onPointerUp: (_) => setState(() => _shieldPressed = false),
      onPointerCancel: (_) => setState(() => _shieldPressed = false),
      child: AnimatedScale(
        scale: _shieldPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? CapsuleColors.cyanGlow
                : CapsuleColors.deepOcean.withValues(alpha: 0.82),
            border: Border.all(
              color: CapsuleColors.cyanGlow,
              width: 2.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_rounded,
                color: isActive ? CapsuleColors.deepOcean : Colors.white,
                size: isTight ? 19 : 22,
              ),
              Text(
                isActive ? '${controller.player.shieldTimer.ceil()}s' : 'DÉFENSE',
                style: GoogleFonts.plusJakartaSans(
                  color: isActive ? CapsuleColors.deepOcean : CapsuleColors.cyanGlow,
                  fontSize: 7.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFireButton(bool isTight) {
    final double size = isTight ? 62 : 70;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        setState(() => _firePressed = true);
        controller.setShooting(true);
        controller.shoot();
      },
      onPointerUp: (_) {
        setState(() => _firePressed = false);
        controller.setShooting(false);
      },
      onPointerCancel: (_) {
        setState(() => _firePressed = false);
        controller.setShooting(false);
      },
      child: AnimatedScale(
        scale: _firePressed ? 0.91 : 1.0,
        duration: const Duration(milliseconds: 70),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFFB7185), Color(0xFFF97316)],
            ),
            border: Border.all(
              color: Colors.white,
              width: 2.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFB7185).withValues(alpha: _firePressed ? 0.8 : 0.45),
                blurRadius: _firePressed ? 16 : 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flash_on_rounded, color: Colors.white, size: isTight ? 25 : 29),
              const Text(
                'TIRER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBossIntroBanner() {
    final boss = controller.boss;
    return IgnorePointer(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: CapsuleColors.deepOcean.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CapsuleColors.dangerOrange, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 18)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ALERTE PATHOGÈNE • DANGER : ${boss.dangerLevel}',
                style: GoogleFonts.plusJakartaSans(
                  color: CapsuleColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                boss.name.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Votre puissance : x${controller.player.knowledgeDamageMultiplier.toStringAsFixed(1)}',
                style: GoogleFonts.inter(
                  color: CapsuleColors.mintGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialBanner(bool isMobile, bool isTight) {
    final IconData icon;
    final Color accent;
    final String stepTitle;
    final String stepHint;

    if (_tutorialStep == 0) {
      icon = Icons.open_with_rounded;
      accent = CapsuleColors.cyanGlow;
      stepTitle = '1/3 • PILOTAGE';
      stepHint = isMobile
          ? 'Glisse le joystick gauche pour déplacer ta capsule'
          : 'Utilise WASD ou les Flèches pour piloter ta capsule';
    } else if (_tutorialStep == 1) {
      icon = Icons.bolt_rounded;
      accent = CapsuleColors.amberGold;
      stepTitle = '2/3 • TIR MÉDICAL';
      stepHint = isMobile
          ? 'Appuie sur TIRER pour neutraliser les pathogènes'
          : 'Maintiens ESPACE ou Clic pour tirer';
    } else {
      icon = Icons.shield_rounded;
      accent = CapsuleColors.mintGreen;
      stepTitle = '3/3 • BOUCLIER & SPÉCIAL';
      stepHint = isMobile
          ? 'Active DÉFENSE ou SPÉCIAL face aux vagues critiques'
          : 'Appuie sur [E] Bouclier ou [Q / F] Arme Spéciale';
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 470),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: isTight ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: CapsuleColors.deepOcean.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.75), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.22),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: isTight ? 16 : 19),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stepTitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: accent,
                      fontSize: isTight ? 9.5 : 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    stepHint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: CapsuleColors.textWhite,
                      fontSize: isTight ? 10.5 : 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _completeTutorial,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: CapsuleColors.oceanSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CapsuleColors.cardBorder),
                ),
                child: Text(
                  'Passer',
                  style: GoogleFonts.plusJakartaSans(
                    color: CapsuleColors.textSubtle,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: CapsuleColors.deepOcean.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CapsuleColors.cardBorder),
      ),
      child: Text(
        '⌨️ [WASD / Flèches] Piloter  •  [ESPACE / Clic] Tir continu  •  [Q / F] Arme Spéciale  •  [E] Bouclier  •  [ÉCHAP] Pause',
        style: GoogleFonts.inter(
          color: CapsuleColors.textSubtle,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPauseModal(BuildContext context) {
    return Container(
      color: CapsuleColors.deepOcean.withValues(alpha: 0.80),
      child: Center(
        child: Container(
          width: 360,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: CapsuleColors.oceanSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: CapsuleColors.cyanGlow, width: 1.8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, color: CapsuleColors.cyanGlow, size: 48),
              const SizedBox(height: 8),
              Text(
                'PARTIE EN PAUSE',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Stage ${controller.level} • Score : ${controller.score}',
                style: GoogleFonts.inter(color: CapsuleColors.textSubtle, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TactileButton(
                label: 'Reprendre la partie',
                icon: Icons.play_arrow_rounded,
                style: TactileButtonStyle.primary,
                height: 46,
                onPressed: widget.onResume,
              ),
              const SizedBox(height: 10),
              TactileButton(
                label: 'Quitter vers la carte',
                icon: Icons.map_rounded,
                style: TactileButtonStyle.secondary,
                height: 44,
                onPressed: widget.onExitToMap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
