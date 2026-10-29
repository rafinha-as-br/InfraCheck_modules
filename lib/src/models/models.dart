/// Modelos imutáveis do contrato da API (espelham `docs/api.md` do InfraCheck_Server).
///
/// São DTOs de transporte: `fromJson` para respostas e `toJson` para o que o app envia.
/// Regras de negócio continuam no servidor.
library;

import 'enums.dart';

DateTime _dt(Object? v) => DateTime.parse(v as String).toLocal();
DateTime? _dtOrNull(Object? v) => v == null ? null : _dt(v);
double? _num(Object? v) => (v as num?)?.toDouble();

/// Coordenada GPS com precisão em metros. Dado sensível (LGPD).
class GeoPoint {
  const GeoPoint({required this.lat, required this.lng, this.accuracy});

  final double lat;
  final double lng;
  final double? accuracy;

  static GeoPoint? fromJsonOrNull(Object? j) => j == null ? null : GeoPoint.fromJson(j as Map<String, dynamic>);

  factory GeoPoint.fromJson(Map<String, dynamic> j) =>
      GeoPoint(lat: _num(j['lat'])!, lng: _num(j['lng'])!, accuracy: _num(j['accuracy']));

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng, if (accuracy != null) 'accuracy': accuracy};
}

class UserInfo {
  const UserInfo({required this.id, required this.name, required this.email, required this.role, this.registration});

  final String id;
  final String name;
  final String email;
  final Role role;
  final String? registration;

  factory UserInfo.fromJson(Map<String, dynamic> j) => UserInfo(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
        role: enumFromApi(Role.values, j['role']),
        registration: j['registration'] as String?,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'email': email, 'role': enumToApi(role), 'registration': registration};

  /// Iniciais para o avatar (ex.: "Helena Prado" → "HP").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return (parts.first[0] + (parts.length > 1 ? parts.last[0] : '')).toUpperCase();
  }
}

class Person {
  const Person({required this.id, required this.name, this.registration});

  final String id;
  final String name;
  final String? registration;

  factory Person.fromJson(Map<String, dynamic> j) =>
      Person(id: j['id'] as String, name: j['name'] as String, registration: j['registration'] as String?);
}

class Contract {
  const Contract({
    required this.id,
    required this.code,
    required this.clientName,
    required this.address,
    this.segment,
    this.responsibleName,
  });

  final String id;
  final String code;
  final String clientName;
  final String address;
  final String? segment;
  final String? responsibleName;

  factory Contract.fromJson(Map<String, dynamic> j) => Contract(
        id: j['id'] as String,
        code: j['code'] as String,
        clientName: j['clientName'] as String,
        address: j['address'] as String,
        segment: j['segment'] as String?,
        responsibleName: j['responsibleName'] as String?,
      );
}

class Checklist {
  const Checklist({required this.id, required this.code, required this.name, required this.itemCount});

  final String id;
  final String code;
  final String name;
  final int itemCount;

  factory Checklist.fromJson(Map<String, dynamic> j) => Checklist(
      id: j['id'] as String, code: j['code'] as String, name: j['name'] as String, itemCount: j['itemCount'] as int);
}

/// Inspetor disponível para atribuição, com a carga de OS de hoje.
class InspectorOption {
  const InspectorOption({required this.id, required this.name, required this.todayCount, this.registration});

  final String id;
  final String name;
  final String? registration;
  final int todayCount;

  factory InspectorOption.fromJson(Map<String, dynamic> j) => InspectorOption(
      id: j['id'] as String,
      name: j['name'] as String,
      registration: j['registration'] as String?,
      todayCount: (j['todayCount'] as num).toInt());
}

class Photo {
  const Photo({required this.id, required this.capturedAt, this.lat, this.lng, this.accuracy});

  final String id;
  final DateTime capturedAt;
  final double? lat;
  final double? lng;
  final double? accuracy;

