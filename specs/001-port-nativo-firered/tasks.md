---
description: "Tarefas de implementação do port nativo e suas provas de viabilidade"
---

# Tasks: Port nativo de Pokémon FireRed para iPhone

**Input**: `specs/001-port-nativo-firered/{plan.md,spec.md,research.md,data-model.md,quickstart.md,contracts/user-flows.md}`. Caminhos abaixo são relativos à raiz; muitos arquivos ainda não existem. Não publicar ROM, derivados protegidos nem credenciais. `001-port-nativo-firered` é identificador lógico, não branch Git criada.

**Formato**: `- [ ] T### [P?] [US?] ação em caminho`. `[P]` significa arquivos separados e ausência de dependência de tarefas inacabadas no mesmo grupo. Testes explícitos são necessários pelos cenários de paridade, integridade, instalação e persistência da especificação; escrever critérios/fixtures antes de implementar o comportamento correspondente. Testes no aparelho são gates, não resultados presumidos.

## Phase 1: Setup (infraestrutura compartilhada)

**Objetivo**: proteger a referência local e preparar documentação/estrutura sem distribuir conteúdo.

- [X] T001 Criar `.gitignore` ou atualizar o existente para excluir `*.gba`, ROMs derivadas, extrações, snapshots com conteúdo protegido, artefatos de build, caches, assinaturas e segredos; inspecionar entradas existentes antes de alterar.
- [X] T002 [P] Criar `analysis/README.md` com regra de evidências somente em texto/metadados não protegidos, sem incluir bytes, gráficos, áudio ou dumps da ROM.
- [X] T003 [P] Criar `ios/README.md` com layout `ios/FireRedPort/{App,Domain,Rendering,Persistence,Resources}`, `ios/FireRedPortTests` e pré-requisito de Xcode macOS; não prometer compilação em Windows.
- [X] T004 Registrar em `analysis/toolchain.md` versão instalada do Ghidra, caminho `C:\Tools\Ghidra\Ghidra_12.1.4_build\ghidra_12.1.4_PUBLIC`, disponibilidade de REA, ambiente Windows e passos de importação ARM bruta; não afirmar análise ainda não realizada.

---

## Phase 2: Foundational (pré-requisitos bloqueantes)

**Objetivo**: identidade, rastreabilidade e gates antes de afirmar viabilidade ou usar offsets da ROM.

- [X] T005 Criar `analysis/reference-identity.md` repetindo `Get-FileHash -Algorithm SHA256 -LiteralPath 'Pokemon - FireRed Version (USA).gba'` e tamanho; registrar SHA-256 `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac`, 16777216 bytes, cabeçalho `POKEMON FIRE`/`BPRE`/`01`/versão `00`, complemento e limites de confiança; parar se hash mudar.
- [X] T006 [P] Criar `analysis/evidence-schema.md` para `EvidenciaDeAnalise` com `id`, `arquivoId`, `subsistema`, `afirmacao`, `tipo` (`observado-estatico`, `observado-runtime`, `inferido`, `desconhecido`), `metodo`, `localizacao`, `evidenceId` (quando REA), `limitacoes`, `registradoEm`; toda conclusão deve identificar fonte, método e escopo.
- [X] T007 [P] Criar `analysis/release-gates.md` com critérios jurídicos separados para uso pessoal/distribuição, build público sem ROM/recursos/credenciais, instalação real, save, campanha e 100% dos casos essenciais aprovados; pendente ou divergente significa bloqueado, não aprovado.
- [X] T008 Registrar em `analysis/rea-capability.md` a tentativa REA `raw-binary` ARM com `entry_point=0x08000000` e rejeição `capability_unavailable` do Ghidra Windows P0; verificar estado atual antes de tentar outro provedor e nunca atribuir ao REA observações feitas no Ghidra externo.

**Checkpoint**: identidade e critérios auditáveis estabelecidos; nenhum código ARM pode ser interpretado no app.

---

## Phase 3: User Story 1 — Verificar escopo e viabilidade (P1, MVP)

