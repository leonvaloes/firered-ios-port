import SwiftUI
import SpriteKit

@main
struct FireRedPortApp: App {
    @State private var showingImportSheet = false
    @State private var showingSaveSheet = false
    @State private var showingDiagnosticsSheet = false
    @State private var gameState = GameState()
    @State private var importedROM: ROMDataReader?
    @State private var importStatus = "Nenhuma cópia privada verificada nesta sessão."
    @State private var isPlaying = false
    @State private var currentMapLayout: MapLayoutData?
    @State private var actionMessage: String?
    @State private var gameScene = GameScene(size: CGSize(width: 320, height: 320))

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isPlaying, importedROM != nil {
                    overworldView
                } else {
                    mainMenuView
                }
            }
            .sheet(isPresented: $showingImportSheet) {
                ROMImportView(onVerified: { reader in
                    importedROM = reader
                    importStatus = "Cópia privada identificada (USA, versão 0). Pronto para jogar!"
                    showingImportSheet = false
                    startGame()
                }, onInvalidated: {
                    importedROM = nil
                    isPlaying = false
                    importStatus = "Verificando nova importação."
                })
            }
            .sheet(isPresented: $showingSaveSheet) {
                SaveMenuView()
            }
            .sheet(isPresented: $showingDiagnosticsSheet) {
                DiagnosticsView()
            }
            .task {
                await DiagnosticLog.shared.record(.appOpened)
                do {
                    if let reader = try LocalROMImporter.restoreVerifiedCopy() {
                        importedROM = reader
                        importStatus = "Cópia privada revalidada (USA, versão 0). Pronto para jogar!"
                        startGame()
                    }
                } catch {
                    importedROM = nil
                    importStatus = "Cópia privada inválida ou inacessível. Importe novamente."
                }
            }
        }
    }

    private var overworldView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentMapLayout?.name ?? gameState.position.mapId)
                        .font(.headline)
                    Text("Pos: (\(gameState.position.x), \(gameState.position.y)) • \(gameState.position.facing.rawValue.uppercased())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("Salvar") {
                    showingSaveSheet = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Menu") {
                    isPlaying = false
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemBackground))

            SpriteView(scene: gameScene)
                .frame(minHeight: 260, maxHeight: 360)
                .background(Color.black)
                .cornerRadius(8)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

            if let msg = actionMessage {
                Text(msg)
                    .font(.caption)
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(6)
                    .padding(.horizontal)
            }

            Spacer()

            HStack(alignment: .center, spacing: 20) {
                VStack(spacing: 2) {
                    Button(action: { handleMove(.north) }) {
                        Image(systemName: "chevron.up")
                            .font(.title2.bold())
                            .frame(width: 56, height: 48)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    HStack(spacing: 8) {
                        Button(action: { handleMove(.west) }) {
                            Image(systemName: "chevron.left")
                                .font(.title2.bold())
                                .frame(width: 48, height: 48)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 28, height: 28)
                            .cornerRadius(4)
                        Button(action: { handleMove(.east) }) {
                            Image(systemName: "chevron.right")
                                .font(.title2.bold())
                                .frame(width: 48, height: 48)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                    }
                    Button(action: { handleMove(.south) }) {
                        Image(systemName: "chevron.down")
                            .font(.title2.bold())
                            .frame(width: 56, height: 48)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }

                Spacer()

                HStack(spacing: 14) {
                    VStack {
                        Spacer().frame(height: 20)
                        Button(action: { handleActionB() }) {
                            Text("B")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 54, height: 54)
                                .background(Color.red.opacity(0.85))
                                .clipShape(Circle())
                        }
                    }
                    VStack {
                        Button(action: { handleActionA() }) {
                            Text("A")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 54, height: 54)
                                .background(Color.blue.opacity(0.85))
                                .clipShape(Circle())
                        }
                        Spacer().frame(height: 20)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private var mainMenuView: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)

            Text("FireRed Port")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Execução nativa offline para iOS")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Estado da Campanha")
                    .font(.headline)
                Text("Jogador: \(gameState.player.name)")
                Text("Mapa: \(gameState.position.mapId)")
                Text("Posição: (\(gameState.position.x), \(gameState.position.y))")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            Text(importStatus)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("romSessionStatus")

            if importedROM != nil {
                Button(action: { startGame() }) {
                    Label("Iniciar Partida (Pallet Town)", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }

            HStack(spacing: 16) {
                Button("Importar ROM") {
                    showingImportSheet = true
                }
                .buttonStyle(.borderedProminent)

                Button("Menu de Save") {
                    showingSaveSheet = true
                }
                .buttonStyle(.bordered)
            }

            Button("Diagnóstico") { showingDiagnosticsSheet = true }
                .buttonStyle(.bordered)

            Spacer()

            Text("Nenhum código ARM emulado. Dados de jogo lidos da cópia privada local.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Início")
    }

    private func startGame() {
        guard let reader = importedROM else { return }
        do {
            let bank: Int
            let map: Int
            if gameState.position.mapId.contains("2F") {
                bank = 4; map = 1
            } else if gameState.position.mapId.contains("1F") {
                bank = 4; map = 0
            } else if gameState.position.mapId.contains("OAK") {
                bank = 4; map = 3
            } else {
                bank = 3; map = 0
            }
            let layout = try reader.loadMapLayout(bank: bank, map: map)
            self.currentMapLayout = layout
            gameState.position.mapId = layout.name
            gameScene.loadMapLayout(layout)
            gameScene.updatePresentation(from: gameState)
            self.isPlaying = true
            self.actionMessage = "Você está em \(layout.name). Use o D-Pad para andar!"
        } catch {
            importStatus = "Erro ao carregar mapa da ROM: \(error)"
        }
    }

    private func handleMove(_ direction: GridPosition.Direction) {
        guard let layout = currentMapLayout else { return }
        actionMessage = nil
        let result = OverworldEngine.step(from: gameState.position, direction: direction) { targetPos in
            layout.isPassable(x: targetPos.x, y: targetPos.y)
        }
        switch result {
        case .moved(to: let newPos):
            gameState.position = newPos
            if let warp = OverworldEngine.checkWarp(mapName: layout.name, x: newPos.x, y: newPos.y) {
                transitionToMap(bank: warp.bank, map: warp.map, x: warp.x, y: warp.y, facing: warp.facing)
            } else {
                gameScene.updatePresentation(from: gameState)
            }
        case .changedFacing(to: let newDirection):
            gameState.position.facing = newDirection
            gameScene.updatePresentation(from: gameState)
        case .blocked:
            gameState.position.facing = direction
            gameScene.updatePresentation(from: gameState)
        }
    }

    private func transitionToMap(bank: Int, map: Int, x: Int, y: Int, facing: GridPosition.Direction) {
        guard let reader = importedROM else { return }
        do {
            let layout = try reader.loadMapLayout(bank: bank, map: map)
            self.currentMapLayout = layout
            gameState.position = GridPosition(mapId: layout.name, x: x, y: y, facing: facing)
            gameScene.loadMapLayout(layout)
            gameScene.updatePresentation(from: gameState)
            actionMessage = "Entrou em \(layout.name)."
        } catch {
            actionMessage = "Falha ao carregar próximo mapa."
        }
    }

    private func handleActionA() {
        actionMessage = "Interação em (\(gameState.position.x), \(gameState.position.y))"
    }

    private func handleActionB() {
        actionMessage = "Modo de corrida ativado."
    }
}
