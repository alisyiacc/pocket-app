import 'package:flutter/foundation.dart';

/// Konfigurasi aplikasi Pocket.
///
/// Backend Laravel berjalan melalui:
/// php artisan serve --host=0.0.0.0 --port=8000
///
/// Android Emulator : http://10.0.2.2:8000/api
/// Chrome/Web        : http://127.0.0.1:8000/api
/// HP fisik          : gunakan IP LAN laptop melalui API_URL
///
/// Mode Mock:
/// flutter run --dart-define=USE_MOCK=true

class AppConfig {
  static const String appName = 'Pocket';

  /// true = menggunakan data mock tanpa backend.
  static const bool useMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: false);

  /// true = menampilkan kondisi akun baru tanpa teman/foto.
  static const bool mockEmpty =
      bool.fromEnvironment('MOCK_EMPTY', defaultValue: false);

  /// Alamat API dapat diganti menggunakan --dart-define=API_URL=...
  static String get baseUrl {
    const String env = String.fromEnvironment('API_URL');

    if (env.isNotEmpty) {
      return env;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.1.22/pocket-api/public/api';
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
