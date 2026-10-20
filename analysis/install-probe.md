# Ensaio de instalação pessoal — pendente

**Status:** não executado; nenhum IPA compilado/assinado, iPhone ou conta Apple disponíveis nesta sessão Windows. Shell SwiftUI e workflow existem, mas não foram validados pelo Xcode. Um workflow escrito não comprova instalação. A versão iOS 26.6.2 é a declarada pelo usuário, não observada nesta sessão.

1. Depois de obter em runner macOS um IPA **sem assinatura nem ROM** e passar inspeção de conteúdo (`analysis/release-gates.md`), baixar exclusivamente o artefato de build limpo no Windows. Registrar SHA-256, build ID, versão, bundle ID e versão efetiva de Xcode. Não colocar ROM ou credenciais no CI.
2. Instalar Sideloadly no Windows com versões de iTunes/iCloud obtidas dos sites oficiais, não Microsoft Store. Conectar o iPhone 15 Pro Max e selecionar IPA. Assinar com Apple ID **apenas neste PC**; não registrar conta/senha em arquivo, prints, logs compartilhados ou repositório.
3. Ativar Developer Mode e confirmar confiança no certificado caso iOS solicite. Instalar, abrir e registrar evidências de execução, versão exata de iOS e erros (sem capturar segredos). Se Sideloadly rejeitar a estrutura da IPA, registrar saída sanitizada e marcar bloqueado; não inferir suporte prático de material promocional do fornecedor.
4. Quando houver importação implementada, importar a cópia pessoal via Files no aparelho, pôr em modo avião e testar abertura/offline; este ensaio não substitui a campanha nem save.
5. Para renovação gratuita (~7 dias), conservar Apple ID e bundle ID, instalar **por cima sem desinstalar**, verificar save automaticamente após reabrir. Backup separado antes do ensaio é contingência, não evidência de preservação automática. Expiração não deve ser contornada.

| Campo de evidência | Valor neste ambiente |
|---|---|
| Build/artefato SHA-256 | não produzido |
| Bundle ID | `org.fireredport.installprobe` no projeto local; build ainda não validado |
| Xcode/runner | não executado |
| Dispositivo/versão iOS observados | indisponível |
| Conta/assinatura | não tentada |
| Instalação/abertura | **bloqueada até ensaio real** |
| Importação/uso offline | não testados |
| Save/renovação | não testados |

Referências de procedimento: [Sideloadly FAQ](https://sideloadly.io/faq.html), [Apple Personal Team](https://developer.apple.com/help/account/basics/about-your-developer-account/), [Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device). Dependências e resultados reais deverão atualizar esta tabela antes de aprovação.
