# EntregaInstalavel — Registro de Entrega e Instalação (T037)

Registro estruturado da entidade `EntregaInstalavel` conforme especificado no modelo de dados e em `tasks.md` (T037):

| Campo de EntregaInstalavel | Valor Registrado | Observações e Limitações |
|---|---|---|
| `buildId` | `39462349022` | Build executado com sucesso no GitHub Actions runner `macos-latest`. |
| `version` | `1.0.0` | Versão de entrega configurada no projeto. |
| `bundleId` | `org.fireredport.installprobe` | Identificador único de pacote verificado no build. |
| `artifactSha256` | `8bc05aa2ffb8025299fc9460efd976e808dde4403e094b8ad9fae390b3fd5bb9` | SHA-256 verificado do artefato `FireRedPort-unsigned.ipa` (136.642 bytes). |
| `romIncluida` | `false` (auditado no IPA) | Auditoria do zip confirma: apenas `FireRedPort` binário, `Info.plist` e `PkgInfo`. |
| `credenciaisIncluidas` | `false` (auditado no IPA) | Auditoria confirma: 0 certificados, chaves p12 ou segredos. |
| `runner` | `macos-latest` (Xcode 26.6 Build 17F113) | Executado com sucesso no CI; 32 testes unitários passaram. |
| `dispositivo` | `iPhone 15 Pro Max` (alvo do usuário) | Alvo físico declarado; nenhum dispositivo conectado localmente. |
| `iosVersion` | `iOS 26.6.2` (alvo declarado) | Versão reportada pelo usuário; ainda não observada em runtime. |
| `assinatura` | `nao-assinada` | Status inicial; transição para `assinada-localmente` ocorrerá no PC via Sideloadly. |
| `instalacaoStatus` | `bloqueado` | Bloqueado até geração de IPA, assinatura local e conexão do iPhone. |
| `resultadoRenovacao` | `não-testado` | Bloqueado até que a instalação e o ciclo de 7 dias sejam executados. |
| `limitacoes` | Documentadas em `analysis/install-probe.md` | Exige Mac para compilação e PC com Sideloadly para assinatura. |
| `evidencias[]` | `[]` (vazio até execução prática) | Nenhuma evidência de aparelho real coletada nesta máquina. |

### Verificação Prévia de Fontes e Caches

- Verificação automatizada realizada em `ios/`, `analysis/` e `.github/`: nenhum arquivo `.gba`, `.agb`, `.sav`, `.ipa`, `.p12`, `.cer`, `.mobileprovision` ou `.key` detectado.
- Antes de qualquer publicação de release, o arquivo IPA compilado pelo CI deverá ser descompactado e inspecionado para garantir que contém estritamente `FireRedPort.app/{Info.plist, FireRedPort, PkgInfo}` sem ativos protegidos.
