# Verificações de viabilidade

Legenda: **observado** exige resultado reprodutível; **pendente** não é aprovação; **bloqueado** impede entrega. Não confundir checklist de qualidade da especificação com conclusão de implementação.

| Caso | Como verificar | Estado (2026-10-20) | Evidência / próximo passo |
|---|---|---|---|
| Identidade coincidente | Hash SHA-256 integral e tamanho, depois cabeçalho | observado localmente | `analysis/reference-identity.md`; repetir antes de interpretar offsets |
| Identidade divergente ou arquivo truncado | Comparar digest/tamanho a cada importação e recusar variantes | pendente | Necessita app e testes sintéticos |
| Estático versus runtime | Toda afirmação incluir método, localização, limitação | pendente | `analysis/evidence-schema.md`; auditar relatório |
| Cobertura dos 11 subsistemas | Matriz com estados e evidências | pendente | `analysis/parity-matrix.md`, `analysis/subsystems.md` |
| Direitos para análise/uso pessoal | Solicitar avaliação jurídica aplicável e procedência | pendente | Não inferir direitos pelo hash |
| Direitos de distribuição | Autorização verificável antes de distribuir conteúdo | bloqueado | Não publicar ROM/recursos/branding |
| Build limpo sem credenciais/ROM | Inspecionar fonte, logs, caches e IPA do CI | pendente | Runner macOS/Xcode ainda não executado |
| Assinatura e instalação | Assinar IPA localmente no Windows e abrir no iPhone real | pendente | Aparelho/Apple ID não acessíveis neste ambiente |
| Save após renovação gratuita | Reinstalar por cima com mesmo Apple ID e bundle ID | pendente | Exige espera/ensaio real; falha bloqueante |

Nenhuma afirmação de jogo funcional ou instalação aprovada segue deste documento. Em caso de divergência na identidade, interromper todas as inferências baseadas em offsets anteriores.
