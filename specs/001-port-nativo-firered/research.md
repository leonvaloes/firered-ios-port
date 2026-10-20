# Pesquisa e decisões — 2026-10-20

## Identidade e alcance da análise

- **Decisão**: Fixar referência por SHA-256 integral e verificar cabeçalho antes de aceitar offsets; não inferir legitimidade ou revisão de circuito somente pelo nome.
- **Racional**: Medição local do arquivo `Pokemon - FireRed Version (USA).gba`: 16.777.216 bytes, SHA-256 `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac`. Bytes de cabeçalho: título `POKEMON FIRE` (offset 0xA0), código `BPRE` (0xAC), fabricante `01` (0xB0), versão byte `00` (0xBC), complemento armazenado `68` (0xBD). Compatível com identificação FireRed americana; cabeçalho não é teste de integridade integral nem prova de propriedade. Formato de cabeçalho: [GBATEK](https://mgba-emu.github.io/gbatek/).
- **Alternativas consideradas**: confiar em nome, cabeçalho ou MD5 de lista informal — insuficientes para validar parser e procedência.

## REA MCP e Ghidra

- **Decisão**: Usar REA para alvos que seu provedor aceite; para este arquivo bruto ARM/GBA, abrir a ROM independentemente no Ghidra configurando processador ARM little-endian e base GBA 0x08000000; registrar offsets, funções e limites; não afirmar decompilação nem execução até fazê-las de fato.
- **Racional**: Tentativa nesta sessão de `rea.open_binary` com `format=raw-binary`, `architecture=arm`, `entry_point=0x08000000`, `provider_id=ghidra` devolveu `capability_unavailable/unsupported_provider`: Windows Ghidra P0 aceita PE nativo e raw 6502, não raw ARM. Hopper indisponível em Windows; IDA/Kuna não configurados. Nenhuma sessão de ROM foi aberta pelo REA. O Ghidra independente ainda não foi executado nesta fase de design. A base sugerida é hipótese de mapeamento GBA a conferir no Ghidra, não endereço de rotina identificado.
- **Alternativas consideradas**: repetir chamada idêntica (não resolve bloqueio), alegar análise inexistente, ou ambiente REA compatível (possível investigação futura).

## Arquitetura do jogo

- **Decisão**: Swift para regras determinísticas e leitura limitada de dados, SwiftUI para importação/menus, SpriteKit para cena 2D; manter estado de jogo fora do renderizador. Fixar toolchain Swift/Xcode após primeiro build reproduzível.
- **Racional**: APIs nativas com [SpriteView](https://developer.apple.com/documentation/spritekit/spriteview); modelo independente do frame permite testes. Importar via [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:oncompletion/)), validar SHA-256 com [CryptoKit](https://developer.apple.com/documentation/cryptokit/sha256) e limites antes de processar qualquer estrutura. Nenhuma instrução ARM é executada pela aplicação.
- **Alternativas consideradas**: emulador (viola FR-006); renderizador Metal próprio (complexidade injustificada inicialmente); recursos embutidos no IPA (viola FR-012).

## Persistência e testes

- **Decisão**: Snapshot completo versionado no Application Support, gravação atômica serializada com último snapshot íntegro de reserva; validação de esquema, hash ROM e digest ao ler; apresentar erro se falhar.
- **Racional**: [Foundation atomic write](https://developer.apple.com/documentation/foundation/nsdata/writingoptions/atomic) reduz risco de arquivo parcial, mas não garante consistência lógica nem transação entre dois arquivos. [XCTest](https://developer.apple.com/documentation/xctest/xctest) para testes sintéticos de parser, regras com RNG fixo, salvamento/migração e restauração; paridade e renovação exigem referência e aparelho real.
- **Alternativas consideradas**: SQLite transacional se múltiplos registros se tornarem necessários; UserDefaults inadequado para snapshot grande e recuperação auditável.

## Compilação, assinatura e direitos

- **Decisão**: Provar build IPA não assinado em GitHub Actions runner macOS sem ROM ou Apple ID; assinar/instalar no Windows do usuário via Sideloadly e testar no iPhone. Tratar essa rota como hipótese até instalar IPA concreta. Não distribuir conteúdo original nem presumir que importação pelo usuário concede direitos de distribuição.
- **Racional**: [Sideloadly FAQ](https://sideloadly.io/faq.html) descreve Windows, Apple ID, instalação de IPA e preservação de dados ao reinstalar por cima; fornecedor declara suporte iOS 26, não prova para este app. Windows requer iTunes/iCloud instalados da versão do site. [Apple Personal Team](https://developer.apple.com/help/account/basics/about-your-developer-account/) informa perfis de sete dias e limites de apps/IDs/aparelhos. [Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device) e confiança no desenvolvedor podem ser exigidos. [Diretrizes Apple §5.2](https://developer.apple.com/app-store/review/guidelines/) não substituem autorização dos titulares; avaliação jurídica específica permanece necessária antes de distribuir.
- **Alternativas consideradas**: assinar no CI (expõe credenciais), pressupor renovação automática (Windows precisa estar disponível), App Store (requer direitos e avaliação própria), excluir backup manual como contingência (não elimina critério de preservação automática).

## Incertezas de verificação, não resolvidas por suposição

Não há bloqueio de escolha arquitetural pendente para este plano. São **gates de execução**: direitos demonstráveis para qualquer distribuição; decompilação/análise real no Ghidra; inventário completo e matriz de paridade; versão exata de Xcode no runner; build de IPA compatível; assinatura e importação no iOS 26.6.2 real; preservação do save na renovação por cima; 20/20 ciclos de save e campanha completa. Falha em qualquer gate relevante bloqueia declaração de produto entregável ou “100% funcional”.
