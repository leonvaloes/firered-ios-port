# EntregaInstalavel — Registro de Entrega e Instalação (T037)

Registro estruturado da entidade `EntregaInstalavel` conforme especificado no modelo de dados e em `tasks.md` (T037):

| Campo de EntregaInstalavel | Valor Registrado | Observações e Limitações |
|---|---|---|
| `buildId` | `pendente-ci` | Nenhum build realizado no momento; aguarda execução em runner macOS. |
| `version` | `1.0.0` | Versão de entrega configurada no projeto. |
| `bundleId` | `org.fireredport.installprobe` | Identificador único de pacote configurado no projeto Xcode. |
| `artifactSha256` | `não-gerado` | Nenhum arquivo `.ipa` foi compilado ou gerado nesta sessão Windows. |
| `romIncluida` | `false` (validado em código) | Auditoria estática confirma: 0 bytes de ROM no repositório ou targets. |
| `credenciaisIncluidas` | `false` (validado em código) | Auditoria estática confirma: 0 certificados, chaves p12 ou senhas. |
| `runner` | `macos-latest` (GitHub Actions) | Configurado em `.github/workflows/ios-build.yml`; não disparado. |
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