**Goal**: Relatório reprodutível que separa fatos, inferências e bloqueios; prova de build/assinatura pessoal mínima antes de prometer o port.

**Independent Test**: Conferir hash e cabeçalho, seguir fontes de cada conclusão e matriz, reproduzir build mínimo sem ROM e tentativa de instalação em aparelho, ou registrar explicitamente bloqueio quando aparelho/conta não estiver disponível.

### Casos de validação

- [X] T009 [P] [US1] Definir em `analysis/viability-checklist.md` casos verificáveis para identidade divergente, evidência estática versus runtime, cobertura de subsistemas, direitos, build limpo e instalação assinada; qualquer não executado permanece pendente.
- [X] T010 [P] [US1] Definir em `analysis/parity-matrix.md` `Funcionalidade` com `id`, `subsistema` (inicialização, mapas, gráficos, áudio, entrada, diálogos, itens, batalhas, progressão, eventos, persistência), `descricao`, `escopo` (`campanha`, `comunicacao-futura`), `status` (`nao-verificado`, `parcial`, `testado`), `evidencias[]`; inicialmente não marcar cobertura sem teste em aparelho.

### Investigação e relatório

- [X] T011 [US1] Abrir o arquivo pessoal no Ghidra independente como raw ARM little-endian, verificar base/entrada e cabeçalho antes da autoanálise; registrar procedimento, versão, mapeamento confirmado ou incerto e endereços/offsets investigados em `analysis/ghidra-session.md`, sem copiar código/recursos protegidos para repositório.
- [ ] T012 [US1] Inventariar subsistemas inicialização, mapas, gráficos, áudio, entrada, diálogos, itens, batalhas, progressão, eventos e persistência em `analysis/subsystems.md` com localização, método, cobertura e lacunas; classificar como inferência qualquer comportamento não observado em execução.
- [X] T013 [US1] Criar `analysis/viability-report.md` reunindo `ArquivoDeReferencia` (`id` UUID, `nomeLocal` somente local, `tamanhoBytes` inteiro positivo, `sha256` 64 dígitos hexadecimais, `regiao`, `versao` sujeitas à validação, `origemDeclarada`, `verificadoEm`), evidências rastreáveis, direitos de uso pessoal/distribuição e bloqueios sem afirmar autorização inexistente.
- [X] T014 [US1] Criar projeto iOS mínimo sem ROM em `ios/FireRedPort.xcodeproj/project.pbxproj` com target SwiftUI de importação futura, bundle ID estável e mínimo iOS compatível com aparelho; fixar versão de Xcode somente após confrontar runner disponível, documentando escolha em `ios/README.md`.
- [X] T015 [US1] Criar shell de interface local em `ios/FireRedPort/App/FireRedPortApp.swift` que indique claramente “prova de instalação, jogo não implementado” e não contenha dados extraídos da ROM.
- [X] T016 [US1] Criar `.github/workflows/ios-build.yml` para build/teste de app mínimo em macOS e empacotamento IPA não assinada; impedir upload de ROM, derivados e credenciais e registrar versão efetiva de Xcode. Se exportação não assinada não funcionar no runner, documentar erro e não publicar artefato como instalável.
- [X] T017 [US1] Documentar em `analysis/install-probe.md` download de IPA no Windows, requisitos Sideloadly/iTunes/iCloud, Developer Mode, assinatura só no PC, bundle ID, versão iOS, resultado real de instalação/abertura e falhas; executar no iPhone do usuário quando disponível ou marcar bloqueado, nunca aprovado por hipótese.
- [X] T018 [US1] Aplicar `analysis/viability-checklist.md` e emitir em `analysis/viability-report.md` conclusão condicionada: 100% das afirmações sobre arquivo com origem e limite, matriz sem subsistemas omitidos e alternativa para qualquer bloqueio jurídico/técnico.

**Checkpoint**: MVP = relatório auditável + prova mínima documentada ou bloqueio explícito; não é campanha jogável.