  factory Photo.fromJson(Map<String, dynamic> j) => Photo(
      id: j['id'] as String,
      capturedAt: _dt(j['capturedAt']),
      lat: _num(j['lat']),
      lng: _num(j['lng']),
      accuracy: _num(j['accuracy']));
}

class ActionPlan {
  const ActionPlan({
    required this.id,
    required this.responsible,
    required this.dueDate,
    required this.action,
    required this.createdBy,
  });

  final String id;
  final String responsible;
  final DateTime dueDate;
  final String action;
  final String createdBy;

  factory ActionPlan.fromJson(Map<String, dynamic> j) => ActionPlan(
      id: j['id'] as String,
      responsible: j['responsible'] as String,
      dueDate: DateTime.parse(j['dueDate'] as String),
      action: j['action'] as String,
      createdBy: j['createdBy'] as String);
}

/// Item de checklist de uma inspeção, com a resposta (quando existir), fotos e planos de ação.
class InspectionItem {
  const InspectionItem({
    required this.id,
    required this.itemNo,
    required this.category,
    required this.statement,
    this.location,
    this.result,
    this.criticality,
    this.description,
    this.recommendedAction,
    this.photos = const [],
    this.actionPlans = const [],
  });

  final String id;
  final int itemNo;
  final String category;
  final String statement;
  final String? location;
  final ItemResult? result;
  final Criticality? criticality;
  final String? description;
  final String? recommendedAction;
  final List<Photo> photos;
  final List<ActionPlan> actionPlans;

  bool get isNonConforming => result == ItemResult.nonConforming;

  factory InspectionItem.fromJson(Map<String, dynamic> j) => InspectionItem(
        id: j['id'] as String,
        itemNo: j['itemNo'] as int,
        category: j['category'] as String,
        statement: j['statement'] as String,
        location: j['location'] as String?,
        result: enumFromApiOrNull(ItemResult.values, j['result']),
        criticality: enumFromApiOrNull(Criticality.values, j['criticality']),
        description: j['description'] as String?,
        recommendedAction: j['recommendedAction'] as String?,
        photos: [for (final p in j['photos'] as List) Photo.fromJson(p as Map<String, dynamic>)],
        actionPlans: [for (final p in j['actionPlans'] as List) ActionPlan.fromJson(p as Map<String, dynamic>)],
      );
}

/// Totais calculados no servidor. [conformityPercent] = conformes / total de itens.
class Stats {
  const Stats({
    required this.total,
    required this.answered,
    required this.conforming,
    required this.nonConforming,
    required this.notApplicable,
    required this.photos,
    required this.conformityPercent,
    this.maxCriticality,
  });

  final int total;
  final int answered;
  final int conforming;
  final int nonConforming;
  final int notApplicable;
  final int photos;
  final Criticality? maxCriticality;
  final double conformityPercent;

  factory Stats.fromJson(Map<String, dynamic> j) => Stats(
        total: j['total'] as int,
        answered: j['answered'] as int,
        conforming: j['conforming'] as int,
        nonConforming: j['nonConforming'] as int,
        notApplicable: j['notApplicable'] as int,
        photos: j['photos'] as int,
        maxCriticality: enumFromApiOrNull(Criticality.values, j['maxCriticality']),
        conformityPercent: _num(j['conformityPercent'])!,
      );
}

/// Linha das listagens (painel e app).
class InspectionSummary {
  const InspectionSummary({
    required this.id,
    required this.number,
    required this.status,
    required this.type,
    required this.urgent,
    required this.scheduledDate,
    required this.shift,
    required this.clientName,
    required this.address,
    required this.checklistCode,
    required this.inspector,
    required this.managerName,
    required this.stats,
    this.startedAt,
    this.finishedAt,
    this.reviewComment,
    this.notes,
  });

