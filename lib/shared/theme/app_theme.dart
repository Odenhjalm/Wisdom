import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisdom/shared/theme/typography.dart';

class AppThemeData {
  final ThemeData light;
  final ThemeData dark;
  AppThemeData(this.light, this.dark);
}

ColorScheme _scheme(Brightness b) => ColorScheme.fromSeed(
      seedColor: const Color(0xFF9B8CFF),
      secondary: const Color(0xFF4FC3F7),
      brightness: b,
    );

final appThemeProvider = Provider<AppThemeData>((ref) {
  final textLight = AppTypography.textTheme(brightness: Brightness.light);
  final textDark = AppTypography.textTheme(brightness: Brightness.dark);

  ThemeData buildTheme(Brightness b, TextTheme txt) {
    final cs = _scheme(b);
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: txt,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: cs.onSurface,
      ),
      scaffoldBackgroundColor: b == Brightness.light
          ? const Color(0xFFF7F7FA)
          : const Color(0xFF0C0D10),
      cardTheme: CardThemeData(
        // Glasliknande kort – svag fyllnad, tydligare kant
        color: b == Brightness.light
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFF14161A).withValues(alpha: 0.16),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: b == Brightness.light
                ? Colors.white.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.40),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: b == Brightness.light
            ? const Color(0x14000000)
            : const Color(0x22FFFFFF),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: b == Brightness.light
            ? const Color(0xFFF3F4F6)
            : const Color(0xFF151821),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary.withValues(alpha: 0.35)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        iconColor: cs.primary,
      ),
      iconTheme: IconThemeData(color: cs.primary),
    );
  }

  return AppThemeData(
    buildTheme(Brightness.light, textLight),
    buildTheme(Brightness.dark, textDark),
  );
});
