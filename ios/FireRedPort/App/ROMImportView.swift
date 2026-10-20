import SwiftUI
import UniformTypeIdentifiers

/// Import screen reports an identified private copy; gameplay remains blocked.
struct ROMImportView: View {
    let onVerified: (ROMDataReader) -> Void
    let onInvalidated: () -> Void
    @State private var showingPicker = false
    @State private var importing = false
    @State private var status = "Nenhuma ROM importada. Jogo não implementado."

    var body: some View {
        VStack(spacing: 18) {
            Text("Importação local").font(.title)
            Text("Selecione apenas uma cópia que você tem direito de usar. O aplicativo não fornece ROMs nem envia dados a servidores.")
                .multilineTextAlignment(.center)
            Button("Selecionar arquivo novamente") { showingPicker = true }
                .disabled(importing)
            if importing { ProgressView("Verificando arquivo integral...") }
            Text(status).multilineTextAlignment(.center).accessibilityIdentifier("romImportStatus")
            Text("Extração e jogo bloqueados até a validação das estruturas da referência.")
                .font(.footnote).multilineTextAlignment(.center)
        }
        .padding()
        .fileImporter(isPresented: $showingPicker, allowedContentTypes: [.data], allowsMultipleSelection: false) { result in
            switch result {
            case .failure:
                status = "Não foi possível acessar o arquivo. Selecione novamente."
                Task { await DiagnosticLog.shared.record(.importAccessFailed) }
            case .success(let urls):
                guard let url = urls.first else { return }
                onInvalidated()
                importing = true
                status = "Verificando identidade..."
                Task.detached(priority: .userInitiated) {
                    await DiagnosticLog.shared.record(.importStarted)
                    let message: String
                    let event: DiagnosticLog.Event
                    do {
                        let reader = try LocalROMImporter.importSelectedFile(url)
                        // Keep the reader in the app session only after the private
                        // copy has been independently checked as well.
                        try reader.verifyIdentity()
                        await MainActor.run { onVerified(reader) }
                        message = "Cópia local verificada. Jogo e extração ainda não implementados."
                        event = .importVerified
                    } catch ROMImportError.truncated {
                        message = "Arquivo truncado. Selecione novamente."
                        event = .importTruncated
                    } catch ROMImportError.incompatible {
                        message = "ROM desconhecida ou alterada. Selecione a referência compatível."
                        event = .importIncompatible
                    } catch ROMImportError.invalidHeader {
                        message = "Cabeçalho inválido. Selecione novamente."
                        event = .importInvalidHeader
                    } catch ROMImportError.insufficientSpace {
                        message = "Espaço insuficiente ou falha ao salvar cópia local. Libere espaço e tente novamente."
                        event = .importInsufficientSpace
                    } catch {
                        message = "Sem acesso ao arquivo. Selecione novamente."
                        event = .importAccessFailed
                    }
                    await DiagnosticLog.shared.record(event)
                    await MainActor.run {
                        status = message
                        importing = false
                    }
                }
            }
        }
    }
}
