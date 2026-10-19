import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([auth.init(), Future.delayed(const Duration(milliseconds: 1300))]);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) =>
            auth.loggedIn ? const MainShell() : const OnboardingScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: AppBackground(
          glow: true,
          child: Center(
            child: FadeTransition(
              opacity: _c,
              child: ScaleTransition(
                scale: Tween(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(parent: _c, curve: Curves.easeOutBack)),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PocketLogo(size: 120),
                    SizedBox(height: 22),
                    Text('Pocket',
                        style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
