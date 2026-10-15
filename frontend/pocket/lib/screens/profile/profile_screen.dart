import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../friends/friends_screen.dart';
import '../onboarding_screen.dart';
import 'edit_profile_screen.dart';
import 'widget_guide_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notif = true, _private = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<AuthProvider>().refresh());
  }

  Widget _tile(IconData icon, String title,
      {String? sub, Widget? trailing, VoidCallback? onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
            color: const Color(0xFF1F1F20),
            borderRadius: BorderRadius.circular(24)),
        child: Row(
          children: [
            Icon(icon, color: color ?? kGold),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  if (sub != null)
                    Text(sub,
                        style: const TextStyle(color: kMuted, fontSize: 12.5)),
                ],
              ),
            ),
            trailing ??
                (onTap != null && color == null
                    ? const Icon(Icons.chevron_right_rounded, color: kMuted)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Keluar dari Pocket?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar', style: TextStyle(color: kDanger))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final nav = Navigator.of(context);
    final auth = context.read<AuthProvider>();
    final friends = context.read<FriendsProvider>();
    final snaps = context.read<SnapsProvider>();
    final chat = context.read<ChatProvider>();
    await auth.logout();
    friends.clear();
    snaps.clear();
    chat.clear();
    nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;
    if (me == null) return const Scaffold();
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              Center(child: Avatar(me, size: 112, ring: true)),
              const SizedBox(height: 14),
              Center(
                child: Text(me.name,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900)),
              ),
              Center(
                child: Text('@${me.username}',
                    style: const TextStyle(color: kMuted, fontSize: 15)),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  _stat('${me.friendsCount}', 'Teman'),
                  const SizedBox(width: 12),
                  _stat('${me.snapsCount}', 'Pocket terkirim'),
                ],
              ),
              const SizedBox(height: 22),
              _tile(Icons.edit_rounded, 'Edit profil',
                  sub: 'Nama dan username',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
              _tile(Icons.people_alt_rounded, 'Kelola teman',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FriendsScreen()))),
              _tile(Icons.widgets_rounded, 'Cara pasang widget',
                  sub: 'Android & iOS',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WidgetGuideScreen()))),
              _tile(Icons.notifications_rounded, 'Notifikasi',
                  trailing: Switch(
                      value: _notif,
                      activeColor: kGold,
                      onChanged: (v) => setState(() => _notif = v))),
              _tile(Icons.lock_rounded, 'Akun privat',
                  sub: 'Hanya teman yang bisa menemukanmu',
                  trailing: Switch(
                      value: _private,
                      activeColor: kGold,
                      onChanged: (v) => setState(() => _private = v))),
              _tile(Icons.dns_rounded, 'Sumber data',
                  sub: AppConfig.useMock
                      ? 'Mock (offline, tanpa server)'
                      : AppConfig.baseUrl),
              _tile(Icons.info_rounded, 'Tentang Pocket',
                  sub: 'Kelompok 7 • UTS Pemrograman Aplikasi Bergerak 2026',
                  onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'Pocket',
                      applicationVersion: '1.0.0',
                      children: const [
                        Text('Clone Locket Widget untuk UTS Pemrograman Aplikasi Bergerak 2026 (Kelompok 7).'),
                      ])),
              const SizedBox(height: 8),
              _tile(Icons.logout_rounded, 'Keluar',
                  color: kDanger, onTap: _logout),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String v, String l) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: const Color(0xFF1F1F20),
              borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              Text(v,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900, color: kGold)),
              const SizedBox(height: 2),
              Text(l, style: const TextStyle(color: kMuted)),
            ],
          ),
        ),
      );
}
