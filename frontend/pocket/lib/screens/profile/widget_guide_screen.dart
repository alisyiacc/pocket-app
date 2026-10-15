import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class WidgetGuideScreen extends StatelessWidget {
  const WidgetGuideScreen({super.key});

  Widget _step(int n, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration:
                  const BoxDecoration(color: kGold, shape: BoxShape.circle),
              child: Text('$n',
                  style: const TextStyle(
                      color: kGoldDeep, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(text,
                    style: const TextStyle(fontSize: 16, height: 1.35))),
          ],
        ),
      );

  Widget _card(String title, IconData icon, List<String> steps) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF1F1F20),
            borderRadius: BorderRadius.circular(28)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: kGold),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 18),
            for (var i = 0; i < steps.length; i++) _step(i + 1, steps[i]),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pasang widget')),
        body: AppBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _card('Android', Icons.android_rounded, const [
                  'Tahan lama area kosong di layar utama.',
                  'Pilih "Widget", lalu cari "Pocket".',
                  'Seret widget Pocket ke layar utama.',
                  'Foto terbaru dari temanmu muncul otomatis.',
                ]),
                _card('iPhone (iOS)', Icons.phone_iphone_rounded, const [
                  'Tahan lama layar utama sampai ikon bergoyang.',
                  'Ketuk tombol "+" di pojok kiri atas.',
                  'Cari "Pocket", pilih ukuran, lalu "Tambah Widget".',
                  'Foto terbaru dari temanmu muncul otomatis.',
                ]),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Catatan: widget layar utama membutuhkan integrasi native (paket home_widget) dan akan ditambahkan pada tahap berikutnya setelah database tersambung.',
                    style: TextStyle(color: kMuted, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
