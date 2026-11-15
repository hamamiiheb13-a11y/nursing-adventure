import 'package:flutter/material.dart';

class BoardTile {
  final int number;
  final int row; // 0 (top) to 9 (bottom)
  final int col; // 0 (left) to 9 (right)
  final int? ladderTo;
  final String? ladderName;
  final int? snakeTo;
  final String? snakeName;
  final String? medicalTip;
  final IconData? icon;

  const BoardTile({
    required this.number,
    required this.row,
    required this.col,
    this.ladderTo,
    this.ladderName,
    this.snakeTo,
    this.snakeName,
    this.medicalTip,
    this.icon,
  });

  bool get hasLadder => ladderTo != null && ladderTo! > number;
  bool get hasSnake => snakeTo != null && snakeTo! < number;
}

class BoardDefinition {
  // Ladders: Base -> Top (7 Ladders)
  static const Map<int, Map<String, dynamic>> ladders = {
    4: {'to': 14, 'name': 'Rapid Triage', 'tip': 'Quick acuity assessment secures priority patient beds!'},
    9: {'to': 31, 'name': 'IV Hydration Surge', 'tip': 'Timely fluid replacement prevents hypovolemic shock!'},
    21: {'to': 42, 'name': 'High-Quality CPR', 'tip': '100-120 compressions/min restores spontaneous circulation!'},
    28: {'to': 84, 'name': 'Defibrillator Surge', 'tip': 'Immediate shock in VFib triples survival rates!'},
    51: {'to': 67, 'name': '5 Rights of Meds', 'tip': 'Right Patient, Drug, Dose, Route & Time prevent error!'},
    72: {'to': 91, 'name': 'Early Sepsis Protocol', 'tip': 'Lactate, cultures, and broad-spectrum antibiotics within 1 hr!'},
    80: {'to': 99, 'name': 'ICU Full Recovery', 'tip': 'Comprehensive critical monitoring leads to total discharge!'},
  };

  // Snakes: Head -> Tail (8 Snakes)
  static const Map<int, Map<String, dynamic>> snakes = {
    17: {'to': 7, 'name': 'Medication Mixup', 'tip': 'Always scan patient wristband before IV administration!'},
    54: {'to': 34, 'name': 'Needlestick Hazard', 'tip': 'Never recap needles by hand – use the sharps safety device!'},
    62: {'to': 19, 'name': 'Sepsis Shock Cascade', 'tip': 'Missed early tachycardia and hypotension caused septic drop!'},
    64: {'to': 60, 'name': 'Documentation Gap', 'tip': 'If it wasn\'t documented, in clinical practice it wasn\'t done!'},
    87: {'to': 36, 'name': 'Burnout Breakdown', 'tip': 'Remember self-care and crew handoffs during high-pressure shifts!'},
    93: {'to': 73, 'name': 'Nosocomial Infection', 'tip': 'Break in aseptic technique caused line infection! Hand hygiene first!'},
    95: {'to': 75, 'name': 'Anaphylaxis Alert', 'tip': 'Always verify patient allergy band before first antibiotic dose!'},
    98: {'to': 79, 'name': 'Unverified Dosage Miss', 'tip': 'Decimal point oversight caught at the finish line! Double-check calculations!'},
  };

  // Medical icons for key tiles
  static IconData? getTileIcon(int num) {
    if (num == 100) return Icons.military_tech_rounded;
    if (ladders.containsKey(num)) return Icons.trending_up_rounded;
    if (snakes.containsKey(num)) return Icons.warning_amber_rounded;
    if (num % 10 == 0) return Icons.local_hospital_rounded;
    if (num % 7 == 0) return Icons.favorite_rounded;
    if (num % 5 == 0) return Icons.healing_rounded;
    if (num % 3 == 0) return Icons.medication_rounded;
    return null;
  }

  // Pre-generate all 100 tiles
  static List<BoardTile> generateTiles() {
    final List<BoardTile> tiles = [];
    for (int n = 1; n <= 100; n++) {
      final int rowFromBottom = (n - 1) ~/ 10;
      final int colInRow = (n - 1) % 10;
      final int col = (rowFromBottom % 2 == 0) ? colInRow : (9 - colInRow);
      final int row = 9 - rowFromBottom;

      final ladderData = ladders[n];
      final snakeData = snakes[n];

      tiles.add(BoardTile(
        number: n,
        row: row,
        col: col,
        ladderTo: ladderData?['to'] as int?,
        ladderName: ladderData?['name'] as String?,
        snakeTo: snakeData?['to'] as int?,
        snakeName: snakeData?['name'] as String?,
        medicalTip: (ladderData?['tip'] ?? snakeData?['tip']) as String?,
        icon: getTileIcon(n),
      ));
    }
    return tiles;
  }
}
