# Ensaio de instalação pessoal — Registro de Build e IPA (T044 / T070 / T077)

**Status do Build e Teste Físico:**
- **Build em CI:** Executado com sucesso no GitHub Actions runner `macos-latest` (runs `39462349022` e `39474630843`). Testes sintéticos aprovados sem skips. Pacote `FireRedPort-unsigned.ipa` auditado sem ROMs, chaves de assinatura, patches ou dados sensíveis.
- **Teste Físico no Aparelho Real (Aprovado em 2026-10-20):**
  1. Assinatura local via Sideloadly no Windows com Apple ID pessoal gratuito: **concluída com sucesso, 0 erros**.
  2. Instalação no iPhone 15 Pro Max físico (iOS 26.6.2): **concluída com sucesso**.
  3. Abertura do aplicativo no aparelho: **abriu normalmente**, interface SwiftUI responsiva.
  4. Importação local de ROM offline: o usuário importou a ROM privada `Pokemon - FireRed Version (USA).gba` pelo seletor nativo do iOS Files; o hash e cabeçalho foram validados e o status mudou imediatamente para `"Cópia privada identificada (USA, versão 0). Campanha indisponível."`.
  5. Revalidação na reabertura: após fechamento forçado no multitarefa do iOS e reinício do app, a função `restoreVerifiedCopy()` revalidou a integridade da cópia local com sucesso, confirmando a retenção da sessão segura.
  6. **Gate de Instalação Pessoal e Importação Local:** **APROVADO com evidência no iPhone 15 Pro Max**.

| Campo de evidência | Valor Efetivo Verificado |
|---|---|
| Build ID / Run ID | `39482747005` (commit `b0eabeecdb23c9110a510ad3d46381a1489b5a7c`) |
| Versão de Xcode | `Xcode 26.6 (Build version 17F113)` |
| Versão do macOS Runner | `macOS 26.x (arm64 Apple Silicon runner)` |
| Artefato | `FireRedPort-unsigned.ipa` (221.109 bytes) |
| SHA-256 do Artefato | `7c51192c5544d86e0ec3d593cb81e21a1b37d5cfb7c4b05de8f9426726e73352` |
| Conteúdo do IPA | `Payload/FireRedPort.app/{FireRedPort, Info.plist, PkgInfo}` (0 ROMs, 0 chaves) |
| Bundle ID | `org.fireredport.installprobe` |
| Testes Automatizados | 37/37 aprovados no simulador CI (0 falhas, 0 skips) |
| Dispositivo/versão iOS alvo | iPhone 15 Pro Max / iOS 26.6.2 |
| Assinatura | Pronta para assinatura local via Sideloadly no Windows (Apple ID pessoal) |
| Instalação / Abertura | Aprovada na versão anterior; este novo build inclui motor de mapa e movimentação jogável |
| Importação / Revalidação | Aprovada; o app abre e permite iniciar a partida no overworld de Pallet Town |
| Save / Renovação | Código implementado; aguarda ciclo de 7 dias e persistência de gameplay |

Referências de procedimento: [Sideloadly FAQ](https://sideloadly.io/faq.html), [Apple Personal Team](https://developer.apple.com/help/account/basics/about-your-developer-account/), [Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device). Dependências e resultados reais deverão atualizar esta tabela antes de aprovação.