  final String id;
  final int number;
  final InspectionStatus status;
  final InspectionType type;
  final bool urgent;
  final DateTime scheduledDate;
  final Shift shift;
  final String clientName;
  final String address;
  final String checklistCode;
  final Person inspector;
  final String managerName;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? reviewComment;
  final String? notes;
  final Stats stats;

  factory InspectionSummary.fromJson(Map<String, dynamic> j) => InspectionSummary(
        id: j['id'] as String,
        number: (j['number'] as num).toInt(),
        status: enumFromApi(InspectionStatus.values, j['status']),
        type: enumFromApi(InspectionType.values, j['type']),
        urgent: j['urgent'] as bool,
        scheduledDate: DateTime.parse(j['scheduledDate'] as String),
        shift: enumFromApi(Shift.values, j['shift']),
        clientName: j['clientName'] as String,
        address: j['address'] as String,
        checklistCode: j['checklistCode'] as String,
        inspector: Person.fromJson(j['inspector'] as Map<String, dynamic>),
        managerName: j['managerName'] as String,
        startedAt: _dtOrNull(j['startedAt']),
        finishedAt: _dtOrNull(j['finishedAt']),
        reviewComment: j['reviewComment'] as String?,
        notes: j['notes'] as String?,
        stats: Stats.fromJson(j['stats'] as Map<String, dynamic>),
      );
}

class TimelineEvent {
  const TimelineEvent({required this.id, required this.type, required this.occurredAt, this.actor, this.detail, this.location});

  final String id;
  final EventType type;
  final String? actor;
  final DateTime occurredAt;
  final String? detail;
  final GeoPoint? location;

  factory TimelineEvent.fromJson(Map<String, dynamic> j) => TimelineEvent(
        id: j['id'] as String,
        type: enumFromApi(EventType.values, j['type']),
        actor: j['actor'] as String?,
        occurredAt: _dt(j['occurredAt']),
        detail: j['detail'] as String?,
        location: GeoPoint.fromJsonOrNull(j['location']),
      );
}

/// Inspeção completa: execução, evidências, planos de ação e trilha de auditoria.
class InspectionDetail {
  const InspectionDetail({
    required this.id,
    required this.number,
    required this.status,
    required this.type,
    required this.urgent,
    required this.scheduledDate,
    required this.shift,
    required this.contract,
    required this.checklistCode,
    required this.checklistName,
    required this.inspector,
    required this.manager,
    required this.hasSignature,
    required this.stats,
    required this.items,
    required this.events,
    this.notes,
    this.startedAt,
    this.startLocation,
    this.finishedAt,
    this.endLocation,
    this.generalNotes,
    this.reviewComment,
    this.reviewedAt,
    this.reviewedBy,
  });

  final String id;
  final int number;
  final InspectionStatus status;
  final InspectionType type;
  final bool urgent;
  final DateTime scheduledDate;
  final Shift shift;
  final String? notes;
  final Contract contract;
  final String checklistCode;
  final String checklistName;
  final Person inspector;
  final Person manager;
  final DateTime? startedAt;
  final GeoPoint? startLocation;
  final DateTime? finishedAt;
  final GeoPoint? endLocation;
  final String? generalNotes;
  final bool hasSignature;
  final String? reviewComment;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final Stats stats;
  final List<InspectionItem> items;
  final List<TimelineEvent> events;

  /// Itens não conformes, na ordem do checklist.
  List<InspectionItem> get nonConformingItems => items.where((i) => i.isNonConforming).toList();

  /// Duração entre o início e o encerramento reais, se ambos existirem.
  Duration? get duration => (startedAt != null && finishedAt != null) ? finishedAt!.difference(startedAt!) : null;

