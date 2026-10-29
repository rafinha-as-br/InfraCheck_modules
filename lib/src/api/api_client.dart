import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/enums.dart';
import '../models/models.dart';
import 'submit_payload.dart';

/// Erro único das chamadas à API (contrato de erro da stack).
///
/// - Erros de negócio vêm do servidor com [code] estável (ex.: `ACTION_PLAN_REQUIRED`) e [details] legíveis.
/// - Falhas de conexão/timeout têm [isNetwork] `true`: no app do inspetor significam "tente depois",
///   nunca perda de dado.
class ApiError implements Exception {
  const ApiError({required this.status, required this.code, required this.message, this.details = const []});

  /// Sem resposta do servidor (offline, DNS, timeout).
  factory ApiError.network() => const ApiError(
      status: 0, code: 'NETWORK', message: 'Sem conexão com o servidor. Tente novamente quando o sinal voltar.');

  final int status;
  final String code;
  final String message;
  final List<String> details;

  bool get isNetwork => status == 0;
  bool get isUnauthorized => status == 401;

  /// Mensagem para a UI: texto principal seguido dos detalhes, quando houver.
  String get fullMessage => details.isEmpty ? message : '$message\n• ${details.join('\n• ')}';

  @override
  String toString() => 'ApiError($status $code: $message)';
}

/// Resultado do login.
class LoginResult {
  const LoginResult({required this.token, required this.expiresAt, required this.user});

  final String token;
  final DateTime expiresAt;
  final UserInfo user;
}

/// Cliente HTTP da API REST do InfraCheck (`/api/v1`), compartilhado pelo app e pelo painel.
///
/// Guarda o JWT em [token]. Quando o servidor responde 401, chama [onUnauthorized] para que a camada
/// de sessão leve o usuário ao login.
class InfraCheckApi {
  InfraCheckApi({required this.baseUrl, http.Client? client, this.timeout = const Duration(seconds: 20)})
      : _client = client ?? http.Client();

  /// Endereço do servidor, sem barra final (ex.: `http://localhost:8080`).
  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  String? token;
  void Function()? onUnauthorized;

  // ------------------------------------------------------------------ autenticação

  Future<LoginResult> login(String email, String password) async {
    final j = await _json('POST', '/auth/login', body: {'email': email, 'password': password}, auth: false);
    return LoginResult(
      token: j['token'] as String,
      expiresAt: DateTime.parse(j['expiresAt'] as String).toLocal(),
      user: UserInfo.fromJson(j['user'] as Map<String, dynamic>),
    );
  }

  Future<UserInfo> me() async => UserInfo.fromJson(await _json('GET', '/auth/me'));

  // ------------------------------------------------------------------ consultas

  Future<PageResult<InspectionSummary>> listInspections({
    InspectionStatus? status,
    String? inspectorId,
    InspectionType? type,
    String? q,
    int page = 0,
    int size = 20,
  }) async {
    final j = await _json('GET', '/inspections', query: {
      if (status != null) 'status': enumToApi(status),
      if (inspectorId != null) 'inspectorId': inspectorId,
      if (type != null) 'type': enumToApi(type),
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      'page': '$page',
      'size': '$size',
    });
    return PageResult(
      content: [for (final e in j['content'] as List) InspectionSummary.fromJson(e as Map<String, dynamic>)],
      total: (j['total'] as num).toInt(),
      page: j['page'] as int,
      size: j['size'] as int,
    );
  }

  Future<Map<InspectionStatus, int>> counts() async {
    final j = await _json('GET', '/inspections/counts');
    return {for (final e in j.entries) enumFromApi(InspectionStatus.values, e.key): (e.value as num).toInt()};
  }

  Future<InspectionDetail> getInspection(String id) async => InspectionDetail.fromJson(await getInspectionJson(id));

  /// JSON bruto da inspeção. O app do inspetor guarda esse texto no aparelho para trabalhar offline.
  Future<Map<String, dynamic>> getInspectionJson(String id) => _json('GET', '/inspections/$id');

  /// JSON bruto da listagem (`content` = itens de [InspectionSummary]); usado para o cache offline do app.
  Future<Map<String, dynamic>> listInspectionsJson({int size = 200}) =>
      _json('GET', '/inspections', query: {'size': '$size'});

  Future<Dashboard> dashboard() async => Dashboard.fromJson(await _json('GET', '/dashboard'));

  Future<List<Contract>> contracts() async =>
      [for (final e in await _jsonList('/contracts')) Contract.fromJson(e as Map<String, dynamic>)];

  Future<List<Checklist>> checklists() async =>
      [for (final e in await _jsonList('/checklists')) Checklist.fromJson(e as Map<String, dynamic>)];

  Future<List<InspectorOption>> inspectors() async =>
      [for (final e in await _jsonList('/inspectors')) InspectorOption.fromJson(e as Map<String, dynamic>)];

  /// Bytes da foto (endpoint autenticado: `Image.network` sem cabeçalho não funciona).
  Future<Uint8List> photoBytes(String photoId) => _bytes('/photos/$photoId/content');

  Future<Uint8List> signatureBytes(String inspectionId) => _bytes('/inspections/$inspectionId/signature');

  // ------------------------------------------------------------------ gestão

