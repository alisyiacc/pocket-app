import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'auth/auth_screens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  static const _slides = [
    (Icons.widgets_rounded, 'Foto langsung ke\nlayar utama temanmu',
        'Jepret foto, dan fotonya muncul di widget teman-temanmu. Tanpa feed, tanpa ribet.'),
    (Icons.people_alt_rounded, 'Hanya untuk\norang terdekat',
        'Tambahkan teman lewat username dan pilih siapa saja yang menerima setiap foto.'),
    (Icons.chat_bubble_rounded, 'Balas, bereaksi,\nngobrol',
        'Balas foto dengan emoji atau pesan. Semua percakapan masuk ke tab Obrolan.'),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;
    return Scaffold(
      body: AppBackground(
        glow: true,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _pc.animateToPage(_slides.length - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut),
                  child: Text(last ? '' : 'Lewati',
                      style: const TextStyle(color: kMuted, fontSize: 16)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) {
                    final s = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: kGold.withAlpha(60), blurRadius: 80)
                            ]),
                            child: Squircle(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFFC53D), Color(0xFFFF9500)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(s.$1, size: 104, color: kGoldDeep),
                              ),
                            ),
                          ),
                          const SizedBox(height: 44),
                          Text(s.$2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  height: 1.15)),
                          const SizedBox(height: 14),
                          Text(s.$3,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 17, color: kMuted, height: 1.4)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? kGold : kSurfaceHi,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: GoldButton(
                  label: last ? 'Buat akun' : 'Lanjut',
                  width: double.infinity,
                  glow: true,
                  onTap: () {
                    if (last) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    } else {
                      _pc.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    }
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Sudah punya akun? Masuk',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
