import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Tipos de aviso do design system (`ic-notice-*`).
enum NoticeKind { info, warn, danger, ok, brand }

/// Aviso com ícone + texto: primeira frase em negrito diz o que aconteceu, o resto diz o que fazer.
///
/// Offline é sempre [NoticeKind.warn], nunca erro: o dado está salvo no aparelho.
class IcNotice extends StatelessWidget {
  const IcNotice({super.key, required this.kind, this.title, required this.message, this.icon});

  final NoticeKind kind;

  /// Frase curta em negrito (opcional).
  final String? title;
  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, defaultIcon) = switch (kind) {
      NoticeKind.info => (IcColors.primary50, IcColors.primary700, Icons.info_outline),
      NoticeKind.warn => (IcColors.warning100, IcColors.warning700, Icons.wifi_off),
      NoticeKind.danger => (IcColors.danger100, IcColors.danger700, Icons.warning_amber_rounded),
      NoticeKind.ok => (IcColors.success100, IcColors.success700, Icons.check_circle_outline),
      NoticeKind.brand => (IcColors.signal100, IcColors.signal700, Icons.info_outline),
    };
    final base = Theme.of(context).textTheme.bodyMedium!;
    return Container(
      padding: const EdgeInsets.all(IcSpacing.s3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(IcRadius.md)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon ?? defaultIcon, size: 20, color: fg),
        const SizedBox(width: IcSpacing.s3),
        Expanded(
          child: Text.rich(TextSpan(style: base.copyWith(color: IcColors.ink900), children: [
            if (title != null) TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: message),
          ])),
        ),
      ]),
    );
  }
}
