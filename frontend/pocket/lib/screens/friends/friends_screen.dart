import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../chat/chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  final int initialTab; // 0 Teman, 1 Permintaan, 2 Tambah
  const FriendsScreen({super.key, this.initialTab = 0});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(
      length: 3, vsync: this, initialIndex: widget.initialTab.clamp(0, 2).toInt());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<FriendsProvider>().load());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FriendsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Teman')),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: kSurface, borderRadius: BorderRadius.circular(30)),
                child: TabBar(
                  controller: _tab,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                      color: kSurfaceHi, borderRadius: BorderRadius.circular(26)),
                  labelColor: Colors.white,
                  unselectedLabelColor: kMuted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                  tabs: [
                    Tab(text: 'Teman (${p.friends.length})'),
                    Tab(
                        text: p.requests.isEmpty
                            ? 'Permintaan'
                            : 'Permintaan (${p.requests.length})'),
                    const Tab(text: 'Tambah'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _FriendList(p: p),
                    _RequestList(p: p),
                    const _AddFriendTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendList extends StatelessWidget {
  final FriendsProvider p;
  const _FriendList({required this.p});

  @override
  Widget build(BuildContext context) {
    if (p.friends.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icon(Icons.people_outline_rounded, size: 64, color: kMuted),
          title: 'Belum ada teman',
          subtitle: 'Buka tab Tambah untuk mencari temanmu lewat username.',
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        for (final f in p.friends)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Avatar(f, size: 50, ring: true),
            title: Text(f.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            subtitle:
                Text('@${f.username}', style: const TextStyle(color: kMuted)),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ChatScreen(friend: f))),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, color: kMuted),
              color: const Color(0xFF2C2C2E),
              onSelected: (_) async {
                try {
                  await p.remove(f);
                  if (context.mounted) toast(context, '${f.name} dihapus dari teman');
                } on ApiException catch (e) {
                  if (context.mounted) toast(context, e.message);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'hapus',
                    child: Text('Hapus teman', style: TextStyle(color: kDanger))),
              ],
            ),
          ),
      ],
    );
  }
}

class _RequestList extends StatelessWidget {
  final FriendsProvider p;
  const _RequestList({required this.p});

  @override
  Widget build(BuildContext context) {
    if (p.requests.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icon(Icons.mark_email_unread_outlined, size: 64, color: kMuted),
          title: 'Tidak ada permintaan',
          subtitle: 'Permintaan pertemanan yang masuk akan muncul di sini.',
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        for (final u in p.requests)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Avatar(u, size: 50),
            title: Text(u.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            subtitle:
                Text('@${u.username}', style: const TextStyle(color: kMuted)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(Icons.close_rounded, color: kMuted),
                    onPressed: () => p.decline(u)),
                GestureDetector(
                  onTap: () async {
                    await p.accept(u);
                    if (context.mounted) toast(context, 'Sekarang kamu berteman dengan ${u.name} 💛');
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                        color: kGold, borderRadius: BorderRadius.circular(22)),
                    child: const Text('Terima',
                        style: TextStyle(
                            color: kGoldDeep, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AddFriendTab extends StatefulWidget {
  const _AddFriendTab();

  @override
  State<_AddFriendTab> createState() => _AddFriendTabState();
}

class _AddFriendTabState extends State<_AddFriendTab> {
  final _q = TextEditingController();
  Timer? _debounce;
  List<User>? _results; // null = tampilkan saran
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    if (v.trim().isEmpty) {
      setState(() => _results = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), _search);
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    try {
      final r = await context.read<FriendsProvider>().search(_q.text.trim());
      if (mounted) setState(() => _results = r);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _act(User u) async {
    final p = context.read<FriendsProvider>();
    try {
      if (u.relation == 'pending_in') {
        await p.accept(u);
      } else if (u.relation == 'none') {
        await p.sendRequest(u);
        if (mounted) toast(context, 'Permintaan dikirim ke ${u.name}');
      }
      if (_results != null) await _search();
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
    }
  }

  Widget _action(User u) {
    String label;
    bool active = true;
    switch (u.relation) {
      case 'friend':
        label = 'Berteman';
        active = false;
        break;
      case 'pending_out':
        label = 'Menunggu';
        active = false;
        break;
      case 'pending_in':
        label = 'Terima';
        break;
      default:
        label = 'Tambah';
    }
    return GestureDetector(
      onTap: active ? () => _act(u) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
            color: active ? kGold : kSurfaceHi,
            borderRadius: BorderRadius.circular(22)),
        child: Text(label,
            style: TextStyle(
                color: active ? kGoldDeep : kMuted, fontWeight: FontWeight.w800)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FriendsProvider>();
    final me = context.watch<AuthProvider>().user;
    final list = _results ?? p.suggestions;
    final link = 'https://${AppConfig.inviteHost}/u/${me?.username ?? ''}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        TextField(
          controller: _q,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Cari nama atau username',
            hintStyle: const TextStyle(color: kMuted),
            prefixIcon: const Icon(Icons.search_rounded, color: kMuted),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kGold)))
                : null,
            filled: true,
            fillColor: kSurface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: link));
            if (context.mounted) toast(context, 'Tautan undangan disalin');
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: kGold.withAlpha(34),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kGold.withAlpha(90))),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, color: kGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bagikan tautan undangan',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      Text(link,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: kMuted, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.copy_rounded, color: kMuted, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(_results == null ? 'Saran untukmu' : 'Hasil pencarian',
            style: const TextStyle(color: kMuted, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Center(
                child: Text('Tidak ada pengguna ditemukan',
                    style: TextStyle(color: kMuted))),
          ),
        for (final u in list)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Avatar(u, size: 50),
            title: Text(u.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            subtitle:
                Text('@${u.username}', style: const TextStyle(color: kMuted)),
            trailing: _action(u),
          ),
      ],
    );
  }
}
