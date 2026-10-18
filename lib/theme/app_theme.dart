import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Paleta Cálida Tipo Libreta Digital ───────────────────────
  // Fondo suave crema que descansa la vista y parece papel fino
  static const Color background = Color(0xFFFAF7F2);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceWarm = Color(0xFFF3EDE3);
  static const Color divider = Color(0xFFE8E2D8);

  // 1. Almacén / Llegaron: Verde Bosque Fresco y Amigable
  static const Color inStock = Color(0xFF15803D);
  static const Color inStockLight = Color(0xFFEAF8F0);
  static const Color inStockDark = Color(0xFF0F5A2B);

  // 2. Despachar / Salieron: Naranja Ruta Enérgico
  static const Color sent = Color(0xFFEA580C);
  static const Color sentLight = Color(0xFFFFF2EB);
  static const Color sentDark = Color(0xFF9A3412);

  // 3. Historial de Envíos: Azul Índigo de Registro
  static const Color history = Color(0xFF4338CA);
  static const Color historyLight = Color(0xFFEEF2FF);

  // 4. Calendario y Fechas: Púrpura Cálido
  static const Color accent = Color(0xFF7C3AED);
  static const Color accentLight = Color(0xFFF5EEFF);

  // Primario general
  static const Color primary = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFFEAF8F0);
  static const Color primaryDark = Color(0xFF0F5A2B);

  // Textos oscuros legibles de alto contraste
  static const Color textDark = Color(0xFF18181B);
  static const Color textMedium = Color(0xFF52525B);
  static const Color textLight = Color(0xFF71717A);

  static const Color danger = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFEE2E2);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: sent,
          surface: background,
          error: danger,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          displayLarge: GoogleFonts.nunito(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
          displayMedium: GoogleFonts.nunito(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
          headlineLarge: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
          headlineMedium: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          titleLarge: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textMedium,
          ),
          labelLarge: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
          iconTheme: const IconThemeData(color: textDark, size: 26),
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.15),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          hintStyle: GoogleFonts.nunito(
            color: textLight,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: divider, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: divider, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: danger, width: 1.5),
          ),
        ),
      );
}
