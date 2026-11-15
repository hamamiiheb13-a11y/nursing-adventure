import 'package:flutter/material.dart';
import '../audio/audio_service.dart';
import '../models/character.dart';
import '../models/player.dart';
import '../widgets/anime_avatar.dart';
import '../widgets/anime_background.dart';
import 'game_screen.dart';

class CharacterSelectScreen extends StatefulWidget {
  final int playerCount;
  final bool vsAI;
  final bool isFastSpeed;

  const CharacterSelectScreen({
    super.key,
    required this.playerCount,
    required this.vsAI,
    required this.isFastSpeed,
  });

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  final AudioService _audio = AudioService();
  late int _activePlayerCount;
  int _currentConfiguringPlayer = 0;

  // Selected character IDs for players
  late List<CharacterId> _selectedCharacters;
  late List<TextEditingController> _nameControllers;

  @override
  void initState() {
    super.initState();
    _activePlayerCount = widget.playerCount;

    final defaultIds = [
      CharacterId.lyra,
      CharacterId.kai,
      CharacterId.aria,
      CharacterId.jin,
    ];

    _selectedCharacters = List.generate(
      _activePlayerCount,
      (i) => defaultIds[i % defaultIds.length],
    );

    _nameControllers = List.generate(_activePlayerCount, (i) {
      if (widget.vsAI && i == 1) {
        return TextEditingController(text: 'Dr. Bot (AI)');
      }
      return TextEditingController(text: 'Player ${i + 1}');
    });
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onStartGame() {
    _audio.playClick();

    final List<Player> players = [];
    for (int i = 0; i < _activePlayerCount; i++) {
      final character = Character.getById(_selectedCharacters[i]);
      final name = _nameControllers[i].text.trim().isEmpty
          ? (widget.vsAI && i == 1 ? 'Dr. Bot' : 'Player ${i + 1}')
          : _nameControllers[i].text.trim();

      players.add(Player(
        id: i + 1,
        name: name,
        character: character,
        isAI: widget.vsAI && i == 1,
      ));
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          players: players,
          isFastSpeed: widget.isFastSpeed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final curChar = Character.getById(_selectedCharacters[_currentConfiguringPlayer]);
    final isConfiguringAI = widget.vsAI && _currentConfiguringPlayer == 1;

    return Scaffold(
      backgroundColor: const Color(0xFF040D1A),
      body: AnimeBackground(
        showFloatingElements: false,
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        _audio.playClick();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CREW SELECTION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00E5FF), width: 1),
                      ),
                      child: Text(
                        widget.vsAI ? 'SOLO VS AI' : '$_activePlayerCount PLAYERS',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // Player Tabs (P1, P2, P3, P4)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: List.generate(_activePlayerCount, (index) {
                    final isSelected = index == _currentConfiguringPlayer;
                    final char = Character.getById(_selectedCharacters[index]);
                    final isAI = widget.vsAI && index == 1;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () {
                            _audio.playClick();
                            setState(() => _currentConfiguringPlayer = index);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? char.accentColor.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? char.accentColor : Colors.white12,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                AnimeAvatar(
                                  characterId: char.id,
                                  size: 32,
                                  showBadge: false,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAI ? 'Dr. Bot (AI)' : 'Player ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.white60,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Character Details & Selection
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        // Player Name Field
                        TextField(
                          controller: _nameControllers[_currentConfiguringPlayer],
                          enabled: !isConfiguringAI,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            labelText: isConfiguringAI
                                ? 'AI Opponent'
                                : 'Player ${_currentConfiguringPlayer + 1} Name',
                            labelStyle: const TextStyle(color: Color(0xFF90E0EF)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            prefixIcon: Icon(
                              isConfiguringAI ? Icons.smart_toy_rounded : Icons.edit_rounded,
                              color: const Color(0xFF00E5FF),
                              size: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Character Cards Grid (Pick 1 of 4)
                        Row(
                          children: Character.allCharacters.map((c) {
                            final isPickedForCurrent = _selectedCharacters[_currentConfiguringPlayer] == c.id;

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: InkWell(
                                  onTap: () {
                                    _audio.playClick();
                                    setState(() {
                                      _selectedCharacters[_currentConfiguringPlayer] = c.id;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: isPickedForCurrent
                                          ? c.accentColor.withOpacity(0.25)
                                          : const Color(0xFF0B1E38).withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isPickedForCurrent ? c.accentColor : Colors.white12,
                                        width: isPickedForCurrent ? 2.5 : 1,
                                      ),
                                      boxShadow: isPickedForCurrent
                                          ? [
                                              BoxShadow(
                                                color: c.accentColor.withOpacity(0.4),
                                                blurRadius: 10,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Column(
                                      children: [
                                        AnimeAvatar(characterId: c.id, size: 50),
                                        const SizedBox(height: 6),
                                        Text(
                                          c.name.split(' ')[0],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isPickedForCurrent ? Colors.white : Colors.white70,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Active Character Bio & Stats Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF091F38),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: curChar.accentColor.withOpacity(0.5), width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AnimeAvatar(characterId: curChar.id, size: 56),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          curChar.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          curChar.title,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: curChar.accentColor,
                                          ),
                                        ),
                                        Text(
                                          curChar.specialty,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF90E0EF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '"${curChar.motto}"',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFFFFD166),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                curChar.bio,
                                style: const TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.3),
                              ),
                              const SizedBox(height: 14),

                              // Character Stats Bar
                              const Text(
                                'CLINICAL ATTRIBUTES',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...curChar.stats.entries.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          e.key,
                                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                                        ),
                                      ),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: e.value / 100,
                                            backgroundColor: Colors.white10,
                                            valueColor: AlwaysStoppedAnimation(curChar.accentColor),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${e.value}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: curChar.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Start Game Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF040D1A),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onStartGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD166),
                          foregroundColor: const Color(0xFF040D1A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.white, width: 1.5),
                          ),
                          elevation: 8,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.anchor_rounded, color: Color(0xFF040D1A), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'SET SAIL • START GAME',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Color(0xFF040D1A),
                              ),
                            ),
                          ],
                        ),
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
}
