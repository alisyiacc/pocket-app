import 'package:flutter/material.dart';

const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
];

String monthName(int m) => _months[m - 1];

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'Baru saja';
  if (d.inMinutes < 60) return '${d.inMinutes} mnt';
  if (d.inHours < 24) return '${d.inHours} jam';
  if (d.inDays == 1) return 'Kemarin';
  if (d.inDays < 7) return '${d.inDays} hari';
  return '${t.day} ${_months[t.month - 1].substring(0, 3)}';
}

String clock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

const _avatarColors = [
  Color(0xFFFF6B8A), Color(0xFF4FA3F7), Color(0xFF8E6CEF), Color(0xFF3CC48A),
  Color(0xFFFF9248), Color(0xFF26C6DA), Color(0xFFEC407A), Color(0xFF7E57C2),
];

Color colorForId(int id) => _avatarColors[id % _avatarColors.length];

void toast(BuildContext context, String msg) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(msg)));
}