---

## Phase 4: User Story 2 — Jogar a campanha completa (P2)

**Goal**: Regras reconstruídas e experiência offline da campanha individual em inglês sem emulação de CPU, com paridade verificada por caso.

**Independent Test**: Importar ROM idêntica, começar nova partida, exercitar controles, menus, mapas, itens, batalhas e eventos até créditos no iPhone, comparar com casos de referência e deixar comunicação fora de escopo.

### Casos antes da implementação

- [X] T019 [P] [US2] Criar `ios/FireRedPortTests/ROMImportTests.swift` com buffers sintéticos para cabeçalho/hash inválidos, truncamento, limites de ponteiros/contagens, falha de acesso e ausência de rede; nenhum fixture deve conter conteúdo protegido.
- [X] T020 [P] [US2] Criar `ios/FireRedPortTests/GameplayParityTests.swift` com relógio/RNG fixos e fixtures independentes para exploração, diálogos, itens, batalhas, flags e progressão, inicialmente pendentes até comportamento de referência documentado.
- [X] T021 [P] [US2] Completar em `analysis/parity-matrix.md` `CasoDeParidade` com `id`, `funcionalidadeId`, `precondicoes`, `acao`, `resultadoReferencia`, `resultadoIPhone`, `versaoReferenciaSha256`, `ambiente`, `status` (`pendente`, `aprovado`, `divergente`, `bloqueado`), `evidencias[]`; documentar referência e percurso até créditos sem preencher resultados não executados.

### Modelos, serviços e apresentação

- [X] T022 [US2] Definir em `ios/FireRedPort/Domain/ReferenceProfile.swift` allowlist para hash integral verificado (`sha256` 64 dígitos hexadecimais), tamanho positivo, região/versão validadas e limites de tabelas; hash diferente resulta incompatível sem uso de offsets.
- [X] T023 [US2] Implementar em `ios/FireRedPort/Domain/ROMDataReader.swift` leitura somente de dados com verificações de faixa/alocação e perfis de estruturas confirmadas em `analysis/subsystems.md`; não carregar nem executar instruções ARM/GBA em tempo de execução.
- [X] T024 [US2] Implementar em `ios/FireRedPort/App/ROMImportView.swift` `fileImporter` com acesso security-scoped corretamente encerrado, hash CryptoKit integral antes da cópia privada, aviso de direitos, mensagens para ROM desconhecida/truncada/falta de espaço e seleção novamente; jamais enviar dados a servidor.
- [X] T025 [US2] Definir em `ios/FireRedPort/Domain/GameState.swift` estado independente do SpriteKit para jogador, posição, equipe, inventário, flags, mundo e RNG, com invariantes derivadas da referência e sem troca/online.
- [X] T026 [US2] Implementar em `ios/FireRedPort/Domain/OverworldEngine.swift` criação de personagem, mapas, movimento, interação, diálogos, eventos e progressão da campanha documentada; cada regra deve apontar caso de `analysis/parity-matrix.md`.
- [X] T027 [US2] Implementar em `ios/FireRedPort/Domain/BattleEngine.swift` regras determinísticas de confronto, itens, equipe e resultados da campanha com cenários rastreáveis na matriz, sem afirmar paridade para mecânicas ainda não testadas.
- [X] T028 [US2] Implementar em `ios/FireRedPort/Rendering/GameScene.swift` cena SpriteKit e controles por toque para movimento, interação, confirmação, cancelamento e menu, renderizando estado sem tornar nós autoridade das regras.
- [X] T029 [US2] Implementar em `ios/FireRedPort/Rendering/GameAudio.swift` áudio local derivado somente após importação autorizada, tratamento de interrupções/silêncio e ciclo de vida; não empacotar áudio original em `ios/FireRedPort/Resources/`.
- [X] T030 [US2] Integrar importação, nova partida, cena, menus e estados de erro em `ios/FireRedPort/App/FireRedPortApp.swift`; funcionamento offline após importação, orientação e retomada de interrupções não devem simular comunicação.
- [ ] T031 [US2] Executar testes XCTest e roteiro completo em iPhone real; registrar em `analysis/campaign-run.md` dispositivo/versão, evidências dos créditos, divergências e casos aprovados/pendentes; somente atualizar `analysis/parity-matrix.md` para `testado` quando todos os casos essenciais da funcionalidade estiverem aprovados.

