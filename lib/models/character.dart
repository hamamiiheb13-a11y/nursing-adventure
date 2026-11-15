import 'package:flutter/material.dart';

enum CharacterId {
  lyra,
  kai,
  aria,
  jin,
}

class Character {
  final CharacterId id;
  final String name;
  final String title;
  final String specialty;
  final String motto;
  final String bio;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final IconData badgeIcon;
  final String uniformStyle;
  final Map<String, int> stats; // Care, Speed, Focus, Wisdom (out of 100)

  const Character({
    required this.id,
    required this.name,
    required this.title,
    required this.specialty,
    required this.motto,
    required this.bio,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.badgeIcon,
    required this.uniformStyle,
    required this.stats,
  });

  static const List<Character> allCharacters = [
    Character(
      id: CharacterId.lyra,
      name: 'Captain Lyra',
      title: 'Trauma Fleet Commander',
      specialty: 'Emergency & Critical Care',
      motto: 'Steady hands through any storm!',
      bio: 'Fearless ER leader who steers the Grand Medical Fleet through high-acuity crises. Armed with rapid triage instincts and golden stethoscope authority.',
      primaryColor: Color(0xFF0B2545),
      secondaryColor: Color(0xFF134074),
      accentColor: Color(0xFFFFD166),
      badgeIcon: Icons.anchor_rounded,
      uniformStyle: 'Navy blue commander trenchcoat, gold medical epaulets & nurse captain cap',
      stats: {'Care': 95, 'Speed': 88, 'Focus': 92, 'Wisdom': 90},
    ),
    Character(
      id: CharacterId.kai,
      name: 'Kai Swift',
      title: 'Surgical Ninja Medic',
      specialty: 'OR & Sterile Mastery',
      motto: 'Zero delay, sterile precision!',
      bio: 'Lightning-fast surgical specialist with razor-sharp reflexes. Can prepare a sterile field, calculate drug dosages, and assist in surgery in the blink of an eye.',
      primaryColor: Color(0xFF006D77),
      secondaryColor: Color(0xFF83C5BE),
      accentColor: Color(0xFF00F5D4),
      badgeIcon: Icons.flash_on_rounded,
      uniformStyle: 'Turquoise surgical scrubs with tactical bandage pouch & cyan ninja headband',
      stats: {'Care': 82, 'Speed': 99, 'Focus': 96, 'Wisdom': 85},
    ),
    Character(
      id: CharacterId.aria,
      name: 'Aria Blossom',
      title: 'Pediatric Navigator',
      specialty: 'Pediatrics & Oncology',
      motto: 'Kindness is the strongest medicine!',
      bio: 'Compassionate sea navigator who brings warmth, hope, and emotional resilience to every patient ward. Masters delicate needle placements with a gentle smile.',
      primaryColor: Color(0xFF8B1E3F),
      secondaryColor: Color(0xFFD64045),
      accentColor: Color(0xFFFF99C8),
      badgeIcon: Icons.favorite_rounded,
      uniformStyle: 'Rose-coral nurse dress coat with medical satchel & golden syringe emblem',
      stats: {'Care': 100, 'Speed': 85, 'Focus': 90, 'Wisdom': 88},
    ),
    Character(
      id: CharacterId.jin,
      name: 'Doc Jin',
      title: 'Pharmacology Sage',
      specialty: 'Pharmacotherapy & Toxicology',
      motto: 'Every milligram determines the outcome!',
      bio: 'Scholarly apothecary doctor and clinical alchemist. Knows every antidote, contraindication, and mechanism of action across the Seven Medical Seas.',
      primaryColor: Color(0xFF3C096C),
      secondaryColor: Color(0xFF5A189A),
      accentColor: Color(0xFFE0AAFF),
      badgeIcon: Icons.science_rounded,
      uniformStyle: 'Deep violet tailored lab coat with glowing serum vials & sleek visor glasses',
      stats: {'Care': 87, 'Speed': 80, 'Focus': 98, 'Wisdom': 100},
    ),
  ];

  static Character getById(CharacterId id) {
    return allCharacters.firstWhere((c) => c.id == id);
  }
}
