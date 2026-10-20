# Feature Specification: Port nativo de Pokémon FireRed para iPhone

**Feature Branch**: `não criada (diretório sem Git)`

**Created**: 2026-10-20

**Status**: Escopo confirmado — prova de viabilidade pendente

**Input**: Engenharia reversa de `Pokemon - FireRed Version (USA).gba` na raiz do projeto, seguida de um port para iPhone, instalável com Sideloadly sem Mac, integralmente funcional e nativo, sem emulador. O usuário solicitou Ghidra e REA MCP; Ghidra está em `C:\Tools\Ghidra\Ghidra_12.1.4_build\ghidra_12.1.4_PUBLIC`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Verificar escopo e viabilidade (Priority: P1)

Como responsável pelo projeto, quero conhecer a identidade do arquivo, os subsistemas a reconstruir e as restrições de direitos, compilação, assinatura e instalação antes de investir no port, para não confundir análise inicial com garantia de entrega. A investigação usará REA MCP e o Ghidra instalado no caminho indicado sempre que o alvo for admitido pelo provedor; limitações da integração serão documentadas.

**Why this priority**: O objetivo completo depende dessas condições; um bloqueio deve ser descoberto antes de prometer um aplicativo funcional.

**Independent Test**: Examinar o relatório de viabilidade e reproduzir suas verificações de identidade e cobertura sem instalar um aplicativo.

**Acceptance Scenarios**:

1. **Given** o arquivo da raiz, **When** a avaliação termina, **Then** o relatório identifica a versão/região e o resumo criptográfico do arquivo, documenta os subsistemas relevantes, fatos observados, inferências e lacunas.
2. **Given** uma restrição de direitos ou uma etapa necessária à instalação que não possa ser cumprida sem Mac, **When** ela é verificada, **Then** o relatório registra o bloqueio e uma alternativa condicionada, sem declarar o port pronto.

---

### User Story 2 - Jogar a campanha completa (Priority: P2)

Como jogador no iPhone, quero iniciar uma nova partida, percorrer a campanha da versão analisada e concluí-la com o comportamento do jogo original, sem executar uma máquina virtual do console.

**Why this priority**: É o objetivo principal solicitado, mas depende da viabilidade comprovada na primeira etapa.

**Independent Test**: Percorrer um roteiro de marcos da campanha no aparelho, com confrontos, mapas, menus e eventos, comparando resultados com a versão de referência.

**Acceptance Scenarios**:

1. **Given** uma instalação válida no iPhone 15 Pro Max (iOS 26.6.2), **When** importo minha ROM local e inicio uma partida, **Then** consigo criar o personagem, mover-me, conversar, batalhar, usar menus e atingir os créditos offline, sem travamentos impeditivos.
2. **Given** recursos e regras da versão americana em inglês, **When** executo os mesmos cenários documentados, **Then** eventos, progressão e resultados determinísticos coincidem nos testes de paridade da campanha individual. Trocas e comunicação não são simuladas nem incluídas nesta entrega.

---

### User Story 3 - Retomar e instalar no próprio aparelho (Priority: P3)

Como jogador, quero salvar e retomar a partida após encerrar o aplicativo e instalá-lo no meu iPhone a partir do computador que possuo, sem depender de um Mac durante meu fluxo de entrega.

**Why this priority**: Sem persistência e um processo de instalação demonstrável o jogo não é utilizável no contexto do usuário.

**Independent Test**: Instalar uma versão assinada num aparelho real, salvar, fechar o aplicativo, reiniciar o iPhone e restaurar a partida.

**Acceptance Scenarios**:

1. **Given** uma partida salva, **When** encerro o aplicativo, reinicio o aparelho e renovo por cima a assinatura gratuita após sete dias com a mesma conta e identificador do app, **Then** a partida reabre no mesmo estado sem exportação manual.
2. **Given** uma compilação para dispositivo criada remotamente sem ROM nem credenciais Apple, **When** sigo as instruções documentadas num computador Windows, **Then** assino e instalo legitimamente no iPhone pelo Sideloadly, importo a ROM no próprio aparelho e abro o app sem emulador em tempo de execução.

