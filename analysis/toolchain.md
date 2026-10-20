# Ferramentas e procedimento de importação

## Ambiente constatado

- Sistema desta sessão: Windows (`win32`).
- Ghidra instalado em `C:\Tools\Ghidra\Ghidra_12.1.4_build\ghidra_12.1.4_PUBLIC`. A pasta existe e `Ghidra/application.properties` registra `application.version=12.1.4` e `application.release.name=PUBLIC`. Não foi verificada uma inicialização da interface nesta etapa.
- Ferramentas REA estão disponíveis via MCP nesta sessão. Nenhum alvo está aberto no REA nesta etapa; disponibilidade das ferramentas **não** significa suporte ao formato da ROM nem análise realizada. A tentativa anterior descrita em `specs/001-port-nativo-firered/research.md` retornou `capability_unavailable/unsupported_provider` para raw ARM no provedor Ghidra Windows P0. Não atribuir ao REA resultados obtidos no Ghidra independente.
- Xcode não está disponível neste ambiente Windows para build iOS; a versão a usar em macOS ainda requer verificação.

## Procedimento de importação (executado parcialmente; ver `analysis/ghidra-session.md`)

1. Confirmar identidade do arquivo pessoal com hash SHA-256 integral e tamanho antes de interpretar endereços; se a identidade divergir, interromper e reavaliar perfil e offsets. Não copiar a ROM para o repositório.
2. Criar projeto Ghidra **fora** do repositório e importar o arquivo local como **Raw Binary** (sem assumir que Ghidra reconheça automaticamente cabeçalho GBA ou endereços).
3. Selecionar linguagem/processador **ARM little-endian** compatível com o alvo GBA; conferir opções de variante e modo de instrução no Ghidra antes de decodificar (ainda não verificados nesta sessão).
4. Configurar/conferir o mapeamento de memória do arquivo para a base candidata `0x08000000`, registrando offset de arquivo, base efetiva e eventuais ajustes. O bloco foi observado começando nesse endereço; isso não confirma endereço de rotina nem entrada real. Verificar cabeçalho e vetor de entrada antes de definir o ponto de entrada efetivo ou iniciar autoanálise.
5. Registrar configurações escolhidas, versão, endereços/offsets investigados, método e limitações em documentação textual sem colar dumps, instruções extraídas ou recursos protegidos. Distinguir qualquer inferência de observação e não afirmar execução de código sem teste de runtime.

A importação Ghidra independente e o mapeamento do bloco bruto em `0x08000000` foram observados em `analysis/ghidra-session.md`; a validação da entrada real, análise de funções e decompilação permanecem pendentes.
