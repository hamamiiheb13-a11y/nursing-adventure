import 'dart:js_interop';

const String _kSessionPlayerKey = 'gastro_quest_session_player_id_v2';

@JS('window.sessionStorage.getItem')
external String? _sessionGetItem(String key);

@JS('window.sessionStorage.setItem')
external void _sessionSetItem(String key, String value);

@JS('window.sessionStorage.removeItem')
external void _sessionRemoveItem(String key);

@JS('window.location.search')
external String get _locationSearch;

String? getSessionPlayerId() {
  try {
    final val = _sessionGetItem(_kSessionPlayerKey);
    if (val == null || val.isEmpty) return null;
    return val;
  } catch (_) {
    return null;
  }
}

void setSessionPlayerId(String playerId) {
  try {
    _sessionSetItem(_kSessionPlayerKey, playerId);
  } catch (_) {}
}

void clearSessionPlayerId() {
  try {
    _sessionRemoveItem(_kSessionPlayerKey);
  } catch (_) {}
}

String? getUrlPlayerId() {
  try {
    final search = _locationSearch;
    if (search.isEmpty) return null;
    final uri = Uri.parse('https://local/$search');
    final p = uri.queryParameters['player'];
    if (p != null && p.trim().isNotEmpty) {
      return p.trim();
    }
  } catch (_) {}
  return null;
}
