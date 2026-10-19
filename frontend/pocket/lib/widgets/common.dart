import 'dart:io' show File;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/models.dart';

/// Latar gradasi gelap khas Locket (+ cahaya emas opsional).
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool glow;
  const AppBackground({super.key, required this.child, this.glow = false});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF222222), Color(0xFF0E0E0E)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (glow)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.2),
                    radius: 0.75,
                    colors: [kGold.withAlpha(48), Colors.transparent],
                  ),
                ),
              ),
            child,
          ],
        ),
      );
}

/// Bentuk squircle (superellipse) seperti viewfinder Locket.
class SquircleClipper extends CustomClipper<Path> {
  final double n;
  const SquircleClipper({this.n = 7});

  @override
  Path getClip(Size size) {
    final a = size.width / 2, b = size.height / 2;
    final path = Path();
    const steps = 160;
    for (var i = 0; i <= steps; i++) {
      final t = 2 * math.pi * i / steps;
      final c = math.cos(t), s = math.sin(t);
      final x = a + a * c.sign * math.pow(c.abs(), 2 / n).toDouble();
      final y = b + b * s.sign * math.pow(s.abs(), 2 / n).toDouble();
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant SquircleClipper old) => old.n != n;
}

class Squircle extends StatelessWidget {
  final Widget child;
  final double n;
  const Squircle({super.key, required this.child, this.n = 7});

  @override
  Widget build(BuildContext context) =>
      ClipPath(clipper: SquircleClipper(n: n), child: child);
}

class GlassCircle extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  const GlassCircle(
      {super.key, required this.child, this.onTap, this.size = 54, this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: color ?? kSurfaceHi.withAlpha(170)),
          child: child,
        ),
      );
}

/// Avatar kecil di pojok kanan atas (lingkaran abu-abu + inisial, seperti "su").
class HeaderAvatar extends StatelessWidget {
  final User? user;
  final VoidCallback? onTap;
  const HeaderAvatar({super.key, this.user, this.onTap});

  @override
  Widget build(BuildContext context) => GlassCircle(
        onTap: onTap,
        child: Text(user?.initials ?? '?',
            style: const TextStyle(
                color: Color(0xFFB0B0B5),
                fontSize: 18,
                fontWeight: FontWeight.w800)),
      );
}

class Avatar extends StatelessWidget {
  final User user;
  final double size;
  final bool ring;
  const Avatar(this.user, {super.key, this.size = 44, this.ring = false});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(ring ? 2 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: ring ? Border.all(color: kGold, width: 2.5) : null,
        ),
        child: ClipOval(
          child: Container(
            color: user.color,
            alignment: Alignment.center,
            child: Text(user.initials,
                style: TextStyle(
                    fontSize: size * 0.34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ),
      );
}

class PocketLogo extends StatelessWidget {
  final double size;
  const PocketLogo({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: kGold.withAlpha(90), blurRadius: size * 0.5)
          ],
        ),
        child: Squircle(
          child: Container(
            color: kGold,
            alignment: Alignment.center,
            child: Icon(Icons.favorite_rounded,
                size: size * 0.52, color: kGoldDeep),
          ),
        ),
      );
}

class GoldButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool glow;
  final bool loading;
  final double? width;
  const GoldButton(
      {super.key,
      required this.label,
      this.icon,
      this.onTap,
      this.glow = false,
      this.loading = false,
      this.width});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          height: 58,
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: onTap == null ? kGold.withAlpha(90) : kGold,
            borderRadius: BorderRadius.circular(40),
            boxShadow: glow
                ? [BoxShadow(color: kGold.withAlpha(70), blurRadius: 50, spreadRadius: 3)]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: kGoldDeep))
              else ...[
                if (icon != null) ...[
                  Icon(icon, color: kGoldDeep, size: 26),
                  const SizedBox(width: 8),
                ],
                Text(label,
                    style: const TextStyle(
                        color: kGoldDeep,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ],
            ],
          ),
        ),
      );
}

class Pill extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const Pill({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
              color: kSurfaceHi.withAlpha(150),
              borderRadius: BorderRadius.circular(30)),
          child: Center(widthFactor: 1, child: child),
        ),
      );
}

/// Tombol shutter: cincin emas + celah gelap + lingkaran putih.
class Shutter extends StatefulWidget {
  final VoidCallback onTap;
  final IconData? icon;
  final bool busy;
  const Shutter({super.key, required this.onTap, this.icon, this.busy = false});

  @override
  State<Shutter> createState() => _ShutterState();
}