### Edge Cases

- ROM diferente, corrompida ou de outra região: interromper a análise baseada em identidade anterior e informar incompatibilidade.
- Falta de autorização para usar ou distribuir conteúdo protegido: não empacotar ou publicar conteúdo sem direitos demonstrados; registrar o limite.
- Salvamento interrompido, armazenamento insuficiente ou atualização do aplicativo: evitar perda silenciosa e fornecer recuperação ou aviso claro.
- Pausa, chamada recebida, troca de aplicativo, ausência de áudio e mudanças de orientação: manter estado consistente e controles acessíveis.
- Instalação/assinatura indisponível ou revogada: informar o bloqueio sem afirmar que o aplicativo pode ser instalado.
- Funções da versão original que dependam de acessórios, troca ou comunicação: registrar requisitos específicos e cobertura separada antes de alegar paridade total.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O projeto MUST registrar a identidade verificável do arquivo de referência, seus limites de análise e evidências rastreáveis para cada conclusão relevante; análise estática não deve ser descrita como execução observada.
- **FR-002**: O projeto MUST produzir uma matriz de funcionalidades e paridade abrangendo inicialização, mapas, gráficos, áudio, entrada, diálogos, itens, batalhas, progressão, eventos e persistência, com estado testado, parcial ou não verificado.
- **FR-003**: O projeto MUST explicitar separadamente as condições jurídicas para uso pessoal e para eventual distribuição de jogo, marcas e recursos protegidos; nenhuma distribuição é pressuposta.
- **FR-004**: Antes de declarar o produto entregável, o projeto MUST demonstrar em um aparelho real a obtenção de um aplicativo instalável e assinado no fluxo do usuário sem macOS, documentando dependências, limitações e eventual impossibilidade.
- **FR-005**: O produto final MUST permitir jogar localmente a campanha completa da versão de referência, incluindo criação de personagem, exploração, diálogos, menus, itens, batalhas, eventos de progressão e conclusão.
- **FR-006**: O produto final MUST executar regras e experiência reconstruídas para iPhone sem carregar ou interpretar instruções do console por um emulador em tempo de execução.
- **FR-007**: O produto final MUST oferecer controles utilizáveis por toque e saída audiovisual adequada ao aparelho, preservando resultados de jogo documentados nos testes de paridade.
- **FR-008**: O produto final MUST salvar e restaurar progresso de maneira confiável após fechar o aplicativo e reiniciar o aparelho; falhas de gravação devem ser visíveis ao jogador.
- **FR-009**: O projeto MUST manter casos de referência reprodutíveis para funcionalidades essenciais e registrar divergências, inclusive recursos originalmente dependentes de acessórios ou comunicação, antes de declarar cobertura total.
- **FR-010**: O projeto MUST impedir a alegação de “100% funcional” enquanto houver funcionalidade identificada como não implementada ou não verificada; o relatório final deve explicitar exceções e restrições da instalação pessoal.
- **FR-011**: A primeira entrega MUST abranger a campanha para um jogador em inglês, sem tradução, alteração de regras, troca ou jogo online; funcionalidades dependentes de comunicação ficam registradas para uma entrega futura.
- **FR-012**: A compilação pública MUST excluir ROM, recursos originais e credenciais Apple de código, logs, caches e artefatos; o app MUST permitir importar a cópia do usuário diretamente no iPhone sem enviar dados a servidores e MUST funcionar offline depois disso.
- **FR-013**: A assinatura MUST ocorrer somente no computador do usuário e a renovação gratuita MUST preservar automaticamente o save em reinstalação por cima no mesmo iPhone; falha nesse teste bloqueia a entrega.
- **FR-014**: O projeto MUST usar REA MCP e Ghidra na análise onde o provedor aceite a ROM; quando o provedor não suportar ARM/GBA no Windows, MUST registrar esse limite e usar o Ghidra separadamente ou um ambiente compatível, sem atribuir resultados externos ao REA.

