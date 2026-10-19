import 'package:flutter/material.dart';

const kGold = Color(0xFFFFB800);
const kGoldDeep = Color(0xFF2B1D00);
const kSurface = Color(0xFF262628);
const kSurfaceHi = Color(0xFF3A3A3C);
const kMuted = Color(0xFF8E8E93);
const kDanger = Color(0xFFFF453A);

ThemeData pocketTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(primary: kGold),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kSurfaceHi,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        contentTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      ),
    );
