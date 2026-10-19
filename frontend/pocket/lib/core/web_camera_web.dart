import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

int _seq = 0;

/// Kamera web langsung lewat getUserMedia (tanpa availableCameras milik plugin
/// `camera`, yang gagal total kalau SATU perangkat kamera bermasalah).
class WebCamera {
  web.HTMLVideoElement? _video;
  web.MediaStream? _stream;
  String? _viewType;
  bool _front = true;
  String? _curId;
  List<String> _deviceIds = [];

  bool get isFront => _front;
  bool get canFlip => _deviceIds.length > 1;

  Widget buildView() {
    final t = _viewType;
    if (t == null) return const SizedBox.shrink();
    return HtmlElementView(key: ValueKey(t), viewType: t);
  }

  static bool isDenied(Object? e) {
    final s = '$e'.toLowerCase();
    return s.contains('notallowed') ||
        s.contains('permission') ||
        s.contains('denied');
  }

  Future<web.MediaStream> _getStream(Object video) {
    final constraints =
        web.MediaStreamConstraints(video: video.jsify()!, audio: false.toJS);
    return web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
  }

  Future<void> _scanDevices() async {
    final arr =
        await web.window.navigator.mediaDevices.enumerateDevices().toDart;
    _deviceIds = [
      for (final d in arr.toDart)
        if (d.kind == 'videoinput' && d.deviceId.isNotEmpty) d.deviceId
    ];
  }

  Future<void> _attach(web.MediaStream stream, {required bool prefer}) async {
    try {
      final video = web.document.createElement('video') as web.HTMLVideoElement;
      video.autoplay = true;
      video.muted = true;
      video.setAttribute('playsinline', 'true');
      video.setAttribute('muted', 'true');
      video.style.setProperty('width', '100%');
      video.style.setProperty('height', '100%');
      video.style.setProperty('object-fit', 'cover');
      video.style.setProperty('background', '#2A2A2C');

      var front = prefer;
      String? id;
      final tracks = stream.getVideoTracks().toDart;
      if (tracks.isNotEmpty) {
        final st = tracks.first.getSettings();
        final fm = st.getProperty<JSAny?>('facingMode'.toJS).dartify();
        id = st.getProperty<JSAny?>('deviceId'.toJS).dartify() as String?;
        if (fm == 'environment') {
          front = false;
        } else if (fm == 'user') {
          front = true;
        }
      }
      video.style.setProperty('transform', front ? 'scaleX(-1)' : 'none');
      video.srcObject = stream;

      final viewType = 'pocket-camera-${_seq++}';
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) => video);

      _video = video;
      _stream = stream;
      _viewType = viewType;
      _front = front;
      _curId = id;
      try {
        await video.play().toDart;
      } catch (_) {/* autoplay muted biasanya jalan sendiri */}
    } catch (e) {
      _stopStream(stream);
      rethrow;
    }
  }

  void _stopStream(web.MediaStream? s) {
    if (s == null) return;
    for (final t in s.getTracks().toDart) {
      t.stop();
    }
  }

  Future<void> _stop() async {
    _stopStream(_stream);
    _stream = null;
    final v = _video;
    if (v != null) {
      v.srcObject = null;
      v.remove();
    }
    _video = null;
    _viewType = null;
  }

  /// Buka kamera. Mencoba beberapa constraint, lalu tiap perangkat satu-satu
  /// (supaya kamera IR / virtual yang rusak dilewati).
  Future<void> start({bool front = true}) async {
    await _stop();
    final facing = front ? 'user' : 'environment';
    final attempts = <Object>[
      {
        'facingMode': {'ideal': facing},
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
      },
      {
        'facingMode': {'ideal': facing}
      },
      true,
    ];
    Object? lastErr;
    for (final a in attempts) {
      try {
        final s = await _getStream(a);
        await _attach(s, prefer: front);
        try {
          await _scanDevices();
        } catch (_) {}
        return;
      } catch (e) {
        lastErr = e;
        if (isDenied(e)) throw e;
      }
    }
    try {
      await _scanDevices();
    } catch (_) {}
    for (final id in _deviceIds) {
      try {
        final s = await _getStream({
          'deviceId': {'exact': id}
        });
        await _attach(s, prefer: front);
        return;
      } catch (e) {
        lastErr = e;
      }
    }
    throw lastErr ?? StateError('Kamera tidak bisa dibuka');
  }

  /// Ganti depan <-> belakang. false = tidak ada kamera lain.
  Future<bool> flip() async {
    if (_deviceIds.length < 2) return false;
    final oldFront = _front;
    final target = !_front;
    await _stop();
    try {
      final s = await _getStream({
        'facingMode': {'exact': target ? 'user' : 'environment'}
      });
      await _attach(s, prefer: target);
      return true;
    } catch (_) {}
    final cur = _deviceIds.indexOf(_curId ?? '');
    for (var k = 1; k < _deviceIds.length; k++) {
      final id = _deviceIds[(cur + k) % _deviceIds.length];
      try {
        final s = await _getStream({
          'deviceId': {'exact': id}
        });
        await _attach(s, prefer: target);
        return true;
      } catch (_) {}
    }
    try {
      await start(front: oldFront);
    } catch (_) {}
    return false;
  }

  /// Ambil foto persegi (crop tengah, sama seperti preview) -> blob URL.
  Future<String> capture() async {
    final v = _video;
    if (v == null || v.videoWidth == 0 || v.videoHeight == 0) {
      throw StateError('Kamera belum siap');
    }
    final vw = v.videoWidth, vh = v.videoHeight;
    final s = vw < vh ? vw : vh;
    final out = s > 1080 ? 1080 : s;
    final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
    canvas.width = out;
    canvas.height = out;
    final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
    if (_front) {
      ctx.translate(out, 0);
      ctx.scale(-1, 1);
    }
    ctx.drawImage(v, (vw - s) / 2, (vh - s) / 2, s, s, 0, 0, out, out);
    final done = Completer<JSObject?>();
    final cb = ((JSObject? b) {
      if (!done.isCompleted) done.complete(b);
    }).toJS;
    canvas.toBlob(cb, 'image/jpeg');
    final blob = await done.future;
    if (blob == null) throw StateError('Gagal membuat foto');
    return web.URL.createObjectURL(blob);
  }

  Future<void> dispose() => _stop();
}
