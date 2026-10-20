# Contrato de evidências de análise — T006

`EvidenciaDeAnalise` é um registro de afirmação **atômica** vinculado à referência de `analysis/reference-identity.md`; não converte uma hipótese em observação. Campos obrigatórios, salvo indicação expressa:

| Campo | Semântica |
| --- | --- |
| `id` | Identificador estável e único do registro (p. ex. UUID); não reutilizar quando a afirmação mudar. |
| `arquivoId` | Identificador estável do arquivo de referência verificado; remeter ao SHA-256 integral, tamanho e verificação registrados para esse arquivo. Em observação sem arquivo, explicitar o alvo próprio, sem fingir que é a ROM. |
| `subsistema` | Área delimitada (inicialização, mapas, gráficos, áudio, entrada, diálogos, itens, batalhas, progressão, eventos, persistência ou ferramentas). |
| `afirmacao` | Uma conclusão verificável, delimitando o que foi e o que **não** foi observado. |
| `tipo` | Um de `observado-estatico`, `observado-runtime`, `inferido`, `desconhecido`. Resultado estático não comprova comportamento em execução. |
| `metodo` | Ferramenta, versão, configuração e passos suficientes para repetição; distinguir medição local, Ghidra independente, REA e ensaio em aparelho. |
| `localizacao` | Fonte e ponto preciso: documento/seção, offset **de arquivo** ou endereço mapeado (com base e convenção), procedimento, caso de teste ou ambiente e momento da execução; indicar intervalo examinado e cobertura quando aplicável. Não confundir endereço com offset. |
| `evidenceId` | ID exato retornado pelo REA **somente quando houver Evidence REA**; ausente/nulo para PowerShell, Ghidra externo e teste sem REA. Não inventar ID nem atribuir observação externa ao REA. |
| `limitacoes` | Lista explícita de lacunas, alternativas plausíveis, cobertura parcial, premissas e condições para confirmação. |
| `registradoEm` | Data/hora ISO 8601 com fuso, da criação da anotação; não confundir com hora da coleta. |

Toda conclusão deve ter fonte, método e escopo rastreáveis, inclusive as negativas (`desconhecido` registra a pergunta, o que foi tentado e por que não foi respondida). Para inferências, citar registros de suporte pelos respectivos `id` e explicar o passo inferencial; não usar `observado-runtime` sem execução real no alvo/ambiente indicado. Se a referência divergir em hash ou tamanho, invalidar a aplicação das observações dependentes de offsets até nova análise. Ausência de achado em busca limitada não prova ausência global.

**Higiene:** registrar só texto/metadados mínimos não protegidos; não copiar bytes, dumps, código descompilado, gráficos, áudio ou material extraído para o repositório. Se Evidence do REA existir, preservar ID, cobertura e limitações e manter o artefato privado; um ID não substitui explicação de fonte e escopo. Estado atual: não há Evidence REA de decompilação da ROM; o contrato não pressupõe análise concluída.
