import SwiftUI

@main
struct FireRedPortApp: App {
    @State private var showingImportSheet = false
    @State private var showingSaveSheet = false
    @State private var showingDiagnosticsSheet = false
    @State private var gameState = GameState()

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
                    ROMImportView()
                }
                .sheet(isPresented: $showingSaveSheet) {
                    SaveMenuView()
                }
                .sheet(isPresented: $showingDiagnosticsSheet) {
                    DiagnosticsView()
                }
                .task { await DiagnosticLog.shared.record(.appOpened) }
            }
        }
    }
}
