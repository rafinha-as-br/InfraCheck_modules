import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:infracheck_modules/infracheck_modules.dart';

void main() {
  test('counts converte o mapa de status do servidor', () async {
    final api = InfraCheckApi(
      baseUrl: 'http://x',
      client: MockClient((_) async => http.Response('{"PENDING":5,"IN_PROGRESS":2,"COMPLETED":4,"APPROVED":3,"REJECTED":1}', 200,
          headers: {'content-type': 'application/json'})),
    );
    final counts = await api.counts();
    expect(counts[InspectionStatus.inProgress], 2);
    expect(counts.values.fold<int>(0, (a, b) => a + b), 15);
  });
}
