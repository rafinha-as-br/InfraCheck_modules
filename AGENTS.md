# InfraCheck Modules — contexto para agentes

## Propósito

Este repositório é reservado para módulos de front-end compartilháveis do ecossistema InfraCheck. Ele existe para concentrar capacidades reutilizáveis entre as interfaces do projeto, evitando que o app de gestão e o app de inspeção tenham implementações divergentes de conceitos comuns.

O escopo de produto e as fronteiras entre componentes estão descritos em `../../AGENTS.md`.

## Papel no ecossistema

Os módulos compartilhados podem apoiar as interfaces que lidam com entidades e regras comuns — por exemplo, representação de inspeções, checklists, não conformidades, evidências, status e apresentação de dados — desde que haja uma necessidade comprovada de reutilização.

Este repositório **não** é o dono das regras de negócio, da persistência, da segurança de acesso nem da geração de relatórios. Essas responsabilidades permanecem no `InfraCheck_Server`. Ele também não deve absorver fluxos exclusivos do aplicativo do inspetor ou do painel administrativo sem uma justificativa clara.

## Estado e critérios para evoluir

Ainda não há tecnologia, estrutura de pacotes, consumidores, API pública ou convenções de versionamento definidos neste repositório. Antes de adicionar código:

- confirme qual aplicação consumirá o módulo e qual problema compartilhado ele resolve;
- mantenha dependências e interface pública explícitas e mínimas;
- não transforme uma regra temporária de interface em regra de domínio;
- documente decisões de tecnologia e compatibilidade quando elas forem tomadas.

Dados como fotos, localização, assinaturas e informações de clientes devem manter o mesmo cuidado de privacidade aplicado em todo o produto.

## Estado atual (protótipo do MVP)

A tecnologia definida é **Dart/Flutter** (pacote `infracheck_modules`), consumido por caminho relativo pelos dois apps. Contém tema/tokens do design system, modelos e cliente do contrato da API e widgets de status — somente o que os dois apps já usam. Ver `README.md` e `docs/overview.md`. Versionamento do pacote e consumo fora do workspace (dependência Git) ainda não definidos.
