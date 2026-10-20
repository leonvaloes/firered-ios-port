# Implementation Plan: Port nativo de Pokémon FireRed para iPhone

**Branch**: `001-port-nativo-firered` (identificador lógico; diretório sem Git) | **Date**: 2026-10-20 | **Spec**: [spec.md](spec.md)

**Input**: Especificação em `specs/001-port-nativo-firered/spec.md`.

## Summary

Planejar primeiro uma prova de viabilidade jurídica, técnica e de assinatura no aparelho real; depois reconstruir a campanha individual em um app iOS nativo que importa uma ROM local exclusivamente como dados, sem executar código GBA. Inventariar comportamento com evidências estáticas REA/Ghidra e casos de referência reproduzíveis; manter bloqueada qualquer alegação de paridade integral até execução, assinatura, persistência e campanha serem demonstradas. A investigação não equivale a um port funcional.

## Technical Context

**Language/Version**: Swift (versão compatível com o Xcode disponível no runner macOS; fixar versão após prova de build)

**Primary Dependencies**: SDK Apple: SwiftUI para fluxo de importação, SpriteKit para apresentação 2D, Foundation/CryptoKit para validação de arquivo; Ghidra independente e REA MCP para análise onde suportado. Escolhas provisórias, validar em protótipo.

**Storage**: Arquivos privados do container iOS para save versionado e ROM importada; gravação substituível com verificação e recuperação.

**Testing**: XCTest para lógica pura e integração de importação/save; casos de paridade na ROM de referência e testes manuais no iPhone real; build em runner macOS sem credenciais.

**Target Platform**: iPhone 15 Pro Max, iOS 26.6.2 declarado na especificação; runner macOS para compilação, Windows + Sideloadly para assinatura/instalação, sujeitos a confirmação em aparelho.

**Project Type**: aplicativo móvel offline, sem API remota.

**Performance Goals**: Entrada e apresentação responsivas e áudio contínuo no aparelho-alvo; metas numéricas de frame time e latência somente após perfil de protótipo.

**Constraints**: Sem ROM, recursos protegidos ou credenciais em build público; sem emulação de CPU/instruções GBA; importação local e jogo offline; campanhas e recursos não verificados não podem ser anunciados como completos; direitos de uso/distribuição dependem de autorização.

**Scale/Scope**: Campanha individual americana em inglês, com mapas, eventos, gráficos, som, diálogos, inventário, batalha e persistência; troca e comunicação excluídas da primeira entrega.

## Constitution Check

*GATE: Avaliado antes da pesquisa e reavaliado após o design.*

A constituição em `.specify/memory/constitution.md` contém apenas placeholders (`[PRINCIPLE_*]`, `[GOVERNANCE_RULES]`, versão indefinida); não impõe requisitos operacionais verificáveis. **Pré-pesquisa: PASS condicional** — nenhuma violação identificável; não interpretar exemplos comentados como normas. **Pós-design: PASS condicional** — mesmo resultado; se a constituição for ratificada antes da implementação, revisar este plano contra suas regras reais. Gates adicionais da especificação: direitos de redistribuição, build sem conteúdo, assinatura local e preservação do save são **bloqueantes para entrega**, ainda não aprovados; a fase de design não os dispensa.

## Project Structure

### Documentation (this feature)

```text
specs/001-port-nativo-firered/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
    └── user-flows.md
```

### Source Code (proposta; ainda não criado)

```text
ios/FireRedPort/
├── App/                 # entrada, importação, ciclo de vida
├── Domain/              # regras reconstruídas, estado e eventos
├── Resources/           # somente recursos originais do projeto, não da ROM
├── Rendering/           # controles, vídeo e áudio
└── Persistence/         # save versionado e recuperação

ios/FireRedPortTests/    # lógica, importação e persistência
analysis/                # evidências e matriz; nenhuma cópia pública da ROM
.github/workflows/       # build sem assinatura/ROM (somente após validação)
```

**Structure Decision**: Um aplicativo iOS offline separado da documentação de análise e dos testes. Os caminhos de código são estrutura planejada, não arquivos existentes; nenhuma camada de servidor é necessária.

## Phase 0: Research

Decisões, alternativas e incertezas residuais constam de [research.md](research.md). Limitações práticas que só se resolvem com aparelho e credenciais do usuário são critérios de aceitação bloqueantes, não fatos assumidos.

## Phase 1: Design & Contracts

Entidades e invariantes: [data-model.md](data-model.md). Contrato de importação, save, instalação e visibilidade de paridade: [contracts/user-flows.md](contracts/user-flows.md). Cenários executáveis e critérios de parada: [quickstart.md](quickstart.md).

## Complexity Tracking

Nenhuma violação identificável de princípio ratificado; a constituição ainda é um modelo não preenchido.
