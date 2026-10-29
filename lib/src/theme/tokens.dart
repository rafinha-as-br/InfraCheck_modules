import 'package:flutter/material.dart';

/// Cores do design system "InfraCheck — Marca e Design System" (tema claro, única versão do MVP).
///
/// Os nomes espelham os tokens de `tokens.json` do design (ex.: `primary-900` → [primary900]).
/// Nunca escreva um valor de cor direto na UI: use sempre estes tokens.
abstract final class IcColors {
  // Marca e ação
  static const primary900 = Color(0xFF0B2B4D);
  static const primary700 = Color(0xFF0F4A85);
  static const primary600 = Color(0xFF1560AB);
  static const primary100 = Color(0xFFDCE9F7);
  static const primary50 = Color(0xFFEEF4FB);
  static const signal500 = Color(0xFFF58220);
  static const signal700 = Color(0xFFA84300);
  static const signal100 = Color(0xFFFDE8D4);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryMuted = Color(0xFFC7D8EC);

  // Texto e bordas
  static const ink900 = Color(0xFF0F1B2A);
  static const ink700 = Color(0xFF33414F);
  static const ink600 = Color(0xFF475666);
  static const borderStrong = Color(0xFF758395);
  static const borderSubtle = Color(0xFFD5DCE5);

  // Superfícies
  static const surface0 = Color(0xFFFFFFFF);
  static const surface50 = Color(0xFFF5F7FA);
  static const surface100 = Color(0xFFE9EEF4);

  // Status (sempre par fundo/texto, com ícone e palavra na UI)
  static const success700 = Color(0xFF0A6B4A);
  static const success100 = Color(0xFFDDF3E8);
  static const danger700 = Color(0xFFB3261E);
  static const danger100 = Color(0xFFFCE4E1);
  static const warning700 = Color(0xFF7A4F00);
  static const warning100 = Color(0xFFFFF1CC);
  static const teal700 = Color(0xFF0B6566);
  static const teal100 = Color(0xFFD5F0EF);

  // Criticidade
  static const critBaixaFg = Color(0xFF6B5200);
  static const critBaixaBg = Color(0xFFFFF3C4);
  static const critMediaFg = Color(0xFF8A3F00);
  static const critMediaBg = Color(0xFFFFE2C2);
  static const critAltaFg = Color(0xFFA4160E);
  static const critAltaBg = Color(0xFFFFD3CC);
  static const critCriticaFg = Color(0xFFFFFFFF);
  static const critCriticaBg = Color(0xFF8B0F1F);
}

/// Escala de espaçamento (grade de 4 px) e alvos mínimos de toque/clique.
abstract final class IcSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;

  /// Altura mínima de controles na web.
  static const double control = 44;

  /// Altura mínima de alvos de toque no app.
  static const double touch = 48;
}

/// Raios de borda.
abstract final class IcRadius {
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 20;
}

/// Sombras do design system.
abstract final class IcShadows {
  static const sm = [BoxShadow(color: Color(0x140B2B4D), blurRadius: 2, offset: Offset(0, 1))];
  static const md = [BoxShadow(color: Color(0x1F0B2B4D), blurRadius: 12, offset: Offset(0, 4))];
  static const lg = [BoxShadow(color: Color(0x2E0B2B4D), blurRadius: 32, offset: Offset(0, 12))];
}
