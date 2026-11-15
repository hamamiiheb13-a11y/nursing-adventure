import 'package:flutter/material.dart';
import '../audio/audio_service.dart';
import '../models/character.dart';
import '../widgets/anime_avatar.dart';
import '../widgets/anime_background.dart';
import '../widgets/instructions_dialog.dart';
import '../widgets/settings_dialog.dart';
import 'character_select_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final AudioService _audio = AudioService();
  bool _isFastSpeed = false;

  void _startGame(int playerCount, bool vsAI) {
    _audio.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterSelectScreen(
          playerCount: playerCount,
          vsAI: vsAI,
          isFastSpeed: _isFastSpeed,
        ),
      ),
    );
  }

  void _openInstructions() {
    _audio.playClick();
    showDialog(
      context: context,
      builder: (context) => const InstructionsDialog(),
    );
  }

  void _openSettings() {
    _audio.playClick();
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        isFastSpeed: _isFastSpeed,
        onSpeedChanged: (val) {
          setState(() => _isFastSpeed = val);
        },
      ),
    );
  }

  void _showCrewLore() {
    _audio.playClick();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 580),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1E38),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5), width: 2),
            boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 20)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.people_alt_rounded, color: Color(0xFF00E5FF), size: 24),
                      SizedBox(width: 10),
                      Text(
                        'MEDICAL CREW ROSTER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 20),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: Character.allCharacters.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final c = Character.allCharacters[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.accentColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimeAvatar(characterId: c.id, size: 54),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(c.badgeIcon, size: 16, color: c.accentColor),
                                  ],
                                ),
                                Text(
                                  c.title,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: c.accentColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c.bio,
                                  style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      body: AnimeBackground(
        showFloatingElements: true,
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Audio Toggles & Settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    // Brand / Mini Logo
                    const Row(
                      children: [
                        Icon(Icons.local_hospital_rounded, color: Color(0xFF00E5FF), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'NURSING ADVENTURE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Sound Toggle Button
                    IconButton(
                      icon: Icon(
                        _audio.sfxEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: _audio.sfxEnabled ? const Color(0xFF00E5FF) : Colors.white38,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _audio.toggleSfx();
                        });
                      },
                    ),

                    // Music Toggle Button
                    IconButton(
                      icon: Icon(
                        _audio.bgmEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                        color: _audio.bgmEnabled ? const Color(0xFFFFD166) : Colors.white38,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _audio.toggleBgm();
                        });
                      },
                    ),

                    // Settings Button
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, color: Colors.white70, size: 22),
                      onPressed: _openSettings,
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // Main Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Select Game Mode Header
                          const Text(
                            'SELECT GAME MODE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Color(0xFFFFD166),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Choose how you want to challenge the medical board',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Mode 1: Solo vs AI Dr. Bot
                          _buildModeCard(
                            title: 'SOLO ADVENTURE',
                            subtitle: 'Play against AI Dr. Bot • Solo Clinical Training',
                            badge: '1 PLAYER VS AI',
                            badgeColor: const Color(0xFF00E5FF),
                            icon: Icons.smart_toy_rounded,
                            accentColor: const Color(0xFF00E5FF),
                            onTap: () => _startGame(2, true),
                          ),

                          const SizedBox(height: 14),

                          // Mode 2: 2 Players Pass & Play
                          _buildModeCard(
                            title: 'CREW DUEL (PASS & PLAY)',
                            subtitle: '2 Players on One Device • Perfect for Study Buddies',
                            badge: '2 PLAYERS',
                            badgeColor: const Color(0xFFFFD166),
                            icon: Icons.people_outline_rounded,
                            accentColor: const Color(0xFFFFD166),
                            onTap: () => _startGame(2, false),
                          ),

                          const SizedBox(height: 14),

                          // Mode 3: 3-4 Players Study Squad
                          _buildModeCard(
                            title: 'STUDY SQUAD TOURNAMENT',
                            subtitle: '3 to 4 Players • Complete Nursing Group Race',
                            badge: '3 - 4 PLAYERS',
                            badgeColor: const Color(0xFFFF758F),
                            icon: Icons.groups_rounded,
                            accentColor: const Color(0xFFFF758F),
                            onTap: () => _startGame(4, false),
                          ),

                          const SizedBox(height: 24),

                          // Action Buttons: How to play & Crew Roster
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                                  label: const Text('HOW TO PLAY'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white24),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: _openInstructions,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.badge_rounded, size: 18),
                                  label: const Text('MEET THE CREW'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF90E0EF),
                                    side: const BorderSide(color: Color(0xFF90E0EF)),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: _showCrewLore,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F2B48).withOpacity(0.9),
                const Color(0xFF091C30).withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.15),
                  border: Border.all(color: accentColor, width: 2),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 14),

              // Title & details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: badgeColor, width: 0.8),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
