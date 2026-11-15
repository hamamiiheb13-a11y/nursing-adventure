import 'character.dart';

class Player {
  final int id;
  String name;
  final Character character;
  int currentSquare;
  int targetSquare;
  final bool isAI;

  // Game stats
  int diceRolls;
  int laddersClimbed;
  int snakesBitten;
  int totalSteps;

  Player({
    required this.id,
    required this.name,
    required this.character,
    this.currentSquare = 1,
    this.targetSquare = 1,
    this.isAI = false,
    this.diceRolls = 0,
    this.laddersClimbed = 0,
    this.snakesBitten = 0,
    this.totalSteps = 0,
  });

  bool get hasWon => currentSquare >= 100;

  void reset() {
    currentSquare = 1;
    targetSquare = 1;
    diceRolls = 0;
    laddersClimbed = 0;
    snakesBitten = 0;
    totalSteps = 0;
  }
}
