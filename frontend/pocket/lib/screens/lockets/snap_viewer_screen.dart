import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

/// Buka penampil foto (slide dari bawah, seperti "Riwayat" di Locket).
void openViewer(BuildContext context, List<Snap> snaps, int index) {
  Navigator.of(context).push(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) =>
        SnapViewerScreen(snaps: snaps, initialIndex: index),
    transitionsBuilder: (_, a, __, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ));
}

class SnapViewerScreen extends StatefulWidget {
  final List<Snap> snaps;
  final int initialIndex;
  const SnapViewerScreen(
      {super.key, required this.snaps, this.initialIndex = 0});

  @override
  State<SnapViewerScreen> createState() => _SnapViewerScreenState();
}

class _SnapViewerScreenState extends State<SnapViewerScreen> {
  late List<Snap> _list = List.of(widget.snaps);
  late final PageController _pc = PageController(initialPage: widget.initialIndex);
  late int _page = widget.initialIndex;
  String _filter = 'Semua teman';
  final _msg = TextEditingController();

  @override
  void dispose() {
    _pc.dispose();
    _msg.dispose();
    super.dispose();
  }

  Snap? get _current =>
      (_list.isEmpty || _page >= _list.length) ? null : _list[_page];

  Future<void> _pickFilter() async {
    final snaps = context.read<SnapsProvider>();
    final friends = context.read<FriendsProvider>().friends;
    final choice = await showModalBottomSheet<(String, int?)>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          children: [
            const Text('Tampilkan dari',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.people_alt_rounded, color: kGold),
              title: const Text('Semua teman'),
              onTap: () => Navigator.pop(context, ('Semua teman', null)),
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded, color: kGold),
              title: const Text('Pocket saya'),
              onTap: () => Navigator.pop(context, ('Pocket saya', -1)),
            ),
            for (final f in friends)
              ListTile(
                leading: Avatar(f, size: 38),
                title: Text(f.name),
                onTap: () => Navigator.pop(context, (f.name, f.id)),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    setState(() {
      _filter = choice.$1;
      final id = choice.$2;
      _list = snaps.all.where((s) {
        if (id == null) return true;
        if (id == -1) return s.sender.id == snaps.meId;
        return s.sender.id == id;
      }).toList();
      _page = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pc.hasClients) _pc.jumpToPage(0);
    });
  }

  Future<void> _react(Snap s, String emoji) async {
    try {
      await context.read<SnapsProvider>().react(s, emoji);
      if (mounted) toast(context, 'Reaksi $emoji terkirim');
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
    }
  }

  Future<void> _reply(Snap s) async {
    final text = _msg.text.trim();
    if (text.isEmpty) return;
    try {
      await context.read<ChatProvider>().send(s.sender.id, text, snapId: s.id);
      _msg.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
        toast(context, 'Balasan terkirim ke ${s.sender.name}');
      }
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
    }
  }

  Future<void> _delete(Snap s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Hapus Pocket?'),
        content: const Text('Foto ini akan hilang dari widget teman-temanmu.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: kDanger))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<SnapsProvider>().remove(s);
      setState(() {
        _list.removeWhere((e) => e.id == s.id);
        if (_page >= _list.length) _page = _list.isEmpty ? 0 : _list.length - 1;
      });
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
    }
  }

  Widget _page_(Snap s, int meId) {
    final mine = s.sender.id == meId;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LayoutBuilder(builder: (context, c) {
          return SizedBox(
            width: c.maxWidth,
            height: c.maxWidth,
            child: Squircle(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SnapImage(s.imageUrl),
                  if (s.caption.isNotEmpty)
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.black.withAlpha(110),
                              borderRadius: BorderRadius.circular(24)),
                          child: Text(s.caption,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Avatar(s.sender, size: 32, ring: true),
            const SizedBox(width: 10),
            Text(mine ? 'Kamu' : s.sender.name,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(width: 10),
            Text(timeAgo(s.createdAt), style: const TextStyle(color: kMuted)),
          ],
        ),
        if (s.reactions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(s.reactions.map((r) => r.emoji).join(' '),
              style: const TextStyle(fontSize: 22)),
        ],
        if (mine) ...[
          const SizedBox(height: 6),
          Text('Dikirim ke ${s.recipientIds.length} teman',
              style: const TextStyle(color: kMuted, fontSize: 13)),
        ],
      ],
    );
  }

  Widget _replyBar(Snap s, int meId) {
    if (s.sender.id == meId) return const SizedBox(height: 8);
    final mineReact = s.reactions
        .where((r) => r.userId == meId)
        .map((r) => r.emoji)
        .toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 10),
        decoration: BoxDecoration(
            color: kSurface, borderRadius: BorderRadius.circular(32)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msg,
                onSubmitted: (_) => _reply(s),
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                    hintText: 'Kirim pesan...',
                    hintStyle: TextStyle(color: kMuted),
                    border: InputBorder.none),
              ),
            ),
            for (final e in ['💛', '🔥', '😂'])
              GestureDetector(
                onTap: () => _react(s, e),
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mineReact.contains(e)
                        ? kGold.withAlpha(60)
                        : Colors.transparent,
                  ),
                  child: Text(e, style: const TextStyle(fontSize: 24)),
                ),
              ),
            IconButton(
                onPressed: () => _reply(s),
                icon: const Icon(Icons.send_rounded, color: kGold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meId = context.read<SnapsProvider>().meId;
    final cur = _current;
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Center(
                        child: Pill(
                          onTap: _pickFilter,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_filter,
                                  style: const TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.w800)),
                              const SizedBox(width: 4),
                              const Icon(Icons.expand_more_rounded, size: 22),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: (cur != null && cur.sender.id == meId)
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz_rounded),
                              color: const Color(0xFF2C2C2E),
                              onSelected: (_) => _delete(cur),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'hapus',
                                    child: Text('Hapus Pocket',
                                        style: TextStyle(color: kDanger))),
                              ],
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _list.isEmpty
                    ? const Center(
                        child: EmptyState(
                          icon: Icon(Icons.photo_library_outlined,
                              size: 64, color: kMuted),
                          title: 'Belum ada Pocket',
                          subtitle: 'Foto dari temanmu akan muncul di sini.',
                        ),
                      )
                    : PageView.builder(
                        controller: _pc,
                        scrollDirection: Axis.vertical,
                        itemCount: _list.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (_, i) => _page_(_list[i], meId),
                      ),
              ),
              if (cur != null) _replyBar(cur, meId),
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.expand_more_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
