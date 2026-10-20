# Matriz de funcionalidades e paridade

`Funcionalidade`: `id`, `subsistema`, `descricao`, `escopo` (`campanha`/`comunicacao-futura`), `status` (`nao-verificado`/`parcial`/`testado`), `evidencias[]`. O status `testado` exige todos os casos essenciais aprovados **no iPhone real**. Nenhum resultado foi observado no aparelho até esta data. IDs de casos abaixo são candidatos, não comprovação de cobertura completa; a seleção final dos casos essenciais depende do inventário T012 e da observação da referência.

| id | subsistema | descrição / alcance | escopo | status | evidências[] |
|---|---|---|---|---|---|
| F01 | inicialização | criação de personagem e nova partida | campanha | nao-verificado | [] |
| F02 | mapas | exploração e colisões | campanha | nao-verificado | [] |
| F03 | gráficos | sprites, animações e menus | campanha | nao-verificado | [] |
| F04 | áudio | música, efeitos e interrupções | campanha | nao-verificado | [] |
| F05 | entrada | controles por toque, confirmação e cancelamento | campanha | nao-verificado | [] |
| F06 | diálogos | interação e escolha de diálogo | campanha | nao-verificado | [] |
| F07 | itens | inventário e uso | campanha | nao-verificado | [] |
| F08 | batalhas | confronto e regras | campanha | nao-verificado | [] |
| F09 | progressão | marcos de campanha e créditos | campanha | nao-verificado | [] |
| F10 | eventos | gatilhos e flags | campanha | nao-verificado | [] |
| F11 | persistência | salvar e continuar | campanha | nao-verificado | [] |
| F12 | comunicação | troca e acessórios de comunicação; entrega futura | comunicacao-futura | nao-verificado | [] |

## Esquema completo de `CasoDeParidade`

Cada registro possui os campos abaixo; `null` indica ausência de observação, **não** igualdade com a referência.

| Campo | Tipo / regra |
|---|---|
| `id` | Identificador único e estável (ex.: `P02`). |
| `funcionalidadeId` | ID existente de `Funcionalidade` (`F01`–`F12`). |
| `precondicoes` | Estado inicial reproduzível: referência importada, ponto de partida/save autorizado, flags, equipe, inventário, posição e demais condições relevantes; não registrar bytes protegidos. |
| `acao` | Sequência de entradas reproduzível, incluindo opções e condições de tempo/RNG quando controláveis. |
| `resultadoReferencia` | `null` até observação real; após observação, resultado verificável e sua proveniência (sem dumps, screenshots ou conteúdo protegido no repositório). |
| `resultadoIPhone` | `null` até execução no aparelho real; depois resultado verificável, dispositivo/build e proveniência. Simulador ou XCTest não preenche este campo. |
| `versaoReferenciaSha256` | SHA-256 integral de 64 dígitos hexadecimais do arquivo observado; hash preliminar abaixo identifica o alvo, não atesta execução. |
| `ambiente` | Condições da referência **e** do iPhone (ferramenta/build, dispositivo/iOS, entrada, relógio/RNG ou limites de controle), inicialmente `a registrar`. |
| `status` | `pendente` (ainda sem comparação suficiente), `aprovado` (comparação reproduzível e aprovação em iPhone real), `divergente` (resultado comparado diferente) ou `bloqueado` (execução impedida com razão documentada). Nenhum `aprovado` apenas por XCTest. |
| `evidencias[]` | IDs/links para registros textuais não protegidos com método, data, condições e limitações; lista vazia até coleta. |

**Identidade-alvo preliminar** para os candidatos: SHA-256 `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` (ver `analysis/reference-identity.md`). Uma observação só pode ser associada ao caso após reconfirmar a identidade integral. Todos os registros da tabela usam esse valor em `versaoReferenciaSha256`; `resultadoReferencia=null`, `resultadoIPhone=null`, `ambiente=a registrar`, `status=pendente` e `evidencias=[]` em cada linha. Nenhum resultado é inferido do nome de um marco.

## Candidatos de casos e percurso até créditos

| id | funcionalidadeId | precondicoes | acao | resultadoReferencia | resultadoIPhone | versaoReferenciaSha256 | ambiente | status | evidencias[] |
|---|---|---|---|---|---|---|---|---|---|
| P01 | F01 | arquivo de referência confirmado; sem save | iniciar nova partida e definir personagem | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P02 | F02 | mapa/posição e colisões a registrar | atravessar percurso, tentar entrar em tile bloqueado e retornar | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P03 | F03 | cena e menu a registrar | observar transições, sprites e menu | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P04 | F04 | cena com áudio a registrar | iniciar áudio, interromper e retomar app | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P05 | F05 | cena com opções a registrar | mover, interagir, confirmar, cancelar e abrir menu por toque | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P06 | F06 | NPC e escolhas a registrar | iniciar diálogo, selecionar opção e encerrar | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P07 | F07 | inventário e contexto de uso a registrar | obter, usar e verificar item | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P08 | F08 | equipe, oponente, relógio/RNG ou limitações a registrar | executar turno e concluir confronto | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P10 | F10 | gatilho e flags a registrar | disparar evento e repetir interação | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P11 | F11 | partida em ponto seguro a registrar | salvar, fechar e continuar | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P09A | F09 | após nova partida; pré-requisitos a identificar por observação | percorrer etapas iniciais e verificar liberação do próximo objetivo | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P09B | F09 | após etapas iniciais; pré-requisitos a identificar | avançar por objetivos intermediários e validar bloqueios/desbloqueios | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P09C | F09 | após objetivos intermediários; pré-requisitos a identificar | avançar pelos objetivos finais e confronto(s) obrigatório(s) | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |
| P09D | F09 | conclusão dos objetivos finais a confirmar | concluir campanha e observar sequência de créditos até seu término | null | null | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` | a registrar | pendente | [] |

**Roteiro candidato:** P01 → P09A → P09B → P09C → P09D, intercalando P02–P08, P10 e P11 nos pontos confirmados por observação. Antes de executar, dividir etapas em checkpoints concretos, registrar entradas e estado de retomada por caso e adicionar casos para todos os ramos/mecânicas essenciais identificados em T012. Isto é apenas estrutura para percorrer até créditos, não evidência de que o percurso foi completado ou de que os marcos listados bastam. F12 (`comunicacao-futura`) permanece fora do percurso e da contagem de aprovação da campanha, sem status artificial de sucesso.

**Execução e gate:** confrontar cada caso com a referência controlada e depois com o build no iPhone; registrar divergências sem sobrescrever observações anteriores, anexar evidências textuais e preencher resultados/ambiente antes de alterar status. Testes sintéticos em `ios/FireRedPortTests/GameplayParityTests.swift` exercitam contratos propostos, não substituem resultados da referência ou do aparelho. Até T012/T025–T031 e execução real, todos os casos e funcionalidades permanecem pendentes/não verificados.
