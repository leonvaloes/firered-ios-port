# Ensaio de instalação pessoal — Registro de Build e IPA (T044)

**Status do Build:** Executado com sucesso no GitHub Actions runner `macos-latest` (run ID: `39462349022`). Todas as 32 suítes de testes unitários passaram sem skips. O pacote `FireRedPort-unsigned.ipa` foi inspecionado e auditado com ausência total de ROMs, chaves de assinatura, patches ou dados sensíveis.

1. **Build e Testes em CI:** Concluído no runner macOS oficial. A suíte de 32 testes sintéticos (`ROMImportTests`: 10, `SaveStoreTests`: 19, `GameplayParityTests`: 3) executou no simulador iOS com 0 falhas e 0 skips. A IPA unsigned foi exportada e verificada localmente.
2. **Próximo passo — Instalação via Sideloadly:** Instalar Sideloadly no Windows com versões de iTunes/iCloud dos sites oficiais (não Microsoft Store). Conectar o iPhone 15 Pro Max via USB e selecionar o arquivo `artifacts/FireRedPort-unsigned-installation-probe/FireRedPort-unsigned.ipa`. Assinar com Apple ID pessoal **apenas neste computador**; nunca versionar credenciais.
3. **Developer Mode e Abertura:** Ativar Modo de Desenvolvedor no iOS 26.6.2 e confiar no certificado pessoal. Instalar e abrir o app.
4. **Importação Offline:** Copiar a ROM pessoal para o app via seletor nativo do iOS Files, ativar o Modo Avião e confirmar o carregamento estritamente offline.
5. **Renovação (~7 dias):** Ao término do ciclo de 7 dias da conta gratuita, reinstalar a IPA assinada por cima via Sideloadly sem desinstalar o app prévio e verificar a conservação íntegra dos saves.

| Campo de evidência | Valor Efetivo Verificado |
|---|---|
| Build ID / Run ID | `39462349022` (GitHub Actions runner `macos-latest`) |
| Versão de Xcode | `Xcode 26.6 (Build version 17F113)` |
| Versão do macOS Runner | `macOS 26.x (arm64 Apple Silicon runner)` |
| Artefato | `FireRedPort-unsigned.ipa` (136.642 bytes) |
| SHA-256 do Artefato | `8bc05aa2ffb8025299fc9460efd976e808dde4403e094b8ad9fae390b3fd5bb9` |
| Conteúdo do IPA | `Payload/FireRedPort.app/{FireRedPort, Info.plist, PkgInfo}` (0 ROMs, 0 chaves) |
| Bundle ID | `org.fireredport.installprobe` |
| Testes Automatizados | 32/32 aprovados (10 ROM import, 19 Save store, 3 Parity) |
| Dispositivo/versão iOS alvo | iPhone 15 Pro Max / iOS 26.6.2 (declarados; aguarda ensaio USB) |
| Assinatura | `nao-assinada` (pronto para Sideloadly local) |
| Instalação/abertura | Aguarda conexão USB e assinatura Sideloadly |
| Importação/uso offline | Código implementado; aguarda execução no aparelho físico |
| Save/renovação | Código implementado; aguarda ciclo de 7 dias no aparelho físico |

Referências de procedimento: [Sideloadly FAQ](https://sideloadly.io/faq.html), [Apple Personal Team](https://developer.apple.com/help/account/basics/about-your-developer-account/), [Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device). Dependências e resultados reais deverão atualizar esta tabela antes de aprovação.
