import '../models/enums.dart';
import '../models/models.dart';

/// Resposta do inspetor a um item do checklist (parte do pacote de envio).
class ItemAnswer {
  const ItemAnswer({required this.itemId, required this.result, this.criticality, this.description, this.recommendedAction});

  final String itemId;
  final ItemResult result;
  final Criticality? criticality;
  final String? description;
  final String? recommendedAction;

  factory ItemAnswer.fromJson(Map<String, dynamic> j) => ItemAnswer(
        itemId: j['itemId'] as String,
        result: enumFromApi(ItemResult.values, j['result']),
        criticality: enumFromApiOrNull(Criticality.values, j['criticality']),
        description: j['description'] as String?,
        recommendedAction: j['recommendedAction'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'result': enumToApi(result),
        if (criticality != null) 'criticality': enumToApi(criticality!),
        if (description != null) 'description': description,
        if (recommendedAction != null) 'recommendedAction': recommendedAction,
      };
}

/// Pacote completo da execução enviado ao encerrar (ou ao sincronizar depois de um período offline).
///
/// [signaturePngBase64] é o PNG da assinatura em base64. O mesmo objeto é gravado no aparelho enquanto
/// o envio não é confirmado (fila offline), por isso também tem [fromJson].
class SubmitPayload {
  const SubmitPayload({
    required this.startedAt,
    required this.startLocation,
    required this.finishedAt,
    required this.endLocation,
    required this.signaturePngBase64,
    required this.items,
    this.generalNotes,
  });

  final DateTime startedAt;
  final GeoPoint? startLocation;
  final DateTime finishedAt;
  final GeoPoint endLocation;
  final String? generalNotes;
  final String signaturePngBase64;
  final List<ItemAnswer> items;

  factory SubmitPayload.fromJson(Map<String, dynamic> j) => SubmitPayload(
        startedAt: DateTime.parse(j['startedAt'] as String),
        startLocation: GeoPoint.fromJsonOrNull(j['startLocation']),
        finishedAt: DateTime.parse(j['finishedAt'] as String),
        endLocation: GeoPoint.fromJson(j['endLocation'] as Map<String, dynamic>),
        generalNotes: j['generalNotes'] as String?,
        signaturePngBase64: j['signature'] as String,
        items: [for (final i in j['items'] as List) ItemAnswer.fromJson(i as Map<String, dynamic>)],
      );

  Map<String, dynamic> toJson() => {
        'startedAt': startedAt.toUtc().toIso8601String(),
        if (startLocation != null) 'startLocation': startLocation!.toJson(),
        'finishedAt': finishedAt.toUtc().toIso8601String(),
        'endLocation': endLocation.toJson(),
        if (generalNotes != null && generalNotes!.trim().isNotEmpty) 'generalNotes': generalNotes,
        'signature': signaturePngBase64,
        'items': [for (final i in items) i.toJson()],
      };
}
