import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../friends/friends_screen.dart';
import '../profile/profile_screen.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  void _newChat(BuildContext context, List<User> friends) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            children: [
              const Text('Pesan baru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final f in friends)
                ListTile(
                  leading: Avatar(f, size: 42),
                  title: Text(f.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('@${f.username}',
                      style: const TextStyle(color: kMuted)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ChatScreen(friend: f)));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final friends = context.watch<FriendsProvider>().friends;
    final me = context.watch<AuthProvider>().user;
    final empty = friends.isEmpty;

    return AppBackground(
      glow: empty,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
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
                            child: Text('Obrolan',
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.w800)),
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
                  child: empty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 80),
                            child: EmptyState(
                              icon: const _ChatIllustration(),
                              title: 'Tambah teman di Pocket',
                              subtitle:
                                  'Kamu butuh teman di Pocket untuk mulai mengirim balasan dan reaksi',
                              action: GoldButton(
                                label: 'Tambah teman',
                                icon: Icons.add_rounded,
                                glow: true,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const FriendsScreen(initialTab: 2))),
                              ),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: kGold,
                          backgroundColor: kSurface,
                          onRefresh: () => chat.load(silent: true),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 130),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: chat.conversations.length,
                            itemBuilder: (_, i) =>
                                _tile(context, chat.conversations[i], me?.id ?? 0),
                          ),
                        ),
                ),
              ],
            ),
            Positioned(
              right: 18,
              bottom: MediaQuery.of(context).padding.bottom + 22,
              child: GestureDetector(
                onTap: empty ? null : () => _newChat(context, friends),
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kGold.withAlpha(empty ? 60 : 255)),
                  child: Icon(Icons.edit_rounded,
                      color: empty ? kGold.withAlpha(150) : kGoldDeep),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, Conversation c, int meId) {
    final m = c.lastMessage;
    String preview = 'Ketuk untuk mulai mengobrol';
    if (m != null) {
      final body = m.snapId != null ? '📷 ${m.body}' : m.body;
      preview = m.senderId == meId ? 'Kamu: $body' : body;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => ChatScreen(friend: c.friend)))
          .then((_) => context.read<ChatProvider>().load(silent: true)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            Avatar(c.friend, size: 56, ring: c.unread > 0),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.friend.name,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: c.unread > 0 ? Colors.white : kMuted,
                          fontWeight:
                              c.unread > 0 ? FontWeight.w700 : FontWeight.w500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (m != null)
                  Text(timeAgo(m.createdAt),
                      style: const TextStyle(color: kMuted, fontSize: 12)),
                if (c.unread > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: kGold, borderRadius: BorderRadius.circular(10)),
                    child: Text('${c.unread}',
                        style: const TextStyle(
                            color: kGoldDeep,
                            fontWeight: FontWeight.w800,
                            fontSize: 12)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ilustrasi gelembung chat + hati + kilau (empty state Obrolan).
class _ChatIllustration extends StatelessWidget {
  const _ChatIllustration();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 150,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 78, color: Color(0xFFA5A5AA)),
            Positioned(
                right: 20,
                top: 2,
                child: Icon(Icons.favorite_rounded, size: 28, color: Color(0xFFA5A5AA))),
            Positioned(
                left: 10,
                top: 30,
                child: Icon(Icons.favorite_rounded, size: 22, color: Color(0xFFA5A5AA))),
            Positioned(
                left: 28,
                top: 6,
                child: Icon(Icons.auto_awesome_rounded, size: 20, color: Color(0xFFA5A5AA))),
            Positioned(
                right: 6,
                top: 56,
                child: Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFFA5A5AA))),
          ],
        ),
      );
}
