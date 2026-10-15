import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';

class ChatScreen extends StatefulWidget {
  final User friend;
  const ChatScreen({super.key, required this.friend});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  List<Message> _msgs = [];
  bool _loading = true, _sending = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
    // Polling sederhana tiap 4 detik (cukup untuk tugas; produksi bisa pakai WebSocket).
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    _input.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    try {
      final l = await context.read<ChatProvider>().messages(widget.friend.id);
      if (mounted) setState(() => _msgs = l);
    } catch (_) {}
    if (mounted && !silent) setState(() => _loading = false);
  }

  Future<void> _send() async {
    final t = _input.text.trim();
    if (t.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final m = await context.read<ChatProvider>().send(widget.friend.id, t);
      _input.clear();
      if (mounted) setState(() => _msgs = [..._msgs, m]);
    } on ApiException catch (e) {
      if (mounted) toast(context, e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meId = context.read<AuthProvider>().user?.id ?? 0;
    final items = _msgs.reversed.toList();
    final maxW = MediaQuery.of(context).size.width * 0.74;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Avatar(widget.friend, size: 38, ring: true),
            const SizedBox(width: 10),
            Text(widget.friend.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: kGold))
                    : items.isEmpty
                        ? Center(
                            child: Text('Sapa ${widget.friend.name} 👋',
                                style: const TextStyle(color: kMuted, fontSize: 17)))
                        : ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                            itemCount: items.length,
                            itemBuilder: (_, i) {
                              final m = items[i];
                              final mine = m.senderId == meId;
                              return Align(
                                alignment: mine
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: maxW),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: mine
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (m.snapImageUrl != null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: SizedBox(
                                            width: 130,
                                            height: 130,
                                            child: Squircle(
                                                child: SnapImage(m.snapImageUrl!)),
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 11),
                                        decoration: BoxDecoration(
                                          color: mine ? kGold : kSurface,
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        child: Text(m.body,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: mine
                                                    ? kGoldDeep
                                                    : Colors.white)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 3, left: 6, right: 6),
                                        child: Text(clock(m.createdAt),
                                            style: const TextStyle(
                                                color: kMuted, fontSize: 11)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 6),
                  decoration: BoxDecoration(
                      color: kSurface, borderRadius: BorderRadius.circular(32)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          onSubmitted: (_) => _send(),
                          textInputAction: TextInputAction.send,
                          decoration: const InputDecoration(
                              hintText: 'Kirim pesan...',
                              hintStyle: TextStyle(color: kMuted),
                              border: InputBorder.none),
                        ),
                      ),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                              color: kGold, shape: BoxShape.circle),
                          child: _sending
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: kGoldDeep))
                              : const Icon(Icons.arrow_upward_rounded,
                                  color: kGoldDeep),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