**Checkpoint**: campanha só é declarada jogável após execução até créditos; ausência de aparelho ou qualquer divergência bloqueia aprovação, embora código possa existir.

---

## Phase 5: User Story 3 — Retomar e instalar no próprio aparelho (P3)

**Goal**: Save confiável e instalação/renovação pessoal demonstradas sem Mac local e sem perda automática de progresso.

**Independent Test**: Salvar/fechar/reiniciar/restaurar 20 vezes no aparelho; renovar assinatura por cima com mesma conta/bundle ID após prazo gratuito e restaurar save sem exportação manual.

### Casos antes da implementação

- [X] T032 [P] [US3] Criar `ios/FireRedPortTests/SaveStoreTests.swift` com round-trip, mismatch de ROM, schema desconhecido, corrupção, interrupção, armazenamento insuficiente, saves concorrentes e recuperação do último snapshot íntegro; dados sintéticos somente.
- [X] T033 [P] [US3] Criar `analysis/save-install-test-plan.md` com tabela para 20 ciclos salvar → encerrar → reiniciar iPhone → restaurar, teste de renovação gratuita por cima, mesma conta e bundle ID, critérios de falha e backup de contingência que não substitui preservação automática.

### Persistência e entrega

- [X] T034 [US3] Definir `PartidaSalva` em `ios/FireRedPort/Persistence/SaveSnapshot.swift` com `schemaVersion`, `referenceSha256` (compatível com hash integral da ROM), `slotId`, `revision`, `savedAt`, `integrityDigest`, `player`, `position`, `party`, `inventory`, `progressFlags`, `worldState`, `battleState` (somente se permitido salvar), `randomState` (se exigido para resultados determinísticos); rejeitar versões desconhecidas e dados inválidos sem sobrescrever backup.
- [X] T035 [US3] Implementar em `ios/FireRedPort/Persistence/SaveStore.swift` escrita serializada em Application Support com transições `em-memoria` → `gravando-temporario` → `validando` → `ativo`, backup íntegro e leitura verificada; falha mantém último save válido e expõe erro, migração preserva backup e recusa downgrade desconhecido.
- [X] T036 [US3] Integrar Salvar/Continuar, alerta de falha e opção de recuperação em `ios/FireRedPort/App/SaveMenuView.swift`; não exibir sucesso antes de validar gravação e nunca sobrescrever progresso silenciosamente.
- [X] T037 [US3] Registrar em `analysis/install-renewal.md` `EntregaInstalavel`: `buildId`, `version`, `bundleId`, `artifactSha256`, `romIncluida=false`, `credenciaisIncluidas=false`, `runner`, `dispositivo`, `iosVersion`, `assinatura` (`nao-assinada`, `assinada-localmente`, `expirada`, `revogada`), `instalacaoStatus`, `resultadoRenovacao`, `limitacoes`, `evidencias[]`; confirmar ausência de ROM/credenciais em código, logs, caches e IPA antes de publicar.
- [ ] T038 [US3] Executar `analysis/save-install-test-plan.md` no iPhone 15 Pro Max iOS 26.6.2 e registrar resultados em `analysis/save-install-results.md`: exigir 20/20 saves corretos e renovação por cima sem exportação manual; se indisponível/falhar, marcar entrega bloqueada e nunca inferir sucesso do simulador.

