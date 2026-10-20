import SwiftUI
import UniformTypeIdentifiers

/// Standalone import screen; not wired into FireRedPortApp until integration work is done.
struct ROMImportView: View {
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
            case .success(let urls):
                guard let url = urls.first else { return }
                importing = true
                status = "Verificando identidade..."
                Task.detached(priority: .userInitiated) {
                    let message: String
                    do {
                        _ = try LocalROMImporter.importSelectedFile(url)
                        message = "Cópia local verificada. Jogo e extração ainda não implementados."
                    } catch ROMImportError.truncated {
                        message = "Arquivo truncado. Selecione novamente."
                    } catch ROMImportError.incompatible {
                        message = "ROM desconhecida ou alterada. Selecione a referência compatível."
                    } catch ROMImportError.invalidHeader {
                        message = "Cabeçalho inválido. Selecione novamente."
                    } catch ROMImportError.insufficientSpace {
                        message = "Espaço insuficiente ou falha ao salvar cópia local. Libere espaço e tente novamente."
                    } catch {
                        message = "Sem acesso ao arquivo. Selecione novamente."
                    }
                    await MainActor.run {
                        status = message
                        importing = false
                    }
                }
            }
        }
    }
}
