import 'dart:js_interop';

@JS('document.documentElement.requestFullscreen')
external void _requestFullscreen();

@JS('document.exitFullscreen')
external void _exitFullscreen();

@JS('document.fullscreenElement')
external JSAny? get _fullscreenElement;

void setWebFullscreen(bool enable) {
  try {
    if (enable) {
      if (_fullscreenElement == null) {
        _requestFullscreen();
      }
    } else {
      if (_fullscreenElement != null) {
        _exitFullscreen();
      }
    }
  } catch (_) {
    // Graceful fallback if browser permissions restrict fullscreen
  }
}
