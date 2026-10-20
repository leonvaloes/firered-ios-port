# Diagnóstico seguro para ensaios no iPhone

A aba **Diagnóstico** do app oferece **Atualizar registro**, **Compartilhar registro** e **Apagar registro**. O compartilhamento só ocorre quando a pessoa toca no botão e escolhe um destino; nada é enviado automaticamente. O registro é mantido **somente em memória**, até o app encerrar, e conserva no máximo 100 eventos. Não é um log da ROM nem um dump da execução do jogo.

Formato: cabeçalho `FireRedPort diagnostics v1`, seguido por timestamp UTC ISO-8601 e **código fixo permitido**. Códigos: `APP_OPENED`, `IMPORT_STARTED`, `IMPORT_VERIFIED`, `IMPORT_TRUNCATED`, `IMPORT_INCOMPATIBLE`, `IMPORT_INVALID_HEADER`, `IMPORT_INSUFFICIENT_SPACE`, `IMPORT_ACCESS_FAILED`. Nunca incluir valores livres: caminhos, conteúdo de ROM, saves, capturas de tela, dados da conta Apple ou hashes privados não são registrados. A pessoa deve ler o texto antes de enviá-lo.

Para um futuro teste solicitado: abrir o app, reproduzir o problema, abrir **Diagnóstico**, tocar **Atualizar registro**, conferir e compartilhar **somente o texto seguro**. Se o app fechar inesperadamente, este log em memória desaparece; não solicitar o arquivo ROM, contêiner do app ou logs completos do dispositivo sem uma revisão de privacidade específica.

Limite: esse registro diagnostica a importação e a abertura, não comprova campanha jogável, save, FPS nem paridade. A extensão futura a eventos de gameplay requer categorias estritamente allowlisted e testes de privacidade antes de ativar.
