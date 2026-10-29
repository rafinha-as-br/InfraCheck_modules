import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Fundo de marca: `primary-900` com a textura "moldura de inspeção" (cantoneiras de visor a 10% de branco).
///
/// Equivale a `assets/patterns/padrao-moldura-inspecao.svg`, desenhado em Dart porque o `<pattern>` do SVG
/// não renderiza de forma confiável no CanvasKit. Use em login e capas; não como ícone nem em excesso.
class FramePattern extends StatelessWidget {
  const FramePattern({super.key, this.tile = 96});

  /// Lado de cada ladrilho, em px lógicos (o design usa 96).
  final double tile;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox.expand(child: CustomPaint(painter: _FramePainter(tile))),
      );
}

class _FramePainter extends CustomPainter {
  _FramePainter(this.tile);

  final double tile;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = IcColors.primary900);
    final k = tile / 96;
    final stroke = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * k
      ..strokeCap = StrokeCap.square;
    final corners = Path()
      ..moveTo(8 * k, 22 * k)..lineTo(8 * k, 8 * k)..lineTo(22 * k, 8 * k)
      ..moveTo(74 * k, 8 * k)..lineTo(88 * k, 8 * k)..lineTo(88 * k, 22 * k)
      ..moveTo(88 * k, 74 * k)..lineTo(88 * k, 88 * k)..lineTo(74 * k, 88 * k)
      ..moveTo(22 * k, 88 * k)..lineTo(8 * k, 88 * k)..lineTo(8 * k, 74 * k);
    for (var y = 0.0; y < size.height; y += tile) {
      for (var x = 0.0; x < size.width; x += tile) {
        canvas.save();
        canvas.translate(x, y);
        canvas.drawPath(corners, stroke);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.tile != tile;
}
