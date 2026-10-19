import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../friends/friends_screen.dart';

class SendScreen extends StatefulWidget {
  final String imagePath;
  const SendScreen({super.key, required this.imagePath});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _caption = TextEditingController();
  final _focus = FocusNode();
  final Set<int> _sel = {};
  bool _sending = false, _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _init = true;
      _sel.addAll(context.read<FriendsProvider>().friends.map((f) => f.id));
    }
  }

  @override
  void dispose() {
    _caption.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sel.isEmpty) {
      toast(context, 'Pilih minimal satu teman');
      return;
    }
    setState(() => _sending = true);
    try {
      final n = await context
          .read<SnapsProvider>()
          .send(widget.imagePath, _caption.text.trim(), _sel.toList());
      if (!mounted) return;
      Navigator.pop(context, n);
    } on ApiException catch (e) {
      if (!mounted) return;
      toast(context, e.message);
      setState(() => _sending = false);
    } catch (_) {
      if (!mounted) return;
      toast(context, 'Gagal mengirim. Coba lagi.');
      setState(() => _sending = false);
    }
  }

  Widget _chip(String label, bool selected, Widget avatar, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: selected ? kGold : Colors.transparent,
                        width: 2.5)),
                child: avatar,
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12, color: selected ? Colors.white : kMuted)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final friends = context.watch<FriendsProvider>().friends;
    final all = friends.isNotEmpty && _sel.length == friends.length;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Text('Kirim ke...',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, c) {
                  final size = math.min(c.maxWidth, c.maxHeight);
                  return Center(
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: Squircle(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            SnapImage(widget.imagePath),
                            Positioned(
                              bottom: 22,
                              left: 44,
                              right: 44,
                              child: TextField(
                                controller: _caption,
                                focusNode: _focus,
                                maxLength: 60,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'Tambah pesan',
                                  hintStyle: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600),
                                  filled: true,
                                  fillColor: Colors.black.withAlpha(110),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(26),
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GlassCircle(
                      size: 56,
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded, size: 30)),
                  Shutter(
                      icon: Icons.arrow_upward_rounded,
                      busy: _sending,
                      onTap: _sending ? () {} : _send),
                  GlassCircle(
                      size: 56,
                      onTap: () => _focus.requestFocus(),
                      child: const Icon(Icons.text_fields_rounded, size: 26)),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 92,
                child: friends.isEmpty
                    ? Center(
                        child: TextButton.icon(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const FriendsScreen(initialTab: 2))),
                          icon: const Icon(Icons.person_add_rounded, color: kGold),
                          label: const Text('Belum ada teman. Tambah teman dulu',
                              style: TextStyle(color: kGold)),
                        ),
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _chip(
                            'Semua',
                            all,
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: kSurface),
                              child: const Icon(Icons.people_alt_rounded,
                                  color: kGold),
                            ),
                            () => setState(() {
                              if (all) {
                                _sel.clear();
                              } else {
                                _sel.addAll(friends.map((f) => f.id));
                              }
                            }),
                          ),
                          ...friends.map((User f) => _chip(
                                f.name,
                                _sel.contains(f.id),
                                Avatar(f, size: 48),
                                () => setState(() => _sel.contains(f.id)
                                    ? _sel.remove(f.id)
                                    : _sel.add(f.id)),
                              )),
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
