import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import 'camera/camera_screen.dart';
import 'chat/chat_list_screen.dart';
import 'lockets/lockets_screen.dart';

/// Cangkang utama: 3 halaman yang bisa digeser (Lockets - Kamera - Obrolan)
/// + bilah navigasi melayang.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// 0 = Rollcalls, 1 = Lockets (tab di halaman kalender)
  static final ValueNotifier<int> locketsTab = ValueNotifier<int>(1);
  static PageController? _ctrl;

  /// Pindah halaman dari mana saja (0 = Lockets, 1 = Kamera, 2 = Obrolan).
  static void goTo(int page, {int? locketsTabIndex}) {
    if (locketsTabIndex != null) locketsTab.value = locketsTabIndex;
    _ctrl?.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _pc = PageController(initialPage: 1);
  int _index = 1;

  @override
  void initState() {
    super.initState();
    MainShell._ctrl = _pc;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    final me = context.read<AuthProvider>().user;
    if (me == null) return;
    context.read<FriendsProvider>().load();
    context.read<SnapsProvider>().load(me.id);
    context.read<ChatProvider>().load();
  }

  @override
  void dispose() {
    MainShell._ctrl = null;
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.select<ChatProvider, int>((p) => p.unread);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pc,
            onPageChanged: (i) => setState(() => _index = i),
            children: const [LocketsScreen(), CameraScreen(), ChatListScreen()],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 14,
            child: Center(
              child: NavPill(
                index: _index,
                unread: unread,
                onTap: (i) => MainShell.goTo(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
