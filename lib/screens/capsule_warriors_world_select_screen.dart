import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../audio/audio_service.dart';
import '../models/game_progress.dart';
import '../models/gastro_question.dart';
import '../models/gastro_world.dart';
import '../services/storage_service.dart';
import '../theme/capsule_theme.dart';
import '../widgets/capsule_parallax_background.dart';
import 'capsule_warriors_briefing_screen.dart';
import 'capsule_warriors_review_screen.dart';

class CapsuleWarriorsWorldSelectScreen extends StatefulWidget {
  final GameProgress progress;

  const CapsuleWarriorsWorldSelectScreen({
    super.key,
    required this.progress,
  });

  @override
  State<CapsuleWarriorsWorldSelectScreen> createState() =>
      _CapsuleWarriorsWorldSelectScreenState();
}

class _CapsuleWarriorsWorldSelectScreenState
    extends State<CapsuleWarriorsWorldSelectScreen> {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();
  late GameProgress _progress;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _reloadProgress() async {
    final updated = await _storage.loadProgress();
    if (mounted) {
      setState(() {
        _progress = updated;
      });
    }
  }

  int get _completedStagesCount {
    int count = 0;
    for (final world in GastroWorld.worlds) {
      if (_progress.isWorldCompleted(world.id)) {
        count++;
      }
    }
    return count;
  }

  void _openStage(GastroWorld world) {
    _audio.playStageSelect();
    Navigator.of(context)
        .push(
          buildCapsuleRoute(
            CapsuleWarriorsBriefingScreen(
              world: world,
              progress: _progress,
            ),
          ),
        )
        .then((_) => _reloadProgress());
  }

  void _scrollHorizontal(double delta) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + delta)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completedStagesCount;
    final totalStages = GastroWorld.worlds.length;
    final completionRatio =
        totalStages > 0 ? (completedCount / totalStages).clamp(0.0, 1.0) : 0.0;
    final totalQuestionsCount = allGastroQuestions.length;

    return Scaffold(
      backgroundColor: CapsuleColors.deepOcean,
      body: CapsuleParallaxBackground(
        showHeroCapsule: false,
        showEnemySilhouettes: true,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrowPortrait = constraints.maxWidth < 600;
              final bool isShortLandscape = constraints.maxHeight < 460;

              return Column(
                children: [
                  // 1. RESPONSIVE HEADER (Zero mid-word wrapping on phones!)
                  _buildHeader(
                    isNarrowPortrait: isNarrowPortrait,
                    isShortLandscape: isShortLandscape,
                    totalQuestionsCount: totalQuestionsCount,
                  ),

                  // 2. MISSION CARDS DECK (Vertical clean list on Portrait, Horizontal Carousel on Landscape/Desktop)
                  Expanded(
                    child: isNarrowPortrait
                        ? ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            physics: const BouncingScrollPhysics(),
                            itemCount: GastroWorld.worlds.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) => _buildPortraitStageCard(
                              GastroWorld.worlds[index],
                            ),
                          )
                        : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1260),
                              child: Row(
                                children: [
                                  if (constraints.maxWidth > 720)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: _buildArrowNavButton(
                                        Icons.chevron_left_rounded,
                                        () => _scrollHorizontal(-260),
                                      ),
                                    ),
                                  Expanded(
                                    child: SizedBox(
                                      height: isShortLandscape ? 228 : 300,
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                        itemCount: GastroWorld.worlds.length,
                                        itemBuilder: (context, index) => _buildHorizontalStageCard(
                                          GastroWorld.worlds[index],
                                          isShortLandscape,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (constraints.maxWidth > 720)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: _buildArrowNavButton(
                                        Icons.chevron_right_rounded,
                                        () => _scrollHorizontal(260),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                  ),

                  // 3. CLEAN BOTTOM GLOBAL PROGRESS BAR
                  _buildBottomProgressBar(
                    completedCount: completedCount,
                    totalStages: totalStages,
                    completionRatio: completionRatio,
                    isCompact: isShortLandscape || isNarrowPortrait,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required bool isNarrowPortrait,
    required bool isShortLandscape,
    required int totalQuestionsCount,
  }) {
    final backBtn = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        _audio.playClick();
        Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrowPortrait ? 12 : 14,
          vertical: isShortLandscape ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CapsuleColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_rounded, color: CapsuleColors.cyanGlow, size: 18),
            const SizedBox(width: 6),
            Text(
              'RETOUR',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );

    final xpPill = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _audio.playClick();
            Navigator.of(context).push(
              buildCapsuleRoute(CapsuleWarriorsReviewScreen(progress: _progress)),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CapsuleColors.turquoise.withValues(alpha: 0.55)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_rounded, color: CapsuleColors.turquoise, size: 16),
                const SizedBox(width: 5),
                Text(
                  'FICHES',
                  style: GoogleFonts.plusJakartaSans(
                    color: CapsuleColors.turquoise,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: CapsuleColors.oceanSurface.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CapsuleColors.gold.withValues(alpha: 0.65)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: CapsuleColors.gold, size: 16),
              const SizedBox(width: 4),
              Text(
                '${_progress.totalXP} XP',
                style: GoogleFonts.orbitron(
                  color: CapsuleColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final titleColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'CHOISISSEZ VOTRE MISSION',
            maxLines: 1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isShortLandscape ? 16 : 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '7 ÉTAPES DIGESTIVES • $totalQuestionsCount QUESTIONS CLINIQUES',
            maxLines: 1,
            style: GoogleFonts.inter(
              color: CapsuleColors.cyanGlow,
              fontSize: isShortLandscape ? 10.5 : 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );

    if (isNarrowPortrait) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [backBtn, xpPill],
              ),
            ),
            const SizedBox(height: 12),
            titleColumn,
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isShortLandscape ? 6 : 12,
      ),
      child: Row(
        children: [
          backBtn,
          const SizedBox(width: 14),
          Expanded(child: Center(child: titleColumn)),
          const SizedBox(width: 14),
          xpPill,
        ],
      ),
    );
  }

  Widget _buildArrowNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: CapsuleColors.cardOcean.withValues(alpha: 0.90),
          shape: BoxShape.circle,
          border: Border.all(color: CapsuleColors.cardBorder),
        ),
        child: Icon(icon, color: CapsuleColors.cyanGlow, size: 26),
      ),
    );
  }

  /// Landscape / Desktop Card
  Widget _buildHorizontalStageCard(GastroWorld world, bool isShortLandscape) {
    final isUnlocked = _progress.isWorldUnlocked(world.id);
    final isCompleted = _progress.isWorldCompleted(world.id);
    final stars = _progress.getStars(world.id);
    final qLabel = world.id == 7 ? 'Révision' : '${world.questionIds.length} Q';

    return Container(
      width: isShortLandscape ? 210 : 238,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUnlocked
              ? [
                  CapsuleColors.cardOcean,
                  CapsuleColors.oceanSurface,
                ]
              : [
                  CapsuleColors.deepOcean.withValues(alpha: 0.85),
                  CapsuleColors.deepOcean.withValues(alpha: 0.70),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? CapsuleColors.mintGreen
              : (isUnlocked ? world.primaryColor.withValues(alpha: 0.75) : CapsuleColors.cardBorder),
          width: isUnlocked ? 1.8 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: isUnlocked ? () => _openStage(world) : null,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(isShortLandscape ? 10 : 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stage Tag + Question Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STAGE 0${world.id}',
                          style: GoogleFonts.orbitron(
                            fontSize: isShortLandscape ? 12 : 13.5,
                            fontWeight: FontWeight.w900,
                            color: isUnlocked ? world.primaryColor : CapsuleColors.textMuted,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: CapsuleColors.deepOcean.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            qLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: CapsuleColors.cyanGlow,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isShortLandscape ? 6 : 8),

                    // Bright Environment Illustration Thumbnail
                    Container(
                      width: double.infinity,
                      height: isShortLandscape ? 54 : 78,
                      decoration: BoxDecoration(
                        color: world.tunnelDeepColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: world.primaryColor.withValues(alpha: 0.35)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: CustomPaint(
                          painter: _StageThumbnailPainter(
                            worldId: world.id,
                            primaryColor: world.primaryColor,
                            secondaryColor: world.secondaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isShortLandscape ? 6 : 10),

                    // Title & Anatomical Organ Zone & Subtitle
                    Text(
                      world.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isShortLandscape ? 12.5 : 14,
                        fontWeight: FontWeight.w800,
                        color: isUnlocked ? Colors.white : CapsuleColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            world.organZone.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              color: isUnlocked ? CapsuleColors.cyanGlow : CapsuleColors.textMuted,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Flexible(
                            child: Text(
                              world.subtitle,
                              maxLines: isShortLandscape ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: isShortLandscape ? 10.5 : 11.5,
                                color: CapsuleColors.textSubtle,
                                height: 1.22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Row: Stars + Launch Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (starIdx) {
                            final isEarned = starIdx < stars;
                            return Icon(
                              Icons.star_rounded,
                              size: isShortLandscape ? 16 : 18,
                              color: isEarned
                                  ? CapsuleColors.gold
                                  : CapsuleColors.textMuted.withValues(alpha: 0.35),
                            );
                          }),
                        ),
                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? CapsuleColors.mintGreen.withValues(alpha: 0.22)
                                  : world.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCompleted ? 'REJOUER' : 'JOUER',
                              style: GoogleFonts.plusJakartaSans(
                                color: isCompleted ? CapsuleColors.mintGreen : CapsuleColors.deepOcean,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              if (!isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: CapsuleColors.deepOcean.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded, color: CapsuleColors.textSubtle, size: isShortLandscape ? 26 : 32),
                          const SizedBox(height: 4),
                          Text(
                            'STAGE ${world.id - 1} REQUIS',
                            style: GoogleFonts.plusJakartaSans(
                              color: CapsuleColors.textSubtle,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Portrait Phone Full-Width Ergonomic Card (Zero clipped letters!)
  Widget _buildPortraitStageCard(GastroWorld world) {
    final isUnlocked = _progress.isWorldUnlocked(world.id);
    final isCompleted = _progress.isWorldCompleted(world.id);
    final stars = _progress.getStars(world.id);
    final qLabel = world.id == 7 ? 'Mode Révision' : '${world.questionIds.length} Questions';

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.62,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CapsuleColors.cardOcean,
              CapsuleColors.oceanSurface,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? CapsuleColors.mintGreen
                : (isUnlocked ? world.primaryColor.withValues(alpha: 0.75) : CapsuleColors.cardBorder),
            width: isUnlocked ? 1.8 : 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isUnlocked ? () => _openStage(world) : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Thumbnail
                  Container(
                    width: 82,
                    height: 74,
                    decoration: BoxDecoration(
                      color: world.tunnelDeepColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: world.primaryColor.withValues(alpha: 0.45)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomPaint(
                            painter: _StageThumbnailPainter(
                              worldId: world.id,
                              primaryColor: world.primaryColor,
                              secondaryColor: world.secondaryColor,
                            ),
                          ),
                          if (!isUnlocked)
                            Container(
                              color: CapsuleColors.deepOcean.withValues(alpha: 0.65),
                              child: const Icon(Icons.lock_rounded, color: Colors.white70, size: 24),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'STAGE 0${world.id}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.orbitron(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: isUnlocked ? world.primaryColor : CapsuleColors.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: CapsuleColors.deepOcean.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                qLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: CapsuleColors.cyanGlow,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          world.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          world.organZone.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: isUnlocked ? CapsuleColors.cyanGlow : CapsuleColors.textMuted,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          world.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: CapsuleColors.textSubtle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(3, (starIdx) {
                                return Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: starIdx < stars
                                      ? CapsuleColors.gold
                                      : CapsuleColors.textMuted.withValues(alpha: 0.35),
                                );
                              }),
                            ),
                            if (isUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? CapsuleColors.mintGreen.withValues(alpha: 0.22)
                                      : world.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isCompleted ? 'REJOUER' : 'LANCER',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isCompleted
                                        ? CapsuleColors.mintGreen
                                        : CapsuleColors.deepOcean,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomProgressBar({
    required int completedCount,
    required int totalStages,
    required double completionRatio,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 32, vertical: isCompact ? 8 : 12),
      decoration: BoxDecoration(
        color: CapsuleColors.deepOcean.withValues(alpha: 0.85),
        border: const Border(top: BorderSide(color: CapsuleColors.cardBorder)),
      ),
      child: Row(
        children: [
          Text(
            '$completedCount/$totalStages MISSIONS',
            style: GoogleFonts.plusJakartaSans(
              color: CapsuleColors.cyanGlow,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: completionRatio,
                backgroundColor: CapsuleColors.oceanSurface,
                valueColor: const AlwaysStoppedAnimation<Color>(CapsuleColors.mintGreen),
                minHeight: 7,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(completionRatio * 100).toInt()}%',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageThumbnailPainter extends CustomPainter {
  final int worldId;
  final Color primaryColor;
  final Color secondaryColor;

  _StageThumbnailPainter({
    required this.worldId,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Organic double-layered digestive lumen curve (distinct amplitude/frequency per world)
    final lumenPath = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.64 + math.sin(x * (0.045 + worldId * 0.006) + worldId * 1.1) * 9.0;
      lumenPath.lineTo(x, y);
    }
    lumenPath.lineTo(size.width, size.height);
    lumenPath.close();

    canvas.drawPath(
      lumenPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.45),
            CapsuleColors.deepOcean.withValues(alpha: 0.78),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Subtle glowing organ rim curve
    final rimPath = Path();
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.64 + math.sin(x * (0.045 + worldId * 0.006) + worldId * 1.1) * 9.0;
      if (x == 0) {
        rimPath.moveTo(x, y);
      } else {
        rimPath.lineTo(x, y);
      }
    }
    canvas.drawPath(
      rimPath,
      Paint()
        ..color = secondaryColor.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Distinct anatomical / bio bubbles
    canvas.drawCircle(
      Offset(size.width * (0.20 + (worldId % 3) * 0.06), size.height * 0.36),
      8,
      Paint()..color = secondaryColor.withValues(alpha: 0.48),
    );
    canvas.drawCircle(
      Offset(size.width * 0.68, size.height * 0.42),
      11,
      Paint()..color = primaryColor.withValues(alpha: 0.52),
    );
    // Miniature capsule icon silhouette swimming through zone
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.45, size.height * 0.44), width: 24, height: 13),
        const Radius.circular(6.5),
      ),
      Paint()..color = const Color(0xFFF4F8FC).withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(size.width * 0.45 + 6, size.height * 0.44),
      4.2,
      Paint()..color = const Color(0xFF20D5E8),
    );
  }

  @override
  bool shouldRepaint(covariant _StageThumbnailPainter oldDelegate) =>
      oldDelegate.worldId != worldId;
}
