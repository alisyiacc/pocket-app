import 'package:flutter/foundation.dart';

/// Konfigurasi aplikasi.
///
/// Default  : terhubung ke Laravel + MySQL (Laragon)  ->  flutter run
///            (opsional) --dart-define=API_URL=http://192.168.1.10/pocket-api/public/api
/// Mode Mock: flutter run --dart-define=USE_MOCK=true  (tanpa backend, hanya cek UI)
class AppConfig {
  static const appName = 'Pocket';
  static const bool useMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: false);

  /// true = akun baru tanpa teman/foto (menampilkan empty state seperti Locket asli)
  static const bool mockEmpty =
      bool.fromEnvironment('MOCK_EMPTY', defaultValue: false);

  /// Android Emulator -> 10.0.2.2 (= laptop/Laragon). iOS Simulator & Web -> 127.0.0.1.
  /// HP fisik: isi API_URL dengan IP LAN laptop.
  static String get baseUrl {
    const env = String.fromEnvironment('API_URL');
    if (env.isNotEmpty) return env;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/pocket-api/public/api';
    }
    return 'http://127.0.0.1/pocket-api/public/api';
  }

  static const String inviteHost = 'pocket.app';
}

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}
