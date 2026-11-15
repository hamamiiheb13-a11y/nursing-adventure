enum GameEventType {
  roll,
  hop,
  ladder,
  snake,
  win,
  turnStart,
}

class GameEvent {
  final GameEventType type;
  final String title;
  final String message;
  final int playerId;
  final String playerName;
  final DateTime timestamp;

  GameEvent({
    required this.type,
    required this.title,
    required this.message,
    required this.playerId,
    required this.playerName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
