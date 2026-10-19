import 'package:flutter/material.dart';
import 'core/config.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

class PocketApp extends StatelessWidget {
  const PocketApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: pocketTheme(),
        home: const SplashScreen(),
        // Di layar lebar (web/desktop/tablet) tampilan dikunci selebar HP (430 px),
        // penuh tinggi layar, tanpa border/celah. Di HP asli tidak ada perubahan.
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          if (mq.size.width <= 600) return child!;
          const w = 430.0;
          return ColoredBox(
            color: Colors.black,
            child: Center(
              child: Container(
                width: w,
                height: mq.size.height,
                foregroundDecoration: const BoxDecoration(
                  border: Border.symmetric(
                      vertical: BorderSide(color: Color(0xFF2A2A2C), width: 1)),
                ),
                child: MediaQuery(
                  data: mq.copyWith(
                    size: Size(w, mq.size.height),
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    viewPadding: const EdgeInsets.only(top: 12, bottom: 8),
                  ),
                  child: child!,
                ),
              ),
            ),
          );
        },
      );
}
