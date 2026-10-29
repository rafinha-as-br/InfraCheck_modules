/// Módulos Flutter compartilhados do InfraCheck.
///
/// - Tema e tokens do design system: [InfraCheckTheme], [IcColors], [IcSpacing], [IcRadius].
/// - Contrato da API: modelos ([InspectionDetail] ...), [InfraCheckApi], [SubmitPayload].
/// - Widgets de status e utilitários: [StatusBadge], [CriticalityBadge], [IcNotice], [IcLogo], [IcFormat].
library;

export 'src/api/api_client.dart';
export 'src/api/submit_payload.dart';
export 'src/format.dart';
export 'src/models/enums.dart';
export 'src/models/models.dart';
export 'src/theme/theme.dart';
export 'src/theme/tokens.dart';
export 'src/widgets/api_image.dart';
export 'src/widgets/badges.dart';
export 'src/widgets/frame_pattern.dart';
export 'src/widgets/logo.dart';
export 'src/widgets/notice.dart';
