# InfraCheck_modules

Pacote Dart/Flutter `infracheck_modules` com o que o app do inspetor e o painel de gestão compartilham:
tema do design system, contrato da API (modelos + cliente HTTP) e widgets de status.

> **Estado: protótipo do MVP.** A composição e a versão deste pacote ainda não foram decididas formalmente (ver
> `AGENTS.md`). O que está aqui foi extraído porque os **dois** apps já consomem — nada de uso hipotético.

## Uso

Dentro do workspace, os apps referenciam o pacote por caminho relativo:

```yaml
dependencies:
  infracheck_modules:
    path: ../InfraCheck_modules
```

```dart
import 'package:infracheck_modules/infracheck_modules.dart';

MaterialApp(theme: InfraCheckTheme.light(), ...);
final api = InfraCheckApi(baseUrl: 'http://localhost:8080');
```

## Conteúdo

| Área | Arquivos | O que oferece |
| --- | --- | --- |
| Tema | `theme/tokens.dart`, `theme/theme.dart` | `IcColors`, `IcSpacing`, `IcRadius`, `IcShadows`, `InfraCheckTheme.light()`, `IcText.mono` |
| Contrato da API | `models/enums.dart`, `models/models.dart` | Enums com rótulos pt-BR e DTOs imutáveis (`InspectionSummary`, `InspectionDetail`, `Dashboard` ...) |
| Cliente HTTP | `api/api_client.dart`, `api/submit_payload.dart` | `InfraCheckApi`, `ApiError` (erro único; `isNetwork` = sem conexão), `SubmitPayload` |
| Widgets | `widgets/*` | `StatusBadge`, `ResultBadge`, `CriticalityBadge`, `UrgentBadge`, `IcNotice`, `IcLogo`, `FramePattern`, `ApiImage` |
| Formatação | `format.dart` | `IcFormat` (datas, horas, duração, coordenadas, percentual em pt-BR) |
| Assets | `assets/logos/`, `assets/patterns/` | Logotipos SVG do design system |

## Regras

- Sem regra de negócio: validações e decisões ficam no `InfraCheck_Server`.
- Não colocar aqui telas ou fluxos exclusivos de um app.
- Valores de cor/tamanho sempre pelos tokens; widgets novos que representem um componente do design system
  devem citar o ID canônico no docstring (`Design System ID: <sigla>.<tipo>.<subtipo>`) — a sigla oficial do
  produto ainda não foi definida, então os widgets atuais não têm ID canônico.

## Testes

```bash
flutter pub get && flutter analyze && flutter test
```

Cobrem conversão de enums, ida e volta do `SubmitPayload`, formatação, tratamento de erros do cliente HTTP e o
`StatusBadge`. Os testes definem `IcFonts.useGoogleFonts = false` para não buscar fontes na rede.

Documentação adicional em [docs/](docs/overview.md).
