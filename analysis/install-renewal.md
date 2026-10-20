# EntregaInstalavel — Registro de Entrega e Instalação (T037)

Registro estruturado da entidade `EntregaInstalavel` conforme especificado no modelo de dados e em `tasks.md` (T037):

| Campo de EntregaInstalavel | Valor Registrado | Observações e Limitações |
|---|---|---|
| `buildId` | `39482747005` | Build executado com sucesso no GitHub Actions runner `macos-latest` (commit `b0eabeecdb23c9110a510ad3d46381a1489b5a7c`). |
| `version` | `1.0.0` | Versão de entrega configurada no projeto. |
| `bundleId` | `org.fireredport.installprobe` | Identificador único de pacote verificado no build. |
| `artifactSha256` | `7c51192c5544d86e0ec3d593cb81e21a1b37d5cfb7c4b05de8f9426726e73352` | SHA-256 verificado do artefato `FireRedPort-unsigned.ipa` (221.109 bytes). |
| `romIncluida` | `false` (auditado no IPA) | Auditoria do zip confirma: apenas `FireRedPort` binário, `Info.plist` e `PkgInfo`. |
| `credenciaisIncluidas` | `false` (auditado no IPA) | Auditoria confirma: 0 certificados, chaves p12 ou segredos. |
| `runner` | `macos-latest` (Xcode 26.6 Build 17F113) | Executado com sucesso no CI; 37 testes unitários passaram sem skips. |
| `dispositivo` | `iPhone 15 Pro Max` (alvo do usuário) | Verificado em execução real física pelo usuário. |
| `iosVersion` | `iOS 26.6.2` | Confirmado em execução no dispositivo físico. |
| `assinatura` | `assinada-localmente` | Assinada via Sideloadly no Windows com Apple ID pessoal gratuito do usuário. |
| `instalacaoStatus` | `aprovado` | Instalou, abriu, importou a ROM local e revalidou com sucesso no aparelho físico; novo build adiciona overworld jogável. |
| `resultadoRenovacao` | `aguarda-ciclo-7-dias` | Instalação inicial concluída; ciclo de renovação após 7 dias aguarda passagem do tempo. |
| `limitacoes` | Documentadas em `analysis/install-probe.md` | Exige Sideloadly no Windows para assinatura local; campanha offline ainda em construção. |
| `evidencias[]` | `["install-probe-iphone15promax-20261020", "sideloadly-success", "rom-import-verified"]` | Evidências fornecidas pelo usuário em teste no aparelho real. |

### Verificação Prévia de Fontes e Caches

- Verificação automatizada realizada em `ios/`, `analysis/` e `.github/`: nenhum arquivo `.gba`, `.agb`, `.sav`, `.ipa`, `.p12`, `.cer`, `.mobileprovision` ou `.key` detectado.
- Antes de qualquer publicação de release, o arquivo IPA compilado pelo CI deverá ser descompactado e inspecionado para garantir que contém estritamente `FireRedPort.app/{Info.plist, FireRedPort, PkgInfo}` sem ativos protegidos.
