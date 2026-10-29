import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';

/// Selo compacto: ícone + palavra sobre fundo colorido. A cor nunca comunica o estado sozinha.
class _Pill extends StatelessWidget {
  const _Pill({required this.bg, required this.fg, required this.label, this.icon, this.leading});

  final Color bg;
  final Color fg;
  final String label;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(IcRadius.xs)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (leading != null) leading!,
        if (icon != null) Icon(icon, size: 14, color: fg),
        const SizedBox(width: 4),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fg, fontWeight: FontWeight.w600, height: 1.2)),
      ]),
    );
  }
}

/// Selo de status da inspeção (Pendente, Em andamento, Concluída, Aprovada, Rejeitada).
///
/// Design System: `ic-badge ic-badge-<status>`.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.label});

  final InspectionStatus status;

  /// Texto alternativo (ex.: "Concluída · aguardando revisão").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (status) {
      InspectionStatus.pending => (IcColors.surface100, IcColors.ink700, Icons.schedule),
      InspectionStatus.inProgress => (IcColors.primary100, IcColors.primary700, Icons.autorenew),
      InspectionStatus.completed => (IcColors.teal100, IcColors.teal700, Icons.check_circle_outline),
      InspectionStatus.approved => (IcColors.success100, IcColors.success700, Icons.check),
      InspectionStatus.rejected => (IcColors.danger100, IcColors.danger700, Icons.close),
    };
    return _Pill(bg: bg, fg: fg, icon: icon, label: label ?? status.label);
  }
}

/// Selo "Urgente" (inspeções emergenciais), exibido ao lado do status.
class UrgentBadge extends StatelessWidget {
  const UrgentBadge({super.key});

  @override
  Widget build(BuildContext context) =>
      const _Pill(bg: IcColors.signal100, fg: IcColors.signal700, icon: Icons.bolt, label: 'Urgente');
}

/// Selo do resultado de um item: Conforme, Não conforme ou N/A.
class ResultBadge extends StatelessWidget {
  const ResultBadge(this.result, {super.key, this.label});

  final ItemResult result;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (result) {
      ItemResult.conforming => (IcColors.success100, IcColors.success700, Icons.check),
      ItemResult.nonConforming => (IcColors.danger100, IcColors.danger700, Icons.warning_amber_rounded),
      ItemResult.notApplicable => (IcColors.surface100, IcColors.ink700, Icons.remove),
    };
    return _Pill(bg: bg, fg: fg, icon: icon, label: label ?? result.label);
  }
}

/// Cores de fundo/texto de cada criticidade (apenas "Crítica" é preenchida em cor forte).
(Color, Color) criticalityColors(Criticality c) => switch (c) {
      Criticality.low => (IcColors.critBaixaBg, IcColors.critBaixaFg),
      Criticality.medium => (IcColors.critMediaBg, IcColors.critMediaFg),
      Criticality.high => (IcColors.critAltaBg, IcColors.critAltaFg),
      Criticality.critical => (IcColors.critCriticaBg, IcColors.critCriticaFg),
    };

/// Selo de criticidade com barras de sinal (1 a 4) e rótulo.
class CriticalityBadge extends StatelessWidget {
  const CriticalityBadge(this.criticality, {super.key});

  final Criticality criticality;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = criticalityColors(criticality);
    return _Pill(
        bg: bg, fg: fg, label: criticality.label, leading: SignalBars(level: criticality.level, color: fg));
  }
}

/// Barras de sinal: [level] de 4 barras preenchidas, as demais a 30% de opacidade.
class SignalBars extends StatelessWidget {
  const SignalBars({super.key, required this.level, required this.color, this.size = const Size(18, 14)});

  final int level;
  final Color color;
  final Size size;

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: CustomPaint(size: size, painter: _BarsPainter(level, color)));
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.level, this.color);

  final int level;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final barW = size.width * 3.6 / 20;
    final gap = size.width * 1.8 / 20;
    for (var i = 0; i < 4; i++) {
      final h = size.height * (5 + 3 * i) / 16;
      final paint = Paint()..color = color.withValues(alpha: i < level ? 1 : .3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(i * (barW + gap), size.height - h, barW, h), const Radius.circular(1)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) => old.level != level || old.color != color;
}

/// Estilo mono dos números de OS e códigos, reutilizado pelas telas.
TextStyle monoStyle(BuildContext context, {double size = 14, Color color = IcColors.ink900}) =>
    IcText.mono(size: size, color: color);