  factory InspectionDetail.fromJson(Map<String, dynamic> j) => InspectionDetail(
        id: j['id'] as String,
        number: (j['number'] as num).toInt(),
        status: enumFromApi(InspectionStatus.values, j['status']),
        type: enumFromApi(InspectionType.values, j['type']),
        urgent: j['urgent'] as bool,
        scheduledDate: DateTime.parse(j['scheduledDate'] as String),
        shift: enumFromApi(Shift.values, j['shift']),
        notes: j['notes'] as String?,
        contract: Contract.fromJson(j['contract'] as Map<String, dynamic>),
        checklistCode: j['checklistCode'] as String,
        checklistName: j['checklistName'] as String,
        inspector: Person.fromJson(j['inspector'] as Map<String, dynamic>),
        manager: Person.fromJson(j['manager'] as Map<String, dynamic>),
        startedAt: _dtOrNull(j['startedAt']),
        startLocation: GeoPoint.fromJsonOrNull(j['startLocation']),
        finishedAt: _dtOrNull(j['finishedAt']),
        endLocation: GeoPoint.fromJsonOrNull(j['endLocation']),
        generalNotes: j['generalNotes'] as String?,
        hasSignature: j['hasSignature'] as bool,
        reviewComment: j['reviewComment'] as String?,
        reviewedAt: _dtOrNull(j['reviewedAt']),
        reviewedBy: j['reviewedBy'] as String?,
        stats: Stats.fromJson(j['stats'] as Map<String, dynamic>),
        items: [for (final i in j['items'] as List) InspectionItem.fromJson(i as Map<String, dynamic>)],
        events: [for (final e in j['events'] as List) TimelineEvent.fromJson(e as Map<String, dynamic>)],
      );
}

/// Resposta paginada.
class PageResult<T> {
  const PageResult({required this.content, required this.total, required this.page, required this.size});

  final List<T> content;
  final int total;
  final int page;
  final int size;
}

class ReviewQueueEntry {
  const ReviewQueueEntry({required this.inspection, required this.waitingMinutes});

  final InspectionSummary inspection;
  final int waitingMinutes;
}

class InspectorLoad {
  const InspectorLoad({required this.inspectorId, required this.name, required this.count});

  final String inspectorId;
  final String name;
  final int count;
}

/// Indicadores do dashboard.
class Dashboard {
  const Dashboard({
    required this.inProgress,
    required this.startedToday,
    required this.awaitingReview,
    required this.awaitingReviewOver12h,
    required this.overdue,
    required this.byStatus,
    required this.reviewQueue,
    required this.inspectorLoadToday,
    this.avgHoursToApproval,
  });

  final int inProgress;
  final int startedToday;
  final int awaitingReview;
  final int awaitingReviewOver12h;
  final int overdue;
  final double? avgHoursToApproval;
  final Map<InspectionStatus, int> byStatus;
  final List<ReviewQueueEntry> reviewQueue;
  final List<InspectorLoad> inspectorLoadToday;

  factory Dashboard.fromJson(Map<String, dynamic> j) => Dashboard(
        inProgress: (j['inProgress'] as num).toInt(),
        startedToday: (j['startedToday'] as num).toInt(),
        awaitingReview: (j['awaitingReview'] as num).toInt(),
        awaitingReviewOver12h: (j['awaitingReviewOver12h'] as num).toInt(),
        overdue: (j['overdue'] as num).toInt(),
        avgHoursToApproval: _num(j['avgHoursToApproval']),
        byStatus: {
          for (final e in (j['byStatus'] as Map<String, dynamic>).entries)
            enumFromApi(InspectionStatus.values, e.key): (e.value as num).toInt()
        },
        reviewQueue: [
          for (final e in j['reviewQueue'] as List)
            ReviewQueueEntry(
              inspection: InspectionSummary.fromJson((e as Map<String, dynamic>)['inspection'] as Map<String, dynamic>),
              waitingMinutes: (e['waitingMinutes'] as num).toInt(),
            )
        ],
        inspectorLoadToday: [
          for (final e in j['inspectorLoadToday'] as List)
            InspectorLoad(
                inspectorId: (e as Map<String, dynamic>)['inspectorId'] as String,
                name: e['name'] as String,
                count: (e['count'] as num).toInt())
        ],
      );
}
