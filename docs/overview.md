# Visão geral do InfraCheck_modules

## Papel

Evita que o app do inspetor e o painel web tenham implementações divergentes de conceitos comuns. Hoje isso
significa três coisas: **tema** (tokens do design system), **contrato da API** e **widgets de status**.

## Dependências

`flutter`, `flutter_svg` (logotipos), `google_fonts` (Barlow, IBM Plex), `http`, `http_parser`.
Os apps consomem por caminho relativo (`../InfraCheck_modules`); para integração contínua será preciso trocar por
dependência Git com tag (decisão de versionamento ainda não tomada).

## Decisões

| Decisão | Motivo |
| --- | --- |
| Enums trafegam em inglês (`IN_PROGRESS`) e viram `inProgress` no Dart (`enumFromApi` / `enumToApi`) | Contrato estável com o servidor; rótulos pt-BR ficam no enum (`label`). |
| `ApiError` único para toda falha de chamada; `isNetwork` distingue "sem conexão" | O app do inspetor trata offline como "tente depois", nunca como perda de dado. |
| `SubmitPayload` tem `toJson` **e** `fromJson` | É o item que o app guarda no aparelho enquanto o envio não é confirmado. |
| Padrão de moldura desenhado em Dart (`FramePattern`) | O `<pattern>` do SVG original falha no CanvasKit (web). |
| Fontes via `google_fonts` | Ficam em cache no aparelho depois do primeiro uso online; empacotar os arquivos de fonte é um aprimoramento para operar 100% offline desde a primeira execução. |
| `ApiImage` busca bytes com o JWT e guarda em memória | Fotos e assinaturas só existem em endpoints autenticados; `Image.network` não enviaria o cabeçalho. |

## Como evoluir

1. Antes de adicionar algo, confirme que **dois** consumidores precisam.
2. Mudou um DTO? Atualize `docs/api.md` do `InfraCheck_Server` e os testes de `modules_test.dart`.
3. Novo widget do design system: reutilize o que existe; documente com o ID canônico quando a sigla do produto existir.
