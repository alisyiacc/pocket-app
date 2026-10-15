import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/web_camera.dart';
import '../../core/utils.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../friends/friends_screen.dart';
import '../lockets/snap_viewer_screen.dart';
import '../main_shell.dart';
import '../profile/profile_screen.dart';
import 'send_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  List<CameraDescription> _cams = [];
  CameraController? _ctrl;
  int _camIndex = 0;
  bool _busy = false;
  String? _error;
  FlashMode _flash = FlashMode.off;
  double _zoom = 1, _minZoom = 1, _maxZoom = 1;
  final _picker = ImagePicker();
  // Web: pakai getUserMedia langsung (lihat core/web_camera_web.dart)
  WebCamera? _web;
  bool _webReady = false;
  bool _webFront = true;
  String? _detail; // pesan teknis asli supaya gampang di-debug

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl?.dispose();
    _web?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;
    final c = _ctrl;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      c.dispose();
      _ctrl = null;
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  bool _initializing = false;

  void _fail(String msg, [Object? detail]) {
    if (detail != null) debugPrint('[Pocket kamera] $detail');
    if (mounted) {
      setState(() {
        _ctrl = null;
        _webReady = false;
        _error = msg;
        _detail = detail?.toString();
      });
    }
  }

  Future<void> _initWeb({bool? front}) async {
    if (_initializing) return;
    _initializing = true;
    try {
      final w = _web ??= WebCamera();
      await w.start(front: front ?? _webFront);
      if (!mounted) {
        await w.dispose();
        return;
      }
      setState(() {
        _webReady = true;
        _error = null;
        _detail = null;
      });
    } catch (e) {
      _fail(_explain('$e'), e);
    } finally {
      _initializing = false;
    }
  }

  String _explain(String code) {
    final c = code.toLowerCase();
    if (c.contains('denied') || c.contains('permission') || c.contains('notallowed')) {
      return 'Izin kamera ditolak. Izinkan kamera untuk Pocket di pengaturan, lalu tekan Coba lagi.';
    }
    if (c.contains('notreadable') || c.contains('inuse')) {
      return 'Kamera sedang dipakai aplikasi/tab lain atau diblokir sistem. Tutup yang lain lalu tekan Coba lagi.';
    }
    if (c.contains('notfound') || c.contains('devicesnotfound')) return 'Kamera tidak ditemukan di perangkat ini.';
    return 'Kamera tidak bisa dibuka ($code).';
  }

  /// Mencoba SEMUA kamera (di Windows kamera pertama kadang kamera IR yang tidak
  /// bisa dipakai) dan beberapa resolusi, sampai ada yang berhasil.
  Future<void> _initCamera() async {
    if (kIsWeb) return _initWeb();
    if (_initializing) return;
    _initializing = true;
    try {
      if (_cams.isEmpty) _cams = await availableCameras();
      if (_cams.isEmpty) {
        _fail('Kamera tidak ditemukan di perangkat ini. Pilih foto dari galeri.');
        return;
      }
      final presets = kIsWeb
          ? [ResolutionPreset.medium, ResolutionPreset.low]
          : [ResolutionPreset.high, ResolutionPreset.medium];
      String lastCode = 'unknown';
      for (var k = 0; k < _cams.length; k++) {
        final idx = (_camIndex + k) % _cams.length;
        for (final preset in presets) {
          final c = CameraController(_cams[idx], preset, enableAudio: false);
          try {
            await c.initialize();
            if (!mounted) {
              await c.dispose();
              return;
            }
            try {
              _minZoom = await c.getMinZoomLevel();
              _maxZoom = await c.getMaxZoomLevel();
            } catch (_) {
              _minZoom = 1;
              _maxZoom = 1;
            }
            _zoom = math.max(1.0, _minZoom);
            try {
              await c.setFlashMode(_flash);
            } catch (_) {}
            if (!mounted) {
              await c.dispose();
              return;
            }
            _camIndex = idx;
            setState(() {
              _ctrl = c;
              _error = null;
            });
            return;
          } on CameraException catch (e) {
            lastCode = e.code;
            try {
              await c.dispose();
            } catch (_) {}
            final l = e.code.toLowerCase();
            if (l.contains('denied') || l.contains('permission')) {
              _fail(_explain(e.code));
              return;
            }
          } catch (e) {
            lastCode = '$e';
            try {
              await c.dispose();
            } catch (_) {}
          }
        }
      }
      _fail(_explain(lastCode));
    } catch (e) {
      _fail(_explain('$e'), e);
    } finally {
      _initializing = false;
    }
  }

  Future<void> _retry() async {
    if (kIsWeb) {
      setState(() {
        _webReady = false;
        _error = null;
        _detail = null;
      });
      await _web?.dispose();
      _web = WebCamera();
      await _initWeb();
      return;
    }
    final old = _ctrl;
    setState(() {
      _ctrl = null;
      _error = null;
    });
    try {
      await old?.dispose();
    } catch (_) {}
    _cams = []; // pindai ulang daftar kamera
    await _initCamera();
  }

  Future<void> _flip() async {
    if (kIsWeb) {
      final w = _web;
      if (w == null || !_webReady) return;
      if (!w.canFlip) {
        toast(context, 'Hanya ada satu kamera');
        return;
      }
      setState(() => _webReady = false);
      final ok = await w.flip();
      if (!mounted) return;
      _webFront = w.isFront;
      setState(() => _webReady = true);
      if (!ok) toast(context, 'Tidak bisa ganti kamera');
      return;
    }
    if (_cams.length < 2) {
      toast(context, 'Hanya ada satu kamera');
      return;
    }
    final cur = _cams[_camIndex].lensDirection;
    final next = _cams.indexWhere((c) => c.lensDirection != cur);
    if (next < 0) return;
    final old = _ctrl;
    setState(() => _ctrl = null);
    await old?.dispose();
    _camIndex = next;
    await _initCamera();
  }

  Future<void> _cycleFlash() async {
    if (kIsWeb) {
      toast(context, 'Flash tidak tersedia di browser');
      return;
    }
    const modes = [FlashMode.off, FlashMode.auto, FlashMode.always];
    final next = modes[(modes.indexOf(_flash) + 1) % modes.length];
    try {
      await _ctrl?.setFlashMode(next);
      setState(() => _flash = next);
    } catch (_) {
      if (mounted) toast(context, 'Flash tidak didukung kamera ini');
    }
  }

  Future<void> _cycleZoom() async {
    if (kIsWeb) {
      toast(context, 'Zoom tidak tersedia di browser');
      return;
    }
    final levels = [1.0, 2.0, 3.0].where((z) => z <= _maxZoom).toList();
    if (levels.length < 2) {
      toast(context, 'Zoom tidak tersedia');
      return;
    }
    final i = levels.indexWhere((z) => (z - _zoom).abs() < 0.05);
    final next = levels[(i + 1) % levels.length];
    try {
      await _ctrl?.setZoomLevel(next);
      setState(() => _zoom = next);
    } catch (_) {}
  }

  Future<void> _capture() async {
    if (_busy) return;
    if (kIsWeb) {
      if (!_webReady || _web == null) {
        await _pickGallery();
        return;
      }
      setState(() => _busy = true);
      try {
        final path = await _web!.capture();
        if (!mounted) return;
        await _openSend(path);
      } catch (e) {
        if (mounted) toast(context, 'Gagal mengambil foto');
        debugPrint('[Pocket kamera] capture: $e');
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      return;
    }
    final c = _ctrl;
    if (c == null || !c.value.isInitialized) {
      await _pickGallery();
      return;
    }
    setState(() => _busy = true);
    try {
      final f = await c.takePicture();
      if (!mounted) return;
      await _openSend(f.path);
    } on CameraException catch (e) {
      if (mounted) toast(context, 'Gagal mengambil foto (${e.code})');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickGallery() async {
    try {
      final x = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600);
      if (x != null && mounted) await _openSend(x.path);
    } catch (_) {
      if (mounted) toast(context, 'Galeri tidak bisa dibuka');
    }
  }

  Future<void> _openSend(String path) async {
    final sent = await Navigator.push<int>(
        context, MaterialPageRoute(builder: (_) => SendScreen(imagePath: path)));
    if (sent != null && mounted) toast(context, 'Terkirim ke $sent teman 💛');
  }

  void _openHistory() {
    final all = context.read<SnapsProvider>().all;
    openViewer(context, all, 0);
  }

  IconData get _flashIcon => _flash == FlashMode.off
      ? Icons.flash_off_rounded
      : (_flash == FlashMode.auto
          ? Icons.flash_auto_rounded
          : Icons.flash_on_rounded);

  String get _zoomLabel => _zoom == _zoom.roundToDouble()
      ? '${_zoom.toInt()}'
      : _zoom.toStringAsFixed(1);

  Widget _fallback() => Container(
        color: const Color(0xFF2A2A2C),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: _error == null
            ? const CircularProgressIndicator(color: kGold)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.no_photography_rounded,
                      size: 56, color: Colors.white24),
                  const SizedBox(height: 12),
                  Text(_error ?? 'Menyiapkan kamera...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54)),
                  if (_detail != null) ...[
                    const SizedBox(height: 6),
                    Text(_detail!,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white24, fontSize: 11)),
                  ],
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: const Text('Coba lagi',
                        style: TextStyle(color: Colors.white)),
                  ),
                  TextButton.icon(
                    onPressed: _pickGallery,
                    icon: const Icon(Icons.photo_library_rounded, color: kGold),
                    label: const Text('Pilih dari galeri',
                        style: TextStyle(color: kGold)),
                  ),
                ],
              ),
      );

  Widget _viewfinder(double size) {
    final c = _ctrl;
    Widget content = _fallback();
    if (kIsWeb) {
      if (_webReady && _web != null) content = SizedBox.expand(child: _web!.buildView());
    } else if (c != null && c.value.isInitialized && c.value.previewSize != null) {
      final ps = c.value.previewSize!;
      content = FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
            width: ps.height, height: ps.width, child: CameraPreview(c)),
      );
    }
    final chip = Colors.white.withAlpha(70);
    return GestureDetector(
      onDoubleTap: _flip,
      child: SizedBox(
        width: size,
        height: size,
        child: Squircle(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: const Color(0xFF2A2A2C)),
              content,
              Positioned(
                top: 24,
                left: 24,
                child: GlassCircle(
                    size: 42,
                    color: chip,
                    onTap: _cycleFlash,
                    child: Icon(_flashIcon, size: 22, color: Colors.white)),
              ),
              Positioned(
                top: 24,
                right: 24,
                child: GlassCircle(
                    size: 42,
                    color: chip,
                    onTap: _cycleZoom,
                    child: Text('${_zoomLabel}x',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb(String? path) => GestureDetector(
        onTap: _pickGallery,
        child: SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: -0.2,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: kSurfaceHi,
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: path == null
                      ? Container(
                          color: kSurface,
                          child: const Icon(Icons.photo_library_rounded,
                              color: Colors.white70, size: 24))
                      : SnapImage(path),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final friends = context.watch<FriendsProvider>().friends;
    final me = context.watch<AuthProvider>().user;
    final lastPhoto = context.select<SnapsProvider, String?>((p) => p.lastPhotoPath);

    return AppBackground(
      child: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) < -300) _openHistory();
          },
          child: LayoutBuilder(builder: (context, cons) {
            final w = cons.maxWidth;
            final size =
                math.min(w, cons.maxHeight - 54 - 24 - 150 - 104).clamp(220.0, w).toDouble();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Row(
                    children: [
                      GlassCircle(
                        onTap: () => MainShell.goTo(0, locketsTabIndex: 0),
                        child: const Icon(Icons.campaign_rounded,
                            color: Colors.white, size: 26),
                      ),
                      Expanded(
                        child: Center(
                          child: Pill(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => FriendsScreen(
                                        initialTab: friends.isEmpty ? 2 : 0))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people_alt_rounded,
                                    size: 24, color: Colors.white),
                                const SizedBox(width: 10),
                                Text(
                                    friends.isEmpty
                                        ? 'Tambahkan Teman'
                                        : '${friends.length} Teman',
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      HeaderAvatar(
                        user: me,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _viewfinder(size),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _thumb(lastPhoto),
                          Shutter(onTap: _capture, busy: _busy),
                          GestureDetector(
                            onTap: _flip,
                            behavior: HitTestBehavior.opaque,
                            child: const SizedBox(
                              width: 60,
                              height: 60,
                              child: Icon(Icons.sync_rounded,
                                  size: 40, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _openHistory,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 38,
                              decoration: BoxDecoration(
                                  color: kSurfaceHi.withAlpha(170),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.collections_rounded,
                                  size: 22, color: Colors.white),
                            ),
                            const SizedBox(width: 14),
                            const Text('Riwayat',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(width: 10),
                            const Icon(Icons.expand_more_rounded,
                                size: 28, color: kMuted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 104),
              ],
            );
          }),
        ),
      ),
    );
  }
}
