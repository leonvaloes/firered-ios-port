# Plano de validação de save, restauração e renovação — T033

**Estado: pendente; roteiro, não resultado.** Nenhum ciclo, instalação ou renovação foi executado neste documento. Base: `specs/001-port-nativo-firered/{tasks.md,data-model.md,contracts/user-flows.md}` (T032–T038) e `analysis/release-gates.md`. Executar apenas com uma cópia de referência cuja posse e uso tenham sido avaliados, sem anexar ROM, save com conteúdo protegido, credenciais, perfil de assinatura ou logs com bytes do arquivo ao repositório.

## Pré-requisitos e identificação da execução

- App com `PartidaSalva`/`SaveStore` integrados (T034–T036), botão **Salvar** que confirma somente após validação e **Continuar** que recusa hash/schema/integridade incompatíveis; XCTest sintético T032 executado. Build/IPA inspecionados sem ROM/segredos; instalação pessoal assinada no PC (T016–T017, T030, T035–T037). Não inferir comportamento em aparelho de XCTest ou simulador.
- Aparelho alvo para T038: iPhone 15 Pro Max, iOS 26.6.2 (conferir versão real no momento), espaço livre registrado; informar build ID, versão do app, bundle ID, hash do artefato, hash da referência, conta Apple **somente por identificador local não reversível** e estado da assinatura, sem senhas/identificador pessoal em evidências publicadas.
- Registrar responsável, data/hora e ambiente em `analysis/save-install-results.md` quando houver execução. Antes do primeiro ciclo, importar localmente a referência válida, criar partida, salvar e verificar leitura; registrar `slotId`, `revision`, `schemaVersion` e um marcador de estado observável (posição, equipe, inventário, flags/progresso e, quando aplicável, estado de batalha/RNG). Não publicar valores extraídos protegidos: usar descrições ou identificadores sintéticos/anonimizados.
- Cada ciclo é **salvar → esperar confirmação de validação → encerrar completamente o app → reiniciar o iPhone → abrir o app → Continuar**. Reiniciar o app sem reiniciar o telefone não conta. Após restaurar, conferir marcador e revisão esperados, avançar estado de forma observável e salvar de novo no próximo ciclo; impedir que um save antigo pareça correto em todos os ciclos. Se salvar falhar, registrar erro e verificar que o último snapshot íntegro permanece restaurável; não contar como ciclo aprovado.

## Registro obrigatório por ciclo

Preencher no arquivo de resultados uma linha por ciclo com: número, horário, build ID, slot/revisão esperados e observados, marcador esperado/observado, confirmação de gravação pós-validação, evidência de encerramento e reinício real do aparelho, resultado da restauração, erro/limitação e referência a evidência textual/redigida. **Pendente** não significa aprovado.

| Ciclo | Estado a registrar em `save-install-results.md` | Estado inicial |
| --- | --- | --- |
| 01 | salvar → encerrar → reiniciar iPhone → restaurar; comparar marcador e revisão | pendente |
| 02 | idem; novo marcador e revisão | pendente |
| 03 | idem; novo marcador e revisão | pendente |
| 04 | idem; novo marcador e revisão | pendente |
| 05 | idem; novo marcador e revisão | pendente |
| 06 | idem; novo marcador e revisão | pendente |
| 07 | idem; novo marcador e revisão | pendente |
| 08 | idem; novo marcador e revisão | pendente |
| 09 | idem; novo marcador e revisão | pendente |
| 10 | idem; novo marcador e revisão | pendente |
| 11 | idem; novo marcador e revisão | pendente |
| 12 | idem; novo marcador e revisão | pendente |
| 13 | idem; novo marcador e revisão | pendente |
| 14 | idem; novo marcador e revisão | pendente |
| 15 | idem; novo marcador e revisão | pendente |
| 16 | idem; novo marcador e revisão | pendente |
| 17 | idem; novo marcador e revisão | pendente |
| 18 | idem; novo marcador e revisão | pendente |
| 19 | idem; novo marcador e revisão | pendente |
| 20 | idem; novo marcador e revisão | pendente |

## Falhas e recuperação

Registrar separadamente no aparelho, quando reproduzíveis sem danificar a instalação principal: referência com hash diferente, schema desconhecido, arquivo corrompido, interrupção de gravação, falta de espaço e saves concorrentes. Em cada falha, exigir erro visível, nenhum falso aviso de sucesso, sessão em memória preservada e recuperação do último snapshot íntegro sem sobrescrevê-lo silenciosamente. Validar por XCTest sintético com injeção controlada de falhas antes de tentar reproduzir falhas de disco no aparelho; não adulterar saves reais sem cópia de contingência. Mudança de schema requer backup íntegro antes de migração; versão desconhecida nunca deve ser rebaixada silenciosamente.

**Falha de gate:** menos de 20/20 ciclos completos e consecutivos aprovados, marcador/revisão incorretos, ausência de reinício físico, recuperação inválida, erro oculto, reinstalação que apaga dados ou qualquer evidência ausente. Anotar `divergente` quando observado diferente, `bloqueado` quando pré-requisito/recurso indisponível, `pendente` quando não executado; repetir a série inteira após correção, sem reaproveitar ciclos antigos para reivindicar 20/20.

## Renovação da assinatura pessoal (teste separado)

1. Anotar build/versão/bundle ID, identificador local da mesma conta, status/validade da assinatura gratuita e marcador de save íntegro antes da renovação. Avisar usuário do prazo aproximado de sete dias e limites da conta gratuita; não forçar expiração ou declarar teste de expiração sem evidência. Fazer cópia de contingência **local e privada** antes do procedimento, sem usar a cópia para simular retenção automática.
2. Quando a renovação legítima for necessária/disponível, assinar localmente no PC com **a mesma conta e bundle ID**, instalar a nova assinatura **por cima**, sem desinstalar, apagar dados, exportar ou reimportar o save. Documentar versão/build anterior e novo, processo e eventuais falhas de confiança/Developer Mode/Sideloadly.
3. Abrir **Continuar** sem intervenção manual nos dados, validar hash/schema/integridade e comparar marcador/revisão com o registro pré-renovação. Salvar um novo estado e restaurá-lo após encerramento e reinício do aparelho; registrar evidências e limitações em `analysis/save-install-results.md` e `analysis/install-renewal.md`.
4. Aprovar renovação só se save anterior permanecer automaticamente disponível e correto, novo save também restaurar, mesma conta/bundle ID e assinatura válida forem demonstrados em aparelho real. Assinatura expirada/revogada, diferença de conta/bundle ID, app desinstalado, restauração via backup manual ou simples teste em simulador **não** aprovam o gate.

## Contingência e decisão

Antes de testes destrutivos, manter backup privado e cifrado do save e metadados mínimos (hash/schema/revisão) fora do repositório, com acesso restrito; verificar que é legível e registrar onde está guardado **sem revelar localização sensível ou conteúdo**. Em falha de renovação/instalação, interromper novos writes, preservar app/container se possível, registrar erro, recuperar dados pela rota de contingência somente após documentar a falha; **recuperação manual não substitui preservação automática** nem torna o teste aprovado. Sem iPhone, conta, build ou integração disponíveis, registrar bloqueio explícito em resultados quando existirem e manter gates de save e entrega pendentes/bloqueados; não inventar medições.
