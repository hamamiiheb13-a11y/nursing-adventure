String? _inMemorySessionPlayerId;

String? getSessionPlayerId() => _inMemorySessionPlayerId;

void setSessionPlayerId(String playerId) {
  _inMemorySessionPlayerId = playerId;
}

void clearSessionPlayerId() {
  _inMemorySessionPlayerId = null;
}

String? getUrlPlayerId() => null;
