# Guia de validação — prova de viabilidade e produto

Estado atual: existe um shell SwiftUI de **prova de instalação** e um workflow de build não executado, além de roteiros XCTest sintéticos ainda não ligados às APIs de produção. Não há jogo implementado, testes aprovados ou IPA verificada. Os comandos condicionais abaixo **não devem ser descritos como testes já aprovados**. Contrato: [user-flows.md](contracts/user-flows.md); entidades: [data-model.md](data-model.md).

## Pré-requisitos

- Windows/PowerShell e arquivo pessoal `Pokemon - FireRed Version (USA).gba` na raiz; não publicar o arquivo.
- Para inspeção estática: Ghidra instalado conforme [spec.md](spec.md), REA MCP disponível; provedores Windows REA atuais não admitem raw ARM desta ROM, portanto Ghidra deve ser usado separadamente para essa etapa.
- Para validar entrega futura: runner macOS com Xcode no CI; Windows com Sideloadly, iTunes e iCloud das versões do site; iPhone 15 Pro Max iOS 26.6.2, Apple ID usado **somente no computador pessoal**, Developer Mode/confiança conforme pedido pelo aparelho.

## 1. Validar identidade antes de analisar

No PowerShell, na raiz do projeto:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath 'Pokemon - FireRed Version (USA).gba'
(Get-Item -LiteralPath 'Pokemon - FireRed Version (USA).gba').Length
```

Esperado para o arquivo observado: hash `3D0C79F1627022E18765766F6CB5EA067F6B5BF7DCA115552189AD65A5C3A8AC`, 16777216 bytes. Se diferente, interromper comparações e avaliar como nova variante. Abrir no Ghidra como raw ARM little-endian com base GBA apropriada, verificar mapeamento/entrada e registrar evidências por subsistema; documentar que REA recusou raw ARM em Windows, não fingir resultado decompilado.

## 2. Verificar build limpo (quando existir projeto iOS)

No runner macOS de GitHub Actions, registrar `xcodebuild -version` e executar `xcodebuild -list -project ios/FireRedPort.xcodeproj`. O target de testes unitários `FireRedPortTests` está configurado no scheme compartilhado `FireRedPort` (`ios/FireRedPort.xcodeproj/xcshareddata/xcschemes/FireRedPort.xcscheme`) com três suítes ativas sem skips (`ROMImportTests`, `SaveStoreTests`, `GameplayParityTests`). O workflow `.github/workflows/ios-build.yml` prevê: (1) verificação estrita de ausência de binários proprietários; (2) build e smoke test no simulador; (3) execução automatizada da suíte de testes sintéticos via `xcodebuild test`; (4) build para iPhone com `CODE_SIGNING_ALLOWED=NO`; (5) validação de inventário do bundle e empacotamento em `FireRedPort-unsigned.ipa`. O runner e a versão efetiva de Xcode dependem de disparo em ambiente macOS. Antes de publicar qualquer artefato, inspecionar conteúdo do IPA, logs e caches para segredos; falha de build ou teste bloqueia fluxo seguinte.

## 3. Assinar e instalar no aparelho real

Baixar IPA limpo para Windows; abrir Sideloadly, conectar iPhone, selecionar IPA e assinar com Apple ID local. Aceitar as etapas legítimas de Developer Mode e confiança quando solicitadas. Registrar versão, bundle ID, hash da IPA, versão iOS e resultado. Se assinatura ou instalação falhar, classificar **bloqueado**, sem alegar instalabilidade. Importar ROM via Files no aparelho e testar modo avião: app deve abrir e jogar sem rede; ROM diferente deve ser recusada.

## 4. Validar comportamento e persistência

- Registrar casos de referência para criação de personagem, mapa, diálogo, item, batalha, evento, áudio, controles e créditos, com resultado na referência e no iPhone; executar campanha individual inteira. Comunicação fica marcada fora de escopo, não aprovada.
- Executar 20 sequências salvar → encerrar → reiniciar aparelho → reabrir; verificar progressão/equipe/inventário/posição, 20/20 corretas. Simular armazenamento insuficiente e corrupção para confirmar erro visível e recuperação.
- Após prazo de renovação gratuita, reinstalar IPA por cima com mesma conta e bundle ID, **sem remover o app**, e verificar restauração sem exportação manual. Fazer backup independente antes de testes arriscados; backup não substitui a exigência de preservação automática.
- Cinco sessões de usabilidade: ao menos quatro participantes completam deslocamento, diálogo, batalha e save sem instrução adicional.

**Critério de parada**: qualquer caso essencial pendente, divergente, bloqueado, falta de direitos para distribuição ou falha de instalação/save impede alegar port completo; relatar exceções e caminho condicionado.
