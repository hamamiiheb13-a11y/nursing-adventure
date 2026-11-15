import 'package:flutter/material.dart';
import '../models/player.dart';

class ActionBanner extends StatelessWidget {
  final Player activePlayer;
  final String statusText;
  final String? eventSubtitle;
  final bool isSpecialEvent;
  final bool isLadder;

  const ActionBanner({
    super.key,
    required this.activePlayer,
    required this.statusText,
    this.eventSubtitle,
    this.isSpecialEvent = false,
    this.isLadder = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bannerBorder = activePlayer.character.accentColor;
    Color bannerBg = const Color(0xFF0F1E36);

    if (isSpecialEvent) {
      if (isLadder) {
        bannerBorder = const Color(0xFFFFD166);
        bannerBg = const Color(0xFF0E3830);
      } else {
        bannerBorder = const Color(0xFFFF385C);
        bannerBg = const Color(0xFF380E14);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bannerBg.withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bannerBorder.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: bannerBorder.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Event / Player Icon
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bannerBorder.withOpacity(0.2),
              border: Border.all(color: bannerBorder, width: 1.5),
            ),
            child: Icon(
              isSpecialEvent
                  ? (isLadder ? Icons.trending_up_rounded : Icons.warning_rounded)
                  : Icons.navigation_rounded,
              size: 18,
              color: bannerBorder,
            ),
          ),
          const SizedBox(width: 10),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: bannerBorder,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (eventSubtitle != null && eventSubtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    eventSubtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Player indicator pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activePlayer.character.primaryColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: activePlayer.character.accentColor, width: 1),
            ),
            child: Text(
              'Sq ${activePlayer.currentSquare}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: activePlayer.character.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
