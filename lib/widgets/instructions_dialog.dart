import 'package:flutter/material.dart';
import '../audio/audio_service.dart';
import '../models/board_tile.dart';

class InstructionsDialog extends StatelessWidget {
  const InstructionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 600),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1E38),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFD166).withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD166).withOpacity(0.2),
              blurRadius: 22,
              spreadRadius: 1,
            ),
            const BoxShadow(color: Colors.black87, blurRadius: 18),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: Color(0xFFFFD166), size: 24),
                    SizedBox(width: 10),
                    Text(
                      'HOW TO PLAY',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () {
                    AudioService().playClick();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 20),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Objective
                    _buildSectionHeader('1. MISSION OBJECTIVE', Icons.flag_rounded, const Color(0xFF00E5FF)),
                    const Text(
                      'Navigate the 100 clinical squares of the Grand Medical Sea. The first nurse to reach Square 100 wins the match and earns the title of Grand Line Trauma Master!',
                      style: TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    // Golden Rescue Ladders
                    _buildSectionHeader('2. GOLDEN RESCUE LADDERS', Icons.trending_up_rounded, const Color(0xFFFFD166)),
                    const Text(
                      'Land on the bottom of a golden ladder to execute a clinical breakthrough and climb straight up to higher squares!',
                      style: TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    _buildCardList(
                      BoardDefinition.ladders.entries.map((e) {
                        return 'Sq ${e.key} ➔ Sq ${e.value['to']}: ${e.value['name']}';
                      }).toList(),
                      const Color(0xFFFFD166),
                    ),
                    const SizedBox(height: 16),

                    // Hazard Red Snakes
                    _buildSectionHeader('3. HAZARD RED SNAKES', Icons.warning_rounded, const Color(0xFFFF5252)),
                    const Text(
                      'Beware the scary red serpents! Landing on a snake head represents a clinical complication, sliding you backwards down to its tail.',
                      style: TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    _buildCardList(
                      BoardDefinition.snakes.entries.map((e) {
                        return 'Sq ${e.key} ➔ Sq ${e.value['to']}: ${e.value['name']}';
                      }).toList(),
                      const Color(0xFFFF5252),
                    ),
                    const SizedBox(height: 16),

                    // Turn Flow
                    _buildSectionHeader('4. GAMEPLAY & TURNS', Icons.casino_rounded, const Color(0xFF00F5D4)),
                    const Text(
                      '• Players roll the 3D dice on their turn.\n'
                      '• Your character token hops forward step-by-step.\n'
                      '• Pass & Play allows 2 to 4 classmates to duel on a single smartphone or tablet.\n'
                      '• In Solo Mode, you face off against AI Dr. Bot who rolls automatically.',
                      style: TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Got it button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  AudioService().playClick();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD166),
                  foregroundColor: const Color(0xFF061121),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'GOT IT, LET\'S PLAY!',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList(List<String> items, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((text) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              children: [
                Icon(Icons.circle, size: 6, color: accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
