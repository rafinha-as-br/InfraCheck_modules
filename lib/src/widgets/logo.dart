import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Versões do logotipo (ver README do design: escolha conforme o fundo).
enum LogoVariant {
  /// Sobre `surface-0` / `surface-50`.
  horizontal('logo-horizontal.svg'),

  /// Sobre `primary-900` (sidebar, login, cabeçalho mobile).
  horizontalReverse('logo-horizontal-reverse.svg'),

  /// Todo branco, sobre `signal-500` ou fotos escuras.
  monoWhite('logo-mono-branco.svg'),

  /// Capas, splash e espaços estreitos e altos.
  vertical('logo-vertical.svg'),

  /// Somente o símbolo, em fundos claros.
  mark('mark.svg'),

  /// Símbolo para fundos `primary-900`.
  markReverse('mark-reverse.svg'),

  /// Ícone do app.
  appIcon('app-icon.svg');

  const LogoVariant(this.file);
  final String file;
}

/// Logotipo da InfraCheck. Respeite a área de proteção (altura do check) ao posicioná-lo.
class IcLogo extends StatelessWidget {
  const IcLogo(this.variant, {super.key, this.height, this.width});

  final LogoVariant variant;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/logos/${variant.file}',
        package: 'infracheck_modules',
        height: height,
        width: width,
        semanticsLabel: 'InfraCheck',
      );
}
