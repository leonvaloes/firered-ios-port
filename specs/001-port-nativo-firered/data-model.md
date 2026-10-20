# Modelo de dados — port nativo

O modelo descreve contratos de domínio propostos, não estruturas comprovadas da ROM. Identificadores e campos específicos da campanha dependem do inventário Ghidra e de casos de referência.

## ArquivoDeReferencia

- `id` (UUID), `nomeLocal` (somente local), `tamanhoBytes` (inteiro positivo), `sha256` (64 dígitos hexadecimais), `regiao`, `versao` (identificações sujeitas à validação), `origemDeclarada`, `verificadoEm`.
- Identidade preliminar do arquivo em raiz: 16.777.216 bytes, SHA-256 `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` (hash local; não prova legitimidade ou revisão interna). Confirmar cabeçalho e checksums em inventário antes de fixar identidade da versão.
- Importação de hash diferente → incompatível, sem usar offsets ou interpretar código. Nunca incluir o arquivo em builds públicos.

## EvidenciaDeAnalise

- `id`, `arquivoId`, `subsistema`, `afirmacao`, `tipo` (`observado-estatico`, `observado-runtime`, `inferido`, `desconhecido`), `metodo`, `localizacao`, `evidenceId` (quando REA), `limitacoes`, `registradoEm`.
- Relação: muitas evidências para um arquivo; toda afirmação de viabilidade deve referenciar origem e escopo. Análise estática não é runtime.

## Funcionalidade e CasoDeParidade

- `Funcionalidade`: `id`, `subsistema` (inicialização, mapas, gráficos, áudio, entrada, diálogos, itens, batalhas, progressão, eventos, persistência), `descricao`, `escopo` (`campanha`, `comunicacao-futura`), `status` (`nao-verificado`, `parcial`, `testado`), `evidencias[]`.
- `CasoDeParidade`: `id`, `funcionalidadeId`, `precondicoes`, `acao`, `resultadoReferencia`, `resultadoIPhone`, `versaoReferenciaSha256`, `ambiente`, `status` (`pendente`, `aprovado`, `divergente`, `bloqueado`), `evidencias[]`.
- Uma funcionalidade só passa a `testado` quando seus casos essenciais são aprovados no aparelho; caso pendente/divergente impede alegação de cobertura integral. Testes de comunicação são registrados em escopo futuro, não falsamente aprovados.

## PartidaSalva

- `schemaVersion`, `referenceSha256`, `slotId`, `revision`, `savedAt`, `integrityDigest`, `player`, `position`, `party`, `inventory`, `progressFlags`, `worldState`, `battleState` (somente se permitido salvar), `randomState` (se exigido para resultados determinísticos).
- Pertence ao container privado do app e à referência importada. Campos concretos dependem de regras reconstruídas; nenhuma serialização de ponteiros ou código da ROM.
- Transições: `em-memoria` → `gravando-temporario` → `validando` → `ativo`; falha → manter último save íntegro, informar erro; restauração só após validar versão, hash e integridade. Migração de schema deve preservar backup e recusar downgrade desconhecido.

## EntregaInstalavel

- `buildId`, `version`, `bundleId`, `artifactSha256`, `romIncluida=false`, `credenciaisIncluidas=false`, `runner`, `dispositivo`, `iosVersion`, `assinatura` (`nao-assinada`, `assinada-localmente`, `expirada`, `revogada`), `instalacaoStatus`, `resultadoRenovacao`, `limitacoes`, `evidencias[]`.
- Transições: build limpo → IPA não assinada → assinatura local no PC → instalada no iPhone → importação local → testes de save/renovação. Falha em qualquer etapa não permite status de entrega aprovada.

## Relacionamentos e invariantes

ArquivoDeReferencia 1:N EvidenciaDeAnalise; Funcionalidade 1:N CasoDeParidade; EntregaInstalavel N:N CasoDeParidade por execução; PartidaSalva N:1 ArquivoDeReferencia. Nenhum dado da ROM ou credencial deve ser transmitido nem publicado. Uma afirmação de “100% funcional” só é permitida após todos os casos essenciais do escopo definido aprovados, campanha concluída e instalação/persistência verificadas em aparelho real; funções de comunicação permanecem explicitamente fora de escopo.