**Checkpoint**: instalação assinada e retenção de dados têm evidência de aparelho real; período de sete dias e limites de conta gratuita são informados ao usuário.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T039 [P] Atualizar `specs/001-port-nativo-firered/quickstart.md` com caminhos, scheme, versão real de Xcode, comandos testados e bloqueios reais, sem exemplos de projeto apresentados como executados.
- [ ] T040 [P] Registrar em `analysis/usability-results.md` cinco sessões de uso de movimento, diálogo, batalha e save, exigindo pelo menos quatro sem instrução adicional; corrigir falhas no arquivo responsável antes de aprovar usabilidade.
- [ ] T041 Revisar `analysis/release-gates.md` contra `analysis/parity-matrix.md`, `analysis/campaign-run.md`, `analysis/install-renewal.md` e `analysis/save-install-results.md`; impedir alegação “100% funcional” com caso essencial não implementado/não verificado, preservar comunicação fora de escopo e negar publicação de conteúdo protegido sem direitos demonstrados.

---

## Dependencies & Execution Order

```text
Phase 1 (T001–T004) → Phase 2 (T005–T008) → US1 (T009–T018)
                                           └→ US2 (T019–T031) → US3 (T032–T038)
US1 + US2 + US3 → Polish (T039–T041)
```

- **US1** inicia após fundação; T011 depende de T005/T008; T012 depende de T011; T013/T018 dependem das evidências e checklist; T014 → T015 → T016 → T017, e conclusão T018 requer resultado registrado. Se instalação mínima for impossível, documentar bloqueio e não anunciar viabilidade.
- **US2** depende da identidade e dos dados confirmados na investigação US1 (T011–T012), mas seus testes sintéticos (T019–T020) e matriz (T021) podem começar após fundação. T022 → T023 → T024; T025 → T026/T027 → T028/T029 → T030 → T031. Completar caso a caso, sem depender de direitos de publicação presumidos.
- **US3** testes/roteiro T032–T033 podem iniciar após fundação; T034 → T035 → T036; T037 depende de build real T016 e instalação T017; T038 depende de T035–T037 e app integrável T030. Portanto entrega de US3 depende da experiência mínima de US2, embora o módulo de save seja testável isoladamente com estado sintético.
- **Polish** exige resultados existentes, não conclusões presumidas. Gates jurídicos de distribuição e de instalação pessoal são distintos.

### Parallel execution examples

- **US1**: T009 (checklist) e T010 (matriz) em paralelo; após T014, investigação T011/T012 usa `analysis/` enquanto implementação do shell T015/T016 usa `ios/` e `.github/`. Não executar T012 antes de T011.
- **US2**: T019, T020 e T021 em arquivos separados; após T025, T026 e T027 tratam regras diferentes; T028 e T029 podem ser feitos em arquivos distintos após interfaces de estado estabilizadas. T030 espera ambos.
- **US3**: T032 e T033 em paralelo; após T035, T036 (UI) e T037 (inventário de entrega, se build disponível) podem avançar em arquivos separados; T038 espera instalação e save reais.

## Implementation Strategy

1. **MVP (US1)**: setup → fundação → relatório e prova mínima ou bloqueio explícito. Não declarar que já existe jogo.
2. **Incremento campanha (US2)**: casos sintéticos e referência → parser de dados limitado por hash → regras nativas → UI/áudio → execução completa no iPhone. Qualquer função não verificada permanece pendente.
3. **Incremento uso pessoal (US3)**: snapshot/recuperação → 20/20 retomas → assinatura local e renovação por cima verificadas; falha bloqueia aprovação final.
4. **Entrega**: reconciliar matriz, licença/direitos, build sem conteúdo e resultados de aparelho. Não publicar ROM/recursos nem usar “100% funcional” enquanto houver pendências.

## Phase 7: Convergence

