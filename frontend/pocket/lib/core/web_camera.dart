// Kamera khusus web. Di Android/iOS tidak dipakai (pakai paket `camera`).
export 'web_camera_stub.dart' if (dart.library.js_interop) 'web_camera_web.dart';