class _ShutterState extends State<Shutter> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.9 : 1,
          duration: const Duration(milliseconds: 110),
          child: Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kGold, width: 5)),
            child: Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              child: widget.busy
                  ? const Padding(
                      padding: EdgeInsets.all(22),
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: kGold))
                  : (widget.icon == null
                      ? null
                      : Icon(widget.icon, color: kGoldDeep, size: 34)),
            ),
          ),
        ),
      );
}

class _PH {
  final List<Color> colors;
  final IconData icon;
  const _PH(this.colors, this.icon);
}

const _placeholders = [
  _PH([Color(0xFF8D5A3B), Color(0xFF3E2A1E)], Icons.local_cafe_rounded),
  _PH([Color(0xFF2E7D32), Color(0xFF0B3D14)], Icons.sports_soccer_rounded),
  _PH([Color(0xFF5E35B1), Color(0xFF1A0F3D)], Icons.nightlight_round),
  _PH([Color(0xFF1565C0), Color(0xFF0A2347)], Icons.laptop_mac_rounded),
  _PH([Color(0xFFFF7043), Color(0xFF6A1B4D)], Icons.wb_twilight_rounded),
  _PH([Color(0xFFEF6C00), Color(0xFF5D2A00)], Icons.ramen_dining_rounded),
  _PH([Color(0xFF455A64), Color(0xFF1C2A30)], Icons.water_drop_rounded),
  _PH([Color(0xFFAD1457), Color(0xFF3B0A27)], Icons.celebration_rounded),
];

/// Menampilkan foto dari: placeholder (mock), URL (server Laravel), atau file lokal.
class SnapImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  const SnapImage(this.path, {super.key, this.fit = BoxFit.cover});

  Widget _broken() => Container(
      color: kSurface,
      child: const Center(
          child: Icon(Icons.broken_image_rounded, color: kMuted, size: 40)));

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('placeholder:')) {
      final i = int.tryParse(path.substring(12)) ?? 0;
      final p = _placeholders[i % _placeholders.length];
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: p.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Center(
            child: Icon(p.icon, size: 90, color: Colors.white.withAlpha(150))),
      );
    }
    if (path.isEmpty) return _broken();
    if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
      return Image.network(path, fit: fit, errorBuilder: (_, __, ___) => _broken());
    }
    return Image.file(File(path), fit: fit, errorBuilder: (_, __, ___) => _broken());
  }
}

/// Bilah navigasi melayang di bawah (kalender - beranda - obrolan).
class NavPill extends StatelessWidget {
  final int index;
  final int unread;
  final ValueChanged<int> onTap;
  const NavPill(
      {super.key, required this.index, required this.onTap, this.unread = 0});

  Widget _item(int i, IconData icon) {
    final sel = i == index;
    return GestureDetector(
      onTap: () => onTap(i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 58,
        height: 44,
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF48484A) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon,
                size: 26,
                color: sel ? Colors.white : const Color(0xFF7C7C80)),
            if (i == 1 && index != 1)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 34,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kGold,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: kGold.withAlpha(150), blurRadius: 14)
                    ],
                  ),
                ),
              ),
            if (i == 2 && unread > 0)
              Positioned(
                top: 8,
                right: 14,
                child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        color: kGold, shape: BoxShape.circle)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E).withAlpha(240),
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: Colors.white.withAlpha(20)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(120), blurRadius: 24)
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(0, Icons.dialpad_rounded),
            _item(1, Icons.home_rounded),
            _item(2, Icons.chat_bubble_rounded),
          ],
        ),
      );
}

class EmptyState extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget? action;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      this.action});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 22),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEDEDED))),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, color: kMuted, height: 1.35)),
            if (action != null) ...[const SizedBox(height: 28), action!],
          ],
        ),
      );
}

/// Garis putus-putus melengkung antar kartu bulan.
class DashConnector extends StatelessWidget {
  final bool flip;
  const DashConnector({super.key, this.flip = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 54,
        width: 60,
        child: CustomPaint(painter: _DashPainter(flip)),
      );
}

class _DashPainter extends CustomPainter {
  final bool flip;
  _DashPainter(this.flip);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(flip ? w * 0.6 : w * 0.4, 0)
      ..cubicTo(flip ? w * 0.1 : w * 0.9, h * 0.3, flip ? w * 0.9 : w * 0.1,
          h * 0.7, flip ? w * 0.4 : w * 0.6, h);
    final paint = Paint()
      ..color = const Color(0xFF3A3A3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 6, m.length)), paint);
        d += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.flip != flip;
}