### Key Entities *(include if feature involves data)*

- **Arquivo de referência**: versão, região, tamanho, identidade criptográfica e origem declarada pelo usuário.
- **Evidência de análise**: observação, localização, método, limitações e subsistema relacionado.
- **Caso de paridade**: ação inicial, pré-condições, resultado esperado na referência, resultado no iPhone e estado de validação.
- **Partida salva**: progresso, equipe, inventário, eventos e estado necessário para retomada.
- **Entrega instalável**: versão, aparelho testado, estado da assinatura, pré-requisitos e restrições de uso.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% das afirmações do relatório de viabilidade sobre o arquivo são acompanhadas de origem e limite de confiança; subsistemas pendentes aparecem explicitamente na matriz.
- **SC-002**: 100% dos casos essenciais da matriz de paridade definidos após o inventário são aprovados em aparelho real antes de qualquer declaração de funcionalidade completa; casos não testados contam como pendentes.
- **SC-003**: Um jogador consegue iniciar uma partida e concluir os créditos em pelo menos uma execução contínua documentada, sem falhas impeditivas nem uso de emulador em tempo de execução.
- **SC-004**: Em 20 testes consecutivos de salvar, fechar, reiniciar e retomar, 20 preservam o estado esperado; qualquer falha bloqueia a aprovação de persistência.
- **SC-005**: No iPhone 15 Pro Max com iOS 26.6.2 do usuário, a compilação sem ROM, assinatura local, instalação, importação offline e abertura são reproduzidas e registradas; se alguma etapa falhar, o marco é classificado como bloqueado — nunca aprovado por suposição.
- **SC-006**: Em testes com pelo menos 5 sessões de uso, ao menos 4 jogadores conseguem completar os fluxos de movimentação, diálogo, batalha e salvamento sem instruções adicionais; problemas são anotados para correção.

## Assumptions

- O trabalho é inicialmente de análise e prototipação pessoal; ROM, recursos e aplicativo com conteúdo original não serão publicados enquanto não houver autorização verificável de redistribuição. O código sem esses recursos poderá ser público.
- “Nativo, sem emulador” significa reconstruir comportamentos do jogo para iPhone, não empacotar a ROM num emulador nem executar instruções do console em tempo de execução.
- A ROM da raiz é a referência do projeto; sua identidade e integridade serão verificadas antes de comparações ou alegações sobre a versão exata.
- O uso de Ghidra e do REA MCP é um requisito do trabalho de análise, não prova automática de cobertura ou viabilidade do port.
- GitHub Actions em runner macOS é candidato para compilar somente código e app sem ROM; Sideloadly no Windows é candidato para assinar com a conta Apple gratuita e instalar no iPhone. Credenciais Apple ficam exclusivamente no PC. A compatibilidade de um pacote concreto com esse fluxo depende de prova prática.
- A ROM será importada no iPhone, processada localmente e não transmitida; o jogo deve funcionar offline após a importação. A importação fornece dados ao port reconstruído e não justifica interpretar código ARM/GBA em tempo de execução.
- A primeira entrega abrange apenas a campanha individual em inglês, sem alterar regras. Trocas, comunicação e jogo online com amigos são escopo futuro e não serão anunciados como funcionais na primeira entrega.
- Reinstalar por cima com a mesma conta e o mesmo identificador do aplicativo é hipótese de preservação de dados, não garantia: o usuário executará os testes no próprio iPhone. Migração para outro aparelho não integra a primeira entrega.
- Uma assinatura gratuita pode exigir renovação aproximadamente a cada sete dias; não se tentará contornar sua expiração. Preservação automática do save na renovação é critério bloqueante.
- O provedor Ghidra do REA no Windows foi validado quanto à instalação, mas recusou explicitamente esta ROM ARM bruta; a análise combinada requer ambiente REA compatível ou uso independente do Ghidra para o alvo GBA.
