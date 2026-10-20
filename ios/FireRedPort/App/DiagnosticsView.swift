import SwiftUI

/// Diagnostics are ephemeral and only shared by explicit user action.
struct DiagnosticsView: View {
    @State private var report = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Diagnóstico seguro").font(.title2.bold())
                Text("Este registro contém apenas horário e códigos de eventos permitidos. Não inclui ROM, saves, nomes de arquivos, caminhos ou credenciais. Confira o texto antes de enviá-lo.")
                Button("Atualizar registro") { Task { await refresh() } }
                if !report.isEmpty {
                    Text(report)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                    ShareLink(item: report) { Label("Compartilhar registro", systemImage: "square.and.arrow.up") }
                }
                Button("Apagar registro", role: .destructive) {
                    Task {
                        await DiagnosticLog.shared.clear()
                        await refresh()
                    }
                }
            }
            .padding()
        }
        .task { await refresh() }
    }

    @MainActor private func refresh() async {
        report = await DiagnosticLog.shared.exportText()
    }
}
