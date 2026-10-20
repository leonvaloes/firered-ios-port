import SwiftUI

/// Safe user-facing menu for persisting state, loading saves, or recovering from corruption.
public struct SaveMenuView: View {
    @State private var statusMessage: String = "Pronto"
    @State private var isProcessing: Bool = false

    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            Text("Gerenciamento de Partida")
                .font(.headline)

            Button("Salvar Jogo") {
                triggerSave()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing)

            Button("Recuperar Backup") {
                triggerRecovery()
            }
            .buttonStyle(.bordered)
            .disabled(isProcessing)

            Text(statusMessage)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func triggerSave() {
        statusMessage = "Gravação atômica em progresso..."
        // Production binding will route to SaveStore.save(snapshot)
    }

    private func triggerRecovery() {
        statusMessage = "Recuperando último snapshot intacto..."
        // Production binding will route to SaveStore.recoverLastIntact
    }
}
