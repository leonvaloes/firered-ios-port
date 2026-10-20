# Prova de viabilidade — observações iniciais (2026-10-20)

## Identidade local da referência

Observação obtida por leitura local dos bytes da ROM (não é Evidence do REA): arquivo `Pokemon - FireRed Version (USA).gba`, 16.777.216 bytes, SHA-256 `3D0C79F1627022E18765766F6CB5EA067F6B5BF7DCA115552189AD65A5C3A8AC`. Cabeçalho: título `POKEMON FIRE`, código `BPRE`, fabricante `01`, versão 0, valor fixo `0x96`, checksum gravado `0x68`, checksum recalculado `0x68`. Cabeçalho consistente não comprova integridade integral, revisão comercial exata, propriedade ou direitos de distribuição.

## Ferramentas e limite observado

- REA MCP 6.7.0 conectado ao OpenCode; `binary_session` mostrou o Ghidra 12.1.4 disponível em `C:\Tools\Ghidra\Ghidra_12.1.4_build\ghidra_12.1.4_PUBLIC`, com Java 25.0.1. O caminho foi configurado no ambiente do servidor MCP. Backup da configuração anterior: `~/.config/opencode/opencode.json.pre-ghidra-20261020`.
- Tentativa efetiva de `open_binary` no REA com `format: raw-binary`, `architecture: arm`, `entry_point: 0x08000000` e `provider_id: ghidra` **falhou antes da análise**: `capability_unavailable / target_format_unsupported`; razão: “Windows Ghidra P0 accepts native PE and explicitly selected raw 6502 targets only.” Isso não significa que o Ghidra independente seja incapaz de importar a ROM, apenas que **esse provedor REA no Windows não suporta ARM bruto**. Nenhum Evidence ID de decompilação foi produzido.
- Próximo passo da análise: investigar uso do Ghidra independente com linguagem ARM/Thumb/GBA e mapeamento corretos ou executar REA/Ghidra em host compatível para análise da ROM; registrar observações separadamente. Não forçar cabeçalho PE falso nem tratar dados da ROM como instruções automaticamente.

## Condições ainda não comprovadas

1. Importação, reconstrução de código e paridade da campanha: **não iniciadas**.
2. Build iOS para dispositivo sem ROM no GitHub Actions: **não testado**.
3. Pacote compilado aceito pelo Sideloadly no Windows com assinatura gratuita: **não testado**.
4. Importação local da ROM, funcionamento offline e save no iPhone 15 Pro Max com iOS 26.6.2: **não testados**.
5. Renovação legítima por cima sem perda automática do save: **não testada e bloqueante**.
6. Código público sem conteúdo protegido; ROM e recursos originais fora do GitHub e dos artefatos: **regra de escopo estabelecida**, não garantia automatizada.

Conclusão: ferramentas conectadas e limite do provedor conhecido; a viabilidade do port ainda não foi demonstrada.
