import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Tema Material 3 do InfraCheck, montado a partir dos tokens do design system
/// (mapeamento descrito no README do design: `primary-700` → `primary`, `danger-700` → `error` etc.).
///
/// Tipografia: Barlow nos títulos, IBM Plex Sans no texto e IBM Plex Mono em dados técnicos
/// (ver [IcText.mono]). As fontes vêm do pacote `google_fonts`: ficam em cache no aparelho depois do
/// primeiro uso online (o app do inspetor sempre faz um login online antes de operar offline).
abstract final class InfraCheckTheme {
  /// Constrói o tema claro (fontes controladas por [IcFonts.useGoogleFonts]).
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: IcColors.primary700,
      brightness: Brightness.light,
    ).copyWith(
      primary: IcColors.primary700,
      onPrimary: IcColors.onPrimary,
      primaryContainer: IcColors.primary100,
      onPrimaryContainer: IcColors.primary900,
      tertiary: IcColors.signal500,
      onTertiary: IcColors.ink900,
      error: IcColors.danger700,
      onError: IcColors.onPrimary,
      errorContainer: IcColors.danger100,
      onErrorContainer: IcColors.danger700,
      surface: IcColors.surface0,
      onSurface: IcColors.ink900,
      onSurfaceVariant: IcColors.ink600,
      surfaceContainer: IcColors.surface100,
      surfaceContainerLowest: IcColors.surface0,
      surfaceContainerLow: IcColors.surface50,
      outline: IcColors.borderStrong,
      outlineVariant: IcColors.borderSubtle,
    );

    final textTheme = _textTheme(IcFonts.useGoogleFonts);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(IcRadius.md));

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: IcColors.surface50,
      textTheme: textTheme,
      dividerColor: IcColors.borderSubtle,
      focusColor: IcColors.primary600,
      appBarTheme: AppBarTheme(
        backgroundColor: IcColors.primary900,
        foregroundColor: IcColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: IcColors.onPrimary, fontSize: 18),
      ),
      cardTheme: CardThemeData(
        color: IcColors.surface0,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IcRadius.lg),
          side: const BorderSide(color: IcColors.borderSubtle),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, IcSpacing.control),
          shape: shape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, IcSpacing.control),
          shape: shape,
          foregroundColor: IcColors.primary700,
          side: const BorderSide(color: IcColors.borderStrong),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, IcSpacing.control),
          shape: shape,
          foregroundColor: IcColors.primary700,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: IcColors.surface0,
        contentPadding: const EdgeInsets.symmetric(horizontal: IcSpacing.s3, vertical: IcSpacing.s3),
        hintStyle: textTheme.bodyMedium?.copyWith(color: IcColors.ink600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IcRadius.sm),
          borderSide: const BorderSide(color: IcColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IcRadius.sm),
          borderSide: const BorderSide(color: IcColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IcRadius.sm),
          borderSide: const BorderSide(color: IcColors.primary600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IcRadius.sm),
          borderSide: const BorderSide(color: IcColors.danger700, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(IcRadius.sm),
          borderSide: const BorderSide(color: IcColors.danger700, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(side: BorderSide(color: IcColors.borderStrong)),
        selectedColor: IcColors.primary100,
        backgroundColor: IcColors.surface0,
        labelStyle: textTheme.labelLarge,
        showCheckmark: false,
      ),
      dividerTheme: const DividerThemeData(color: IcColors.borderSubtle, space: 1, thickness: 1),
    );
  }

  static TextTheme _textTheme(bool google) {
    TextStyle display(double size, double height, FontWeight w) => google
        ? GoogleFonts.barlow(fontSize: size, height: height / size, fontWeight: w, color: IcColors.ink900)
        : TextStyle(fontFamily: 'Barlow', fontSize: size, height: height / size, fontWeight: w, color: IcColors.ink900);
    TextStyle sans(double size, double height, FontWeight w, {double? spacing}) => google
        ? GoogleFonts.ibmPlexSans(
            fontSize: size, height: height / size, fontWeight: w, letterSpacing: spacing, color: IcColors.ink900)
        : TextStyle(
            fontFamily: 'IBM Plex Sans',
            fontSize: size,
            height: height / size,
            fontWeight: w,
            letterSpacing: spacing,
            color: IcColors.ink900);

    return TextTheme(
      displayMedium: display(40, 44, FontWeight.w700), // display
      headlineMedium: display(28, 34, FontWeight.w700), // h1
      titleLarge: display(22, 28, FontWeight.w600), // h2
      titleMedium: display(18, 24, FontWeight.w600), // h3
      bodyLarge: sans(16, 24, FontWeight.w400), // body-lg
      bodyMedium: sans(14, 20, FontWeight.w400), // body
      bodySmall: sans(13, 18, FontWeight.w400), // body-sm
      labelSmall: sans(12, 16, FontWeight.w600, spacing: 0.5), // label (caixa alta)
      labelLarge: sans(15, 20, FontWeight.w600), // button
    );
  }
}

/// Chave global das fontes: testes definem alse para não buscar fontes na rede (usa a família pelo nome).
abstract final class IcFonts {
  static bool useGoogleFonts = true;
}

/// Estilos de tipografia que não existem no `TextTheme` do Material.
abstract final class IcText {
  /// IBM Plex Mono: número da OS, coordenadas, horários e códigos (estilos `data` / `data-sm` do design).
  static TextStyle mono({double size = 14, Color color = IcColors.ink900}) {
    return IcFonts.useGoogleFonts
        ? GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: FontWeight.w500, color: color)
        : TextStyle(fontFamily: 'IBM Plex Mono', fontSize: size, fontWeight: FontWeight.w500, color: color);
  }
}
