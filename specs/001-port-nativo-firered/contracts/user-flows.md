# Contrato de interface para o usuário — proposta

Este contrato especifica comportamento esperado; ainda não há app implementado. Ver [modelo de dados](../data-model.md) para entidades e estados.

## Importar ROM

1. Tela inicial oferece **Importar arquivo local** pelo seletor Files; app não pede conta nem transmite arquivo.
2. App obtém acesso temporário ao arquivo selecionado, calcula SHA-256 integral, verifica tamanho e perfil de cabeçalho, e só então copia para área privada, com leitura sujeita a limites.
3. Hash suportado permite **Nova partida** / **Continuar**; hash diferente, arquivo truncado ou falta de espaço apresenta causa e ação **Escolher outro arquivo**, sem iniciar leitura de offsets não verificados.
4. Mensagem informa que usuário deve ter direitos pertinentes ao próprio arquivo; ausência de direitos de redistribuição impede publicação do jogo e recursos.

## Jogo e salvamento

- Controles por toque oferecem movimento, interação, confirmação, cancelamento e menu; áudio e pausa respeitam ciclo de vida do iOS. A campanha individual em inglês pode ser jogada offline depois da importação. Não oferecer troca/online na primeira entrega.
- **Salvar** só confirma sucesso após escrita e validação do snapshot. Em falha, mensagem visível, estado da sessão mantido e último save íntegro preservado. **Continuar** mostra incompatibilidade de ROM/schema ou corrupção e oferece recuperação do save anterior quando válida, sem sobrescrever silenciosamente.
- Ao restaurar, reproduzir o estado comprometido de personagem, equipe, inventário, posição e progresso; rotina de 20/20 reaberturas inclui reinício do telefone.

## Distribuição e instalação pessoal

- Artefato público contém somente código e recursos próprios; nunca ROM, dados extraídos dela, conta Apple ou perfis de assinatura. IPA unsigned do CI é instalada apenas depois de assinatura local no Windows do usuário.
- Guia de instalação indica requisitos Sideloadly, Developer Mode/confiança quando exigidos, limites da conta gratuita e renovação em torno de sete dias. Na renovação, mesma conta e bundle ID, instalar por cima **sem desinstalar**; testar preservação do save e interromper entrega se falhar.
- Tela/relatório de cobertura distingue `testado`, `parcial` e `não verificado`, mostra comunicação fora de escopo e nunca anuncia “100% funcional” sem todos os casos essenciais aprovados.

## Segurança e privacidade

- Arquivo e saves permanecem no container local; nenhum upload. ROM é entrada não confiável: recusar identidade desconhecida; tratamento de erros sem expor bytes protegidos em logs/artefatos.
