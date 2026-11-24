import 'package:flutter/services.dart';
import 'fullscreen_platform_stub.dart'
    if (dart.library.js_interop) 'fullscreen_platform_web.dart' as platform_fs;

class FullscreenUtil {
  static bool _isFullscreen = false;
  static bool get isFullscreen => _isFullscreen;

  static void toggle() {
    _isFullscreen = !_isFullscreen;
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    platform_fs.setWebFullscreen(_isFullscreen);
  }
}
