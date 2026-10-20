# Fatia vertical: cópia privada identificada na sessão

**Escopo (FR-012, T072 parcial):** após seleção pelo `fileImporter`, a importação verifica hash integral/cabeçalho, copia localmente, verifica novamente a cópia privada e entrega o `ROMDataReader` à sessão do app. Ao abrir o app novamente, `restoreVerifiedCopy()` revalida a cópia antes de permitir o estado "identificada". Ausência, truncamento e identidade divergente não autorizam a sessão. A interface continua a informar que extração e campanha estão indisponíveis. Nenhum parser de mapas, diálogo ou batalha foi habilitado; o leitor não é prova de jogo offline.

**Fontes separadas:** `analysis/rea-capability.md` registra a rejeição da ROM raw ARM pelo REA MCP/Ghidra Windows antes de análise e ausência de Evidence REA da ROM; consulta atual `rea.binary_session({})` confirmou sessão fechada, Ghidra instalado como candidato, Hopper indisponível neste host e IDA/Kuna não configurados. Não se repetiu a mesma abertura rejeitada. `analysis/ghidra-session.md` e `analysis/subsystems.md` documentam investigações estáticas feitas no Ghidra **independente** e suas lacunas: não estabelecem gameplay, paridade nem execução. Esta fatia usa somente identidade/estrutura já registrada; não atribui descoberta nova da ROM ao REA ou Ghidra.

**Resultado do CI (run macOS oficial):**
- Commit: `1f418ba472c9eba730a518f0db5d11871bec9d52` (push em `main`)
- Run GitHub Actions: [39474630843](https://github.com/leonvaloes/firered-ios-port/actions/runs/39474630843)
- Conclusão: `success`
- Etapas executadas e aprovadas:
  1. `Check source inventory (fail closed)`: aprovado (sem ROMs, assets protegidos ou segredos; apenas fontes Swift permitidas).
  2. `Build and smoke-test in iOS Simulator`: aprovado (compilação Debug iphonesimulator, boot de simulador iPhone, instalação do app, lançamento e execução da suíte XCTest completa com 0 falhas).
  3. `Build unsigned iPhone app`: aprovado (compilação Release iphoneos sem assinatura).
  4. `Validate app contents and package unsigned IPA`: aprovado (bundle validado sem _CodeSignature, mobileprovision ou symlinks; artefato `FireRedPort-unsigned-installation-probe` gerado).
- **Status da fatia técnica:** validada em CI/XCTest no runner macOS.
- **Limitações e gates mantidos bloqueados:** este resultado valida a sintaxe, integridade de pacotes, contratos sintéticos e ciclo de vida do app em simulador. Não comprova execução nem importação em iPhone físico, não valida paridade de gameplay, não testa salvamento físico após reinício nem renovação de assinatura de 7 dias, e não aprova nenhum gate humano.
