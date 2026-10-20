import SwiftUI

@main
struct FireRedPortApp: App {
    @State private var showingImportSheet = false
    @State private var showingSaveSheet = false
    @State private var showingDiagnosticsSheet = false
    @State private var gameState = GameState()
    @State private var importedROM: ROMDataReader?
    @State private var importStatus = "Nenhuma cópia privada verificada nesta sessão."

    var body: some Scene {
        WindowGroup {
            NavigationStack {
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
                        Text("Estado da Campanha (Sintético)")
                            .font(.headline)
                        Text("Jogador: \(gameState.player.name)")
                        Text("Mapa: \(gameState.position.mapId)")
                        Text("Posição: (\(gameState.position.x), \(gameState.position.y))")
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                    Text(importStatus)
                        .font(.footnote)
                        .accessibilityIdentifier("romSessionStatus")

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

                    Text("Nenhum código ARM emulado. Dados de jogo protegidos não incluídos no pacote.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .navigationTitle("Início")
                .sheet(isPresented: $showingImportSheet) {
                    ROMImportView(onVerified: { reader in
                        importedROM = reader
                        importStatus = "Cópia privada identificada (USA, versão 0). Campanha indisponível."
                    }, onInvalidated: {
                        importedROM = nil
                        importStatus = "Verificando nova importação. Campanha indisponível."
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
                            importStatus = "Cópia privada revalidada (USA, versão 0). Campanha indisponível."
                        }
                    } catch {
                        importedROM = nil
                        importStatus = "Cópia privada inválida ou inacessível. Importe novamente; campanha indisponível."
                    }
                }
            }
        }
    }
}
