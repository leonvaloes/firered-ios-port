# Port iOS — Arquitetura e Implementação Nativa

Estrutura implementada no projeto:

```text
ios/
├── FireRedPort.xcodeproj/             # Projeto Xcode (targets: FireRedPort e FireRedPortTests)
│   └── xcshareddata/xcschemes/
│       └── FireRedPort.xcscheme       # Scheme compartilhado configurado para build e testes
├── FireRedPort/
│   ├── App/
│   │   ├── FireRedPortApp.swift       # Ciclo de vida e navegação com sheets de importação e save
│   │   ├── ROMImportView.swift        # Interface segura para seleção local de ROM
│   │   └── SaveMenuView.swift         # Interface para salvar, carregar e restaurar backup
│   ├── Domain/
│   │   ├── GameState.swift            # Modelo autoritativo de estado da campanha (independente de UI)
│   │   ├── OverworldEngine.swift      # Motor de movimento, colisão e flags de eventos
│   │   ├── BattleEngine.swift         # Motor determinístico de cálculo de combate e dano
│   │   ├── ReferenceProfile.swift     # Perfil de identidade e bloqueio estrito de extração
│   │   └── ROMDataReader.swift        # Leitor de dados delimitado e importador local seguro
│   ├── Rendering/
│   │   ├── GameScene.swift            # Cena 2D SpriteKit desacoplada da autoridade de regras
│   │   └── GameAudio.swift            # Gerenciador de ciclo de áudio sem áudio protegido embutido
│   ├── Persistence/
│   │   ├── SaveSnapshot.swift         # Snapshot serializável com digest de integridade SHA-256
│   │   └── SaveStore.swift            # Actor com gravação atômica em disco e backup de recuperação
│   └── Resources/                     # Apenas recursos autorais; nenhuma ROM ou asset protegido
└── FireRedPortTests/                  # Suíte unitária XCTest integrada ao projeto
    ├── ROMImportTests.swift           # Validação sintética de integridade, limites e bloqueios de ROM
    ├── SaveStoreTests.swift           # Testes sintéticos de round-trip, integridade e recuperação
    └── GameplayParityTests.swift      # Testes sintéticos de movimento, colisão e cálculo de combate
```

### Targets e Configuração

1. **`FireRedPort`**: Aplicação SwiftUI para iOS 17.0+ (Bundle ID: `org.fireredport.installprobe`).
2. **`FireRedPortTests`**: Target nativo de testes unitários XCTest (`com.apple.product-type.bundle.unit-test`) associado ao scheme `FireRedPort`. Todas as 3 suítes utilizam asserções ativas sobre as APIs de produção, sem `XCTSkip` e sem fixtures de conteúdo proprietário.

### Execução e Ambiente

- **Ambiente local:** Windows 11 x64. Como a toolchain Swift/Xcode (`xcodebuild`) não existe nativamente no Windows, **nenhuma compilação ou execução de testes foi realizada nesta máquina**.
- **Automação CI (`.github/workflows/ios-build.yml`):** Executa em runner `macos-latest`, realiza auditoria estrita de inventário, compila o app, executa a suíte `xcodebuild test` no simulador e empacota o IPA unsigned.
- **Validação no aparelho real:** Instalação e execução de campanha exigem assinatura via Sideloadly no Windows do usuário e teste em iPhone 15 Pro Max físico. Nenhuma aprovação em hardware foi presumida.