  Future<InspectionDetail> createInspection({
    required String contractId,
    required String checklistId,
    required String inspectorId,
    required InspectionType type,
    required DateTime scheduledDate,
    required Shift shift,
    String? notes,
  }) async =>
      InspectionDetail.fromJson(await _json('POST', '/inspections', body: {
        'contractId': contractId,
        'checklistId': checklistId,
        'inspectorId': inspectorId,
        'type': enumToApi(type),
        'scheduledDate': _date(scheduledDate),
        'shift': enumToApi(shift),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      }));

  Future<InspectionDetail> addActionPlan(
    String inspectionId, {
    required String itemId,
    required String responsible,
    required DateTime dueDate,
    required String action,
  }) async =>
      InspectionDetail.fromJson(await _json('POST', '/inspections/$inspectionId/action-plans',
          body: {'itemId': itemId, 'responsible': responsible, 'dueDate': _date(dueDate), 'action': action}));

  Future<InspectionDetail> approve(String inspectionId) async =>
      InspectionDetail.fromJson(await _json('POST', '/inspections/$inspectionId/approve'));

  Future<InspectionDetail> reject(String inspectionId, String reason) async =>
      InspectionDetail.fromJson(await _json('POST', '/inspections/$inspectionId/reject', body: {'reason': reason}));

  // ------------------------------------------------------------------ campo

  /// Marca o início em campo (idempotente no servidor).
  Future<InspectionDetail> startInspection(String id, DateTime startedAt, GeoPoint location) async =>
      InspectionDetail.fromJson(await _json('POST', '/inspections/$id/start',
          body: {'startedAt': startedAt.toUtc().toIso8601String(), 'location': location.toJson()}));

  /// Envia uma foto (idempotente: [photoId] é gerado no aparelho).
  Future<void> uploadPhoto({
    required String inspectionId,
    required String photoId,
    required String itemId,
    required Uint8List bytes,
    required DateTime capturedAt,
    GeoPoint? location,
    String contentType = 'image/jpeg',
  }) async {
    final req = http.MultipartRequest('PUT', _uri('/inspections/$inspectionId/photos/$photoId'))
      ..headers.addAll(_headers())
      ..fields['itemId'] = itemId
      ..fields['capturedAt'] = capturedAt.toUtc().toIso8601String()
      ..files.add(http.MultipartFile.fromBytes('file', bytes,
          filename: '$photoId.${contentType.split('/').last}', contentType: MediaType.parse(contentType)));
    if (location != null) {
      req.fields['lat'] = '${location.lat}';
      req.fields['lng'] = '${location.lng}';
      if (location.accuracy != null) req.fields['accuracy'] = '${location.accuracy}';
    }
    await _guard(() async {
      final res = await http.Response.fromStream(await _client.send(req).timeout(timeout * 3));
      _check(res);
    });
  }

  /// Conclui a inspeção com o pacote completo da execução (as fotos devem ter sido enviadas antes).
  Future<InspectionDetail> submit(String inspectionId, SubmitPayload payload) async =>
      InspectionDetail.fromJson(await _json('POST', '/inspections/$inspectionId/submit', body: payload.toJson()));

  void close() => _client.close();

  // ------------------------------------------------------------------ infraestrutura

  Uri _uri(String path, [Map<String, String>? query]) {
    final u = Uri.parse('$baseUrl/api/v1$path');
    return query == null || query.isEmpty ? u : u.replace(queryParameters: query);
  }

  Map<String, String> _headers({bool auth = true, bool json = false}) => {
        if (json) 'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (auth && token != null) 'Authorization': 'Bearer $token',
      };

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>> _json(String method, String path,
      {Map<String, String>? query, Map<String, dynamic>? body, bool auth = true}) async {
    final res = await _request(method, path, query: query, body: body, auth: auth);
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _jsonList(String path) async {
    final res = await _request('GET', path);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  Future<Uint8List> _bytes(String path) async => (await _request('GET', path)).bodyBytes;

  Future<http.Response> _request(String method, String path,
      {Map<String, String>? query, Map<String, dynamic>? body, bool auth = true}) {
    return _guard(() async {
      final req = http.Request(method, _uri(path, query))
        ..headers.addAll(_headers(auth: auth, json: body != null));
      if (body != null) req.body = jsonEncode(body);
      final res = await http.Response.fromStream(await _client.send(req).timeout(timeout));
      _check(res);
      return res;
    });
  }

  /// Converte falhas de transporte em [ApiError.network].
  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on ApiError {
      rethrow;
    } on TimeoutException {
      throw ApiError.network();
    } on http.ClientException {
      throw ApiError.network();
    }
  }

  void _check(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    if (res.statusCode == 401) onUnauthorized?.call();
    var code = 'HTTP_${res.statusCode}';
    var message = 'Não foi possível concluir a operação.';
    var details = <String>[];
    try {
      final j = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      code = j['code'] as String? ?? code;
      message = j['message'] as String? ?? message;
      details = [for (final d in (j['details'] as List? ?? const [])) d as String];
    } catch (_) {
      // Corpo sem JSON (ex.: erro de proxy): mantém a mensagem genérica.
    }
    throw ApiError(status: res.statusCode, code: code, message: message, details: details);
  }
}