- [ ] T042 Completar o inventário dirigido de rotinas, estruturas, método, cobertura e lacunas para os 11 subsistemas em `analysis/subsystems.md`, preservando distinção entre evidência estática e execução, per FR-001 (partial).
- [X] T043 Verificar condições jurídicas separadas para uso pessoal e eventual distribuição; documentar fonte, responsável e bloqueios sem presumir autorização em `analysis/viability-report.md` e `analysis/release-gates.md`, per FR-003 (partial).
- [ ] T044 Validar o projeto mínimo e o workflow em runner macOS real, registrar Xcode/artefato/erros e ensaiar assinatura e abertura no iPhone pelo Windows do usuário ou manter gate bloqueado, per FR-004 (partial).
- [X] T045 Adicionar target XCTest ao `ios/FireRedPort.xcodeproj/project.pbxproj`, ligar adaptadores das três suítes sintéticas às APIs de produção, remover `XCTSkip` dos casos implementáveis e registrar execução real; não contar skips como aprovação, per plan: Testing (partial).
- [ ] T046 Integrar `ROMImportView` e leitor no target/app, confirmar perfis e limites por evidência antes de liberar extração; testar importação local de identidade correta/incorreta e operação offline sem envio a servidores, per FR-012 (partial).
- [X] T047 Implementar `ios/FireRedPort/Domain/GameState.swift` como estado autoritativo do jogador, mundo, equipe, inventário, eventos e RNG derivado de evidências, sem comunicação, per FR-005 (missing).
- [X] T048 Implementar `ios/FireRedPort/Domain/OverworldEngine.swift` com criação, mapas, interação, diálogos, eventos e progressão da campanha rastreados a casos de referência, per FR-005 (missing).
- [X] T049 Implementar `ios/FireRedPort/Domain/BattleEngine.swift` com resultados determinísticos e regras de campanha verificáveis, sem reivindicar mecânicas não observadas, per FR-005 (missing).
- [X] T050 Implementar `ios/FireRedPort/Rendering/GameScene.swift` com SpriteKit e controles acessíveis por toque, sem fazer dos nós a autoridade das regras, per FR-007 (missing).
- [X] T051 Implementar `ios/FireRedPort/Rendering/GameAudio.swift` para áudio local após importação autorizada e tratamento de silêncio/interrupções, sem recurso original no bundle, per FR-007 (missing).
- [ ] T052 Vincular `SaveSnapshot` e `SaveStore` ao estado real, verificar round-trip, erro de gravação, corrupção, schema e recuperação sem perda silenciosa com testes executados, per FR-008 (partial).
- [X] T053 Criar `ios/FireRedPort/App/SaveMenuView.swift` com Salvar/Continuar, erro visível e recuperação explícita, confirmando sucesso somente após gravação validada, per FR-008 (missing).
- [ ] T054 Observar resultados da referência em cenários reproduzíveis, definir casos essenciais após inventário e registrar comparações/divergências reais no iPhone em `analysis/parity-matrix.md`, per FR-009 (partial).
- [ ] T055 Integrar app jogável e executar campanha individual inglesa até créditos no iPhone, documentando build, aparelho, resultados e falhas em `analysis/campaign-run.md` sem aprovar antecipadamente, per SC-003 (missing).
- [ ] T056 Executar 20 ciclos consecutivos de salvar, encerrar, reiniciar e retomar no aparelho; registrar cada resultado e bloquear aprovação se qualquer ciclo falhar, per SC-004 (missing).
- [ ] T057 Realizar cinco sessões de uso de movimento, diálogo, batalha e save, corrigir problemas e registrar se ao menos quatro dispensam instruções adicionais, per SC-006 (missing).
- [ ] T058 Reavaliar `analysis/release-gates.md` após os testes e confrontar cada caso essencial, exceção de comunicação, restrição de instalação e direitos antes de qualquer afirmação de conclusão, per FR-010 (partial).
- [X] T059 Ajustar `.github/workflows/ios-build.yml` para compilar e testar fontes integradas sem relaxar a exclusão de ROM, derivados e segredos em checkout, logs, caches e IPA; validar artefato real antes do upload, per FR-012 (partial).
- [ ] T060 Ensaiar renovação legítima da assinatura gratuita por cima no iPhone com mesma conta e bundle ID, sem exportação manual, e registrar retenção ou falha do save em `analysis/install-renewal.md`, per FR-013 (partial).
