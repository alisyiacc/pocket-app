import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../repositories/repositories.dart';
import '../../widgets/common.dart';
import '../main_shell.dart';
import '../profile/profile_screen.dart';
import 'snap_viewer_screen.dart';

class LocketsScreen extends StatelessWidget {
  const LocketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;
    return AppBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 66,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const SizedBox(width: 54),
                    const Expanded(
                      child: Center(
                        child: FittedBox(
                            fit: BoxFit.scaleDown, child: _Segmented()),
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
            ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: MainShell.locketsTab,
                builder: (_, tab, __) =>
                    tab == 0 ? const _RollcallsView() : const _LocketsView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented();

  Widget _seg(String label, IconData icon, int i, int cur) {
    final sel = i == cur;
    return GestureDetector(
      onTap: () => MainShell.locketsTab.value = i,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: sel ? kSurfaceHi : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: sel ? Colors.white : kMuted),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: sel ? Colors.white : kMuted)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: MainShell.locketsTab,
        builder: (_, cur, __) => Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(32)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _seg('Rollcalls', Icons.campaign_rounded, 0, cur),
              _seg('Pockets', Icons.image_rounded, 1, cur),
            ],
          ),
        ),
      );
}

// ---------------------------------------------------------------- LOCKETS
class _LocketsView extends StatelessWidget {
  const _LocketsView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SnapsProvider>();
    final all = p.all;
    final now = DateTime.now();

    // Bulan yang ditampilkan: bulan ini sampai bulan Locket tertua (maks 12).
    var oldest = DateTime(now.year, now.month);
    for (final s in all) {
      final m = DateTime(s.createdAt.year, s.createdAt.month);
      if (m.isBefore(oldest)) oldest = m;
    }
    final months = <DateTime>[];
    var m = DateTime(now.year, now.month);
    while (!m.isBefore(oldest) && months.length < 12) {
      months.add(m);
      m = DateTime(m.year, m.month - 1);
    }

    return RefreshIndicator(
      color: kGold,
      backgroundColor: kSurface,
      onRefresh: () => p.load(p.meId),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 130),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (all.isEmpty) ...[
            const Opacity(
              opacity: 0.55,
              child: Column(
                children: [
                  Icon(Icons.near_me_outlined, size: 48, color: kMuted),
                  SizedBox(height: 14),
                  Text('Kirim Pocket pertamamu!',
                      style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: kMuted)),
                ],
              ),
            ),
            const Center(child: DashConnector()),
            const _PreviewCard(),
            const Center(child: DashConnector(flip: true)),
          ],
          for (var i = 0; i < months.length; i++) ...[
            _MonthCard(month: months[i], snaps: all),
            if (i != months.length - 1)
              Center(child: DashConnector(flip: i.isEven)),
          ],
        ],
      ),
    );
  }
}

/// Kartu dekoratif (ikon-ikon redup) saat belum ada Locket.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  static const _icons = <int, IconData>{
    8: Icons.waves_rounded, 11: Icons.self_improvement_rounded,
    12: Icons.emoji_emotions_rounded, 15: Icons.brightness_7_rounded,
    17: Icons.local_library_rounded, 22: Icons.cloud_rounded,
    24: Icons.wb_sunny_outlined, 25: Icons.beach_access_rounded,
    26: Icons.home_rounded, 27: Icons.directions_walk_rounded,
    33: Icons.nightlight_round,
  };

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: 0.5,
        child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFF1F1F20),
              borderRadius: BorderRadius.circular(34)),
          child: Column(
            children: [
              Container(
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2A2B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    for (var i = 0; i < 35; i++)
                      _icons.containsKey(i)
                          ? Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xFF3A3A3C),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Icon(_icons[i], color: kMuted, size: 22),
                            )
                          : Center(
                              child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF3A3A3C),
                                      shape: BoxShape.circle))),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _MonthCard extends StatelessWidget {
  final DateTime month;
  final List<Snap> snaps;
  const _MonthCard({required this.month, required this.snaps});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = DateTime(month.year, month.month + 1, 0).day;
    final offset = DateTime(month.year, month.month, 1).weekday % 7; // Minggu = 0
    final isCurrent = month.year == now.year && month.month == now.month;

    final byDay = <int, List<Snap>>{};
    for (final s in snaps) {
      if (s.createdAt.year == month.year && s.createdAt.month == month.month) {
        byDay.putIfAbsent(s.createdAt.day, () => []).add(s);
      }
    }

    final cells = <Widget>[
      for (var i = 0; i < offset; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++) _cell(context, d, byDay[d], isCurrent, now),
    ];

    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF1F1F20),
          borderRadius: BorderRadius.circular(34)),
      child: Column(
        children: [
          Container(
            height: 52,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            ),
            child: Text('${monthName(month.month)} ${month.year}',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: cells,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, int day, List<Snap>? list, bool isCurrent,
      DateTime now) {
    if (list != null && list.isNotEmpty) {
      final latest = list.first; // sudah terurut terbaru -> lama
      return GestureDetector(
        onTap: () {
          final idx = snaps.indexWhere((s) => s.id == latest.id);
          openViewer(context, snaps, idx < 0 ? 0 : idx);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SnapImage(latest.imageUrl),
              if (list.length > 1)
                Positioned(
                  right: 3,
                  bottom: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                        color: Colors.black.withAlpha(150),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('${list.length}',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    final future = isCurrent && day > now.day;
    if (future) {
      return Container(
          decoration: BoxDecoration(
              color: const Color(0xFF2A2A2B),
              borderRadius: BorderRadius.circular(12)));
    }
    return Center(
        child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
                color: Color(0xFF3A3A3C), shape: BoxShape.circle)));
  }
}

// -------------------------------------------------------------- ROLLCALLS
class _RollcallsView extends StatefulWidget {
  const _RollcallsView();

  @override
  State<_RollcallsView> createState() => _RollcallsViewState();
}

class _RollcallsViewState extends State<_RollcallsView> {
  final _repo = RollcallRepository();
  List<Rollcall> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _items = await _repo.list();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _create() async {
    final c = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Rollcall baru'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Contoh: Kumpul akhir pekan'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, c.text.trim()),
              child: const Text('Buat', style: TextStyle(color: kGold))),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;
    try {
      final r = await _repo.create(title);
      if (mounted) setState(() => _items.insert(0, r));
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: kGold));
    }
    if (_items.isEmpty) {
      return Center(
        child: EmptyState(
          icon: const Icon(Icons.campaign_rounded, size: 64, color: kMuted),
          title: 'Belum ada Rollcall',
          subtitle:
              'Rollcall adalah kumpulan foto bersama temanmu dalam satu tema.',
          action: GoldButton(
              label: 'Buat Rollcall', icon: Icons.add_rounded, onTap: _create, glow: true),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GoldButton(label: 'Buat Rollcall', icon: Icons.add_rounded, onTap: _create),
        ),
        const SizedBox(height: 16),
        for (final r in _items)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: const Color(0xFF1F1F20),
                borderRadius: BorderRadius.circular(28)),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: kGold.withAlpha(40),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.campaign_rounded, color: kGold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text('oleh ${r.createdBy} • ${timeAgo(r.createdAt)}',
                          style: const TextStyle(color: kMuted, fontSize: 13)),
                    ],
                  ),
                ),
                Text('${r.photoCount} foto',
                    style: const TextStyle(color: kMuted)),
              ],
            ),
          ),
      ],
    );
  }
}
