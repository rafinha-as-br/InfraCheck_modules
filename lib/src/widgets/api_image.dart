import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Imagem carregada de um endpoint autenticado (fotos e assinaturas exigem o JWT, então não dá para usar
/// `Image.network` com URL pura). Guarda os bytes em memória por [cacheKey] para não baixar de novo ao rolar.
///
/// Os bytes são dados sensíveis (LGPD) e ficam só na memória do processo.
class ApiImage extends StatefulWidget {
  const ApiImage({super.key, required this.cacheKey, required this.loader, this.fit = BoxFit.cover, this.semanticLabel});

  final String cacheKey;
  final Future<Uint8List> Function() loader;
  final BoxFit fit;
  final String? semanticLabel;

  static final Map<String, Uint8List> _cache = {};

  /// Limpa o cache (ex.: ao sair da sessão).
  static void clearCache() => _cache.clear();

  @override
  State<ApiImage> createState() => _ApiImageState();
}

class _ApiImageState extends State<ApiImage> {
  late Future<Uint8List> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(ApiImage old) {
    super.didUpdateWidget(old);
    if (old.cacheKey != widget.cacheKey) _future = _load();
  }

  Future<Uint8List> _load() async {
    final hit = ApiImage._cache[widget.cacheKey];
    if (hit != null) return hit;
    final bytes = await widget.loader();
    ApiImage._cache[widget.cacheKey] = bytes;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasData) {
          return Image.memory(snap.data!, fit: widget.fit, semanticLabel: widget.semanticLabel, gaplessPlayback: true);
        }
        return ColoredBox(
          color: IcColors.surface100,
          child: Center(
            child: snap.hasError
                ? const Icon(Icons.broken_image_outlined, color: IcColors.ink600)
                : const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      },
    );
  }
}
