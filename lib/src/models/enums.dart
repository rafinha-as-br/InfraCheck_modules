/// Enums do contrato da API, com rótulos em português (vocabulário fixo do design system).
///
/// Na rede os valores trafegam como constantes em inglês (`IN_PROGRESS`); aqui viram `inProgress`.
library;

/// Converte `IN_PROGRESS` em `inProgress` e procura o valor correspondente.
T enumFromApi<T extends Enum>(List<T> values, Object? raw) {
  final name = _toCamel(raw as String);
  return values.firstWhere((v) => v.name == name, orElse: () => throw FormatException('Valor inesperado: $raw'));
}

/// Variante tolerante: `null` quando [raw] é nulo.
T? enumFromApiOrNull<T extends Enum>(List<T> values, Object? raw) => raw == null ? null : enumFromApi(values, raw);

/// Converte `inProgress` em `IN_PROGRESS` para enviar à API.
String enumToApi(Enum e) =>
    e.name.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]}').toUpperCase();

String _toCamel(String upperSnake) {
  final parts = upperSnake.toLowerCase().split('_');
  return parts.first + parts.skip(1).map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1)).join();
}

/// Papéis de acesso.
enum Role {
  admin('Administrador'),
  contractManager('Gestor de contrato'),
  inspector('Inspetor');

  const Role(this.label);
  final String label;

  /// Administrador e Gestor de Contrato usam o painel web e revisam inspeções.
  bool get isManagement => this == admin || this == contractManager;
}

/// Ciclo de vida da inspeção: pendente → em andamento → concluída → aprovada | rejeitada.
enum InspectionStatus {
  pending('Pendente'),
  inProgress('Em andamento'),
  completed('Concluída'),
  approved('Aprovada'),
  rejected('Rejeitada');

  const InspectionStatus(this.label);
  final String label;
}

enum InspectionType {
  preventive('Preventiva periódica'),
  corrective('Corretiva pós-ocorrência'),
  preDelivery('Pré-entrega / recebimento'),
  audit('Auditoria contratual'),
  emergency('Emergencial');

  const InspectionType(this.label);
  final String label;

  /// Emergenciais recebem o selo "Urgente".
  bool get isUrgent => this == emergency;
}

enum Shift {
  morning('Manhã'),
  afternoon('Tarde'),
  night('Noite');

  const Shift(this.label);
  final String label;
}

/// Resultado de um item do checklist.
enum ItemResult {
  conforming('Conforme'),
  nonConforming('Não conforme'),
  notApplicable('N/A');

  const ItemResult(this.label);
  final String label;
}

/// Criticidade de uma não conformidade, da menor para a maior.
enum Criticality {
  low('Baixa'),
  medium('Média'),
  high('Alta'),
  critical('Crítica');

  const Criticality(this.label);
  final String label;

  /// Alta e Crítica exigem plano de ação antes da aprovação.
  bool get requiresActionPlan => this == high || this == critical;

  /// Quantidade de barras de sinal (1 a 4) usadas no selo de criticidade.
  int get level => index + 1;
}

enum EventType {
  created,
  started,
  submitted,
  synced,
  actionPlanSaved,
  approved,
  rejected,
}
