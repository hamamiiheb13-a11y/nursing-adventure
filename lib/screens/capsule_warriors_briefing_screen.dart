import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../models/gastro_world.dart';
import '../models/gastro_question.dart';
import '../arcade/weapon_system.dart';
import '../arcade/gastro_arcade_screen.dart';
import '../services/storage_service.dart';
import '../audio/audio_service.dart';
import '../widgets/tactile_button.dart';

class CapsuleWarriorsBriefingScreen extends StatefulWidget {
  final GastroWorld world;
  final GameProgress progress;

  const CapsuleWarriorsBriefingScreen({
    super.key,
    required this.world,
    required this.progress,
  });

  @override
  State<CapsuleWarriorsBriefingScreen> createState() => _CapsuleWarriorsBriefingScreenState();
}

class _CapsuleWarriorsBriefingScreenState extends State<CapsuleWarriorsBriefingScreen> {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();
  late int _selectedLevel;

  @override
  void initState() {
    super.initState();
    // Default to highest unlocked level within this world or the world's start level
    final currentUnlocked = widget.progress.currentUnlockedLevel;
    if (currentUnlocked >= widget.world.startLevel && currentUnlocked <= widget.world.endLevel) {
      _selectedLevel = currentUnlocked;
    } else if (currentUnlocked > widget.world.endLevel) {
      _selectedLevel = widget.world.startLevel;
    } else {
      _selectedLevel = widget.world.startLevel;
    }
  }

  void _onEquipWeapon(String weaponName) {
    setState(() {
      widget.progress.equippedWeapon = weaponName;
    });
    _storage.saveProgress(widget.progress);
    _audio.playTargetLock();
  }

  void _launchMission() {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GastroArcadeScreen(
          level: _selectedLevel,
          progress: widget.progress,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 750;
    final world = widget.world;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          'BRIEFING DE MISSION • MONDE ${world.id}',
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
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // World Banner
                _buildWorldBanner(isMobile),
                const SizedBox(height: 20),

                // Sector Levels Selector
                _buildLevelSelector(),
                const SizedBox(height: 24),

                // Boss Intelligence Card
                _buildBossIntelCard(),
                const SizedBox(height: 24),

                // Weapon Loadout Selector
                _buildWeaponArsenalSection(),
                const SizedBox(height: 28),

                // Launch Button
                TactileButton(
                  label: 'Lancer la Capsule (Niveau $_selectedLevel)',
                  subtitle: 'Initialiser la propulsion et entrer dans la muqueuse gastrique',
                  icon: Icons.rocket_launch_rounded,
                  style: TactileButtonStyle.primary,
                  height: 60,
                  onPressed: _launchMission,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorldBanner(bool isMobile) {
    final world = widget.world;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: world.primaryColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: world.primaryColor.withValues(alpha: 0.15),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [world.primaryColor, world.secondaryColor]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(world.icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: world.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ZONE ${world.id} • ${world.title.toUpperCase()}',
                        style: GoogleFonts.plusJakartaSans(
                          color: world.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Q${world.startLevel} à Q${world.endLevel}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  world.description,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFE2E8F0),
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelector() {
    final world = widget.world;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SÉLECTIONNEZ LE NIVEAU DU SECTEUR',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(world.endLevel - world.startLevel + 1, (i) {
            final lvl = world.startLevel + i;
            final isUnlocked = widget.progress.isLevelUnlocked(lvl);
            final isCompleted = widget.progress.isLevelCompleted(lvl);
            final isSelected = lvl == _selectedLevel;
            final stars = widget.progress.getStars(lvl);

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: isUnlocked
                  ? () {
                      _audio.playClick();
                      setState(() => _selectedLevel = lvl);
                    }
                  : null,
              child: Container(
                width: 96,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? world.primaryColor.withValues(alpha: 0.25)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? world.primaryColor
                        : isUnlocked
                            ? const Color(0xFF334155)
                            : const Color(0xFF1E293B),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'NIVEAU $lvl',
                      style: GoogleFonts.plusJakartaSans(
                        color: isUnlocked ? Colors.white : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isCompleted)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (s) {
                          return Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: s < stars ? const Color(0xFFFFD166) : const Color(0xFF475569),
                          );
                        }),
                      )
                    else if (isUnlocked)
                      Text(
                        'En cours',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00E5FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBossIntelCard() {
    final boss = widget.world.boss;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
            ),
            child: Icon(boss.icon, color: const Color(0xFFEF4444), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ALERTE BOSS DE FIN DE SECTEUR',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFEF4444),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'DANGER MAX',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  boss.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  boss.title,
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

  Widget _buildWeaponArsenalSection() {
    final unlockedWeapons = widget.progress.unlockedWeapons;
    final equipped = widget.progress.equippedWeapon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ARSENAL MÉDICAL DE LA CAPSULE',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${unlockedWeapons.length} / ${WeaponConfig.allWeapons.length} Armes Débloquées',
              style: GoogleFonts.inter(
                color: const Color(0xFF00E5FF),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: WeaponConfig.allWeapons.map((weapon) {
            final isUnlocked = unlockedWeapons.contains(weapon.name);
            final isEquipped = equipped == weapon.name;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isEquipped
                    ? weapon.glowColor.withValues(alpha: 0.15)
                    : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isEquipped
                      ? weapon.glowColor
                      : isUnlocked
                          ? const Color(0xFF334155)
                          : const Color(0xFF1E293B),
                  width: isEquipped ? 1.8 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUnlocked ? weapon.icon : Icons.lock_rounded,
                    color: isUnlocked ? weapon.glowColor : const Color(0xFF64748B),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weapon.name,
                          style: GoogleFonts.plusJakartaSans(
                            color: isUnlocked ? Colors.white : const Color(0xFF64748B),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          weapon.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isUnlocked)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEquipped ? weapon.glowColor : const Color(0xFF1E293B),
                        foregroundColor: isEquipped ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                      onPressed: isEquipped ? null : () => _onEquipWeapon(weapon.name),
                      child: Text(
                        isEquipped ? 'Équipée' : 'Équiper',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 11.5),
                      ),
                    )
                  else
                    Text(
                      'Débloqué plus tard',
                      style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
