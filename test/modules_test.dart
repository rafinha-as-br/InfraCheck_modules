import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:infracheck_modules/infracheck_modules.dart';

void main() {
  setUpAll(() => IcFonts.useGoogleFonts = false);

  group('enums', () {
    test('converte entre o formato da API e o do Dart (ida e volta)', () {
      expect(enumFromApi(InspectionStatus.values, 'IN_PROGRESS'), InspectionStatus.inProgress);
      expect(enumToApi(InspectionStatus.inProgress), 'IN_PROGRESS');
      for (final c in Criticality.values) {
        expect(enumFromApi(Criticality.values, enumToApi(c)), c);
      }
      expect(enumFromApi(ItemResult.values, 'NON_CONFORMING'), ItemResult.nonConforming);
    });

    test('valor desconhecido falha explicitamente', () {
      expect(() => enumFromApi(Shift.values, 'MADRUGADA'), throwsFormatException);
    });

    test('Alta e Crítica exigem plano de ação', () {
      expect(Criticality.low.requiresActionPlan, isFalse);
      expect(Criticality.high.requiresActionPlan, isTrue);
      expect(Criticality.critical.requiresActionPlan, isTrue);
    });
  });

  group('SubmitPayload', () {
    test('preserva os dados na serialização (necessário para a fila offline)', () {
      final p = SubmitPayload(
        startedAt: DateTime.utc(2025, 6, 12, 11, 7),
        startLocation: const GeoPoint(lat: -23.5613, lng: -46.6559, accuracy: 6),
        finishedAt: DateTime.utc(2025, 6, 12, 12, 41),
        endLocation: const GeoPoint(lat: -23.5614, lng: -46.656),
        signaturePngBase64: 'abc',
        generalNotes: 'ok',
        items: const [
          ItemAnswer(itemId: 'i1', result: ItemResult.nonConforming, criticality: Criticality.high, description: 'd'),
          ItemAnswer(itemId: 'i2', result: ItemResult.conforming),
        ],
      );
      final back = SubmitPayload.fromJson(jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>);
      expect(back.items.first.criticality, Criticality.high);
      expect(back.items.last.result, ItemResult.conforming);
      expect(back.endLocation.lat, -23.5614);
      expect(back.startLocation?.accuracy, 6);
      expect(back.finishedAt.isAtSameMomentAs(p.finishedAt), isTrue);
    });
  });

  group('IcFormat', () {
    test('formata no padrão pt-BR', () {
      expect(IcFormat.percent(90.5), '90,5%');
      expect(IcFormat.duration(const Duration(hours: 1, minutes: 34)), '1 h 34 min');
      expect(IcFormat.coordinates(-23.5613, -46.6559), '-23,5613 -46,6559');
      expect(IcFormat.scheduled(DateTime(2025, 6, 12), Shift.morning, now: DateTime(2025, 6, 12, 9)), 'Hoje · manhã');
    });
  });

  group('InfraCheckApi', () {
    test('envia o JWT e converte erro de negócio em ApiError', () async {
      late http.Request seen;
      final api = InfraCheckApi(
        baseUrl: 'http://x',
        client: MockClient((req) async {
          seen = req;
          return http.Response(
              jsonEncode({'code': 'ACTION_PLAN_REQUIRED', 'message': 'Falta plano', 'details': ['Item 04']}), 422,
              headers: {'content-type': 'application/json'});
        }),
      )..token = 'tok';
      await expectLater(
          api.approve('abc'),
          throwsA(isA<ApiError>()
              .having((e) => e.code, 'code', 'ACTION_PLAN_REQUIRED')
              .having((e) => e.fullMessage, 'msg', contains('Item 04'))));
      expect(seen.headers['Authorization'], 'Bearer tok');
      expect(seen.url.path, '/api/v1/inspections/abc/approve');
    });

    test('falha de conexão vira ApiError de rede', () async {
      final api = InfraCheckApi(
          baseUrl: 'http://x', client: MockClient((_) async => throw http.ClientException('offline')));
      await expectLater(api.me(), throwsA(isA<ApiError>().having((e) => e.isNetwork, 'isNetwork', isTrue)));
    });
  });

  testWidgets('StatusBadge mostra ícone e palavra', (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: InfraCheckTheme.light(),
        home: const Scaffold(body: StatusBadge(InspectionStatus.completed))));
    expect(find.text('Concluída'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });
}
