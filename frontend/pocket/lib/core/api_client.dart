import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' show XFile;
import 'config.dart';
import 'mock_backend.dart';

/// Laravel Resource kadang membungkus data dalam {"data": ...}.
/// Dua helper ini menerima kedua bentuk (dibungkus / tidak).
List listOf(dynamic r) =>
    (r is Map && r['data'] is List) ? r['data'] as List : (r as List);
Map<String, dynamic> mapOf(dynamic r) =>
    ((r is Map && r['data'] is Map) ? r['data'] : r) as Map<String, dynamic>;

/// Satu-satunya pintu keluar ke server. Mode mock -> MockBackend,
/// mode Laravel -> HTTP sungguhan (Bearer token Sanctum).
/// Tidak memakai dart:io, jadi aman untuk Android, iOS, dan Web.
class ApiClient {
  ApiClient._();
  static final ApiClient I = ApiClient._();

  String? token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _send('POST', path, body: body);
  Future<dynamic> put(String path, [Map<String, dynamic>? body]) =>
      _send('PUT', path, body: body);
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path,
      {Map<String, String>? query, Map<String, dynamic>? body}) {
    if (AppConfig.useMock) {
      return MockBackend.I.handle(method, path, query: query, body: body);
    }
    return _guard(() async {
      final uri = Uri.parse('${AppConfig.baseUrl}$path')
          .replace(queryParameters: query);
      final enc = jsonEncode(body ?? {});
      late http.Response res;
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: _headers);
          break;
        case 'POST':
          res = await http.post(uri, headers: _headers, body: enc);
          break;
        case 'PUT':
          res = await http.put(uri, headers: _headers, body: enc);
          break;
        default:
          res = await http.delete(uri, headers: _headers);
      }
      return _decode(res);
    });
  }

  /// multipart/form-data untuk upload foto (POST /snaps).
  Future<dynamic> upload(String path,
      {required Map<String, String> fields,
      required String fileField,
      required String filePath}) {
    if (AppConfig.useMock) {
      return MockBackend.I.upload(path, fields, filePath);
    }
    return _guard(() async {
      final req = http.MultipartRequest(
          'POST', Uri.parse('${AppConfig.baseUrl}$path'));
      req.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      req.fields.addAll(fields);
      final bytes = await XFile(filePath).readAsBytes();
      req.files.add(
          http.MultipartFile.fromBytes(fileField, bytes, filename: 'photo.jpg'));
      final streamed = await req.send();
      return _decode(await http.Response.fromStream(streamed));
    });
  }

  Future<dynamic> _guard(Future<dynamic> Function() f) async {
    try {
      return await f().timeout(const Duration(seconds: 70));
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Server tidak merespons (timeout).');
    } on http.ClientException catch (e) {
      debugPrint('[Pocket API] gagal konek ke ${AppConfig.baseUrl}: $e');
      throw ApiException(
          'Tidak bisa terhubung ke server (${AppConfig.baseUrl}). '
          'Pastikan Laragon sudah Start All & alamat API benar.');
    } catch (e) {
      debugPrint('[Pocket API] error: $e');
      throw ApiException('Respons server tidak bisa diproses. Coba lagi.');
    }
  }

  dynamic _decode(http.Response res) {
    dynamic data;
    if (res.body.isNotEmpty) {
      try {
        data = jsonDecode(res.body);
      } catch (_) {
        data = null;
      }
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    String msg = 'Terjadi kesalahan (${res.statusCode})';
    if (data is Map) {
      if (data['errors'] is Map && (data['errors'] as Map).isNotEmpty) {
        final first = (data['errors'] as Map).values.first;
        msg = first is List && first.isNotEmpty ? '${first.first}' : '$first';
      } else if (data['message'] != null) {
        msg = '${data['message']}';
      }
    }
    throw ApiException(msg, res.statusCode);
  }
}
