import SwiftUI

/// Save UI stays unavailable until campaign state is wired to persistent snapshots.
public struct SaveMenuView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            Text("Gerenciamento de Partida")
                .font(.headline)

            Text("Salvar e recuperar indisponíveis: a campanha ainda não está conectada ao armazenamento.")
                .font(.footnote)
                .multilineTextAlignment(.center)
            Button("Salvar Jogo") {}
                .buttonStyle(.borderedProminent)
                .disabled(true)
            Button("Recuperar Backup") {}
                .buttonStyle(.bordered)
                .disabled(true)
        }
        .padding()
    }

}
