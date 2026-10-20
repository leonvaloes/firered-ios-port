# Viabilidade — relatório parcial (2026-10-20)

**Conclusão:** viabilidade de um port completo **não demonstrada**. Este relatório registra observações locais auditáveis e gates abertos; não é alegação de aplicativo pronto, de autorização jurídica ou de paridade. `analysis/viability-checklist.md` acompanha os casos; `analysis/subsystems.md` é inventário incompleto e `analysis/parity-matrix.md` não tem aprovação em aparelho.

## ArquivoDeReferencia

- `id`: `75c634e3-88d0-4e5d-ad7a-385f98de7835` (identificador documental, não extraído da ROM).
- `nomeLocal`: `Pokemon - FireRed Version (USA).gba` (somente local; não empacotar nem publicar).
- `tamanhoBytes`: `16777216` (>0); `sha256`: `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` (64 hexadecimais).
- `regiao`: candidata USA pelo nome e código `BPRE`; `versao`: byte de cabeçalho `0x00`, **não** revisão comercial comprovada; `origemDeclarada`: arquivo fornecido no workspace pelo usuário, sem comprovação de titularidade; `verificadoEm`: 2026-10-20.
- **Origem/método/limite:** `analysis/reference-identity.md` mede o arquivo local; `analysis/ghidra-session.md` registra importação independente no Ghidra ARM little-endian com bloco `08000000–08ffffff`, cabeçalho e salto estático `08000000 → 08000204`. Hash identifica bytes, não direitos, integridade da campanha, revisão comercial ou execução. Resultado Ghidra **não é Evidence REA**.

## Evidências e lacunas

| Afirmação | Tipo e fonte | Limite |
|---|---|---|
| SHA-256, tamanho e cabeçalho acima | observação local; `analysis/reference-identity.md` | corresponde apenas ao arquivo presente na data |
| Mapeamento raw e bootstrap inicial | observado-estatico; `analysis/ghidra-session.md` | não foi executado; modo Thumb subsequente ainda inferido |
| REA/Ghidra Windows não admite raw ARM | erro de capacidade observado; `analysis/rea-capability.md` | não prova que Ghidra independente ou outros ambientes não suportem ROM |
| Subsistemas: entrada e escrita inicial de paleta | observado-estatico limitado; `analysis/subsystems.md` | não demonstram interação ou gráficos em execução; demais rotinas e paridade ainda desconhecidas |
| Shell de instalação e workflow de IPA não assinada | código estático presente em `ios/FireRedPort/App/FireRedPortApp.swift`, `ios/FireRedPort.xcodeproj/project.pbxproj`, `.github/workflows/ios-build.yml` | Xcode/CI não executados; workflow lista restrita rejeita novas fontes, portanto componentes de importação/save separados ainda não compõem o app |
| Build IPA sem ROM, assinatura Windows e instalação | desconhecido; `analysis/install-probe.md` | exige runner macOS, PC/conta do usuário e iPhone real |
| Campanha, save e renovação | desconhecido; `analysis/parity-matrix.md` | nenhum roteiro/20 ciclos/renovação executados |

## Direitos e gates (T043)

- **Uso pessoal e engenharia reversa — pendente de avaliação, não autorizado por este relatório:**
  - *Fontes a verificar:* legislação e exceções aplicáveis na jurisdição efetiva do usuário (por exemplo, Lei 9.609/1998 e Lei 9.610/1998 no Brasil ou 17 U.S.C. § 117 e § 1201(f) nos EUA). A citação dessas normas **não** determina por si só que a cópia, análise, importação ou uso concreto sejam permitidos; verificar também origem e eventuais restrições contratuais/técnicas com orientação jurídica competente.
  - *Responsável:* o usuário deve fornecer comprovação de procedência da cópia e obter avaliação específica antes de afirmar autorização. Não foi comprovada posse de cartucho original, procedimento de dump ou jurisdição aplicável.
  - *Limites:* o hash e a presença da ROM local comprovam somente identidade dos bytes, não legitimidade de obtenção, direitos sobre marcas ou autorização de distribuição. Gate de uso pessoal: **pendente**.
- **Condições para distribuição e licenciamento comercial:**
  - *Fonte e titulares:* Marcas registradas "Pokémon", "FireRed", designs de criaturas, diálogos, áudios e sprites são propriedade exclusiva de Nintendo Co., Ltd., The Pokémon Company e Game Freak Inc.
  - *Responsável:* Qualquer entidade ou desenvolvedor que disponibilize o aplicativo ao público.
  - *Bloqueio intransponível:* **Distribuição do jogo, ROM, recursos multimídia extraídos ou binários compilados contendo propriedade intelectual é bloqueada de forma absoluta**, salvo se obtida licença formal escrita dos detentores dos direitos. A autoria limpa do código-fonte (clean-room) não convalida a distribuição de ativos gráficos, musicais ou narrativos protegidos.
- **Build/instalação:** o GitHub Actions produziu e testou um IPA não assinado (run `39462349022`; `analysis/install-probe.md`); isso não demonstra assinatura Sideloadly nem instalação/abertura no iPhone. Assinatura e ensaio físico permanecem pendentes, sem segredos no CI.
- **Cobertura/entrega:** nenhum subsistema consta `testado`; T012 inventário ainda incompleto. Port não pode ser anunciado como funcional, muito menos “100% funcional”, antes de campanha individual em inglês até créditos, todos os casos essenciais aprovados no aparelho, save 20/20 e renovação sem perda.

## Aplicação do checklist (T018 — parcial)

Conferi `analysis/viability-checklist.md` contra este relatório: identidade observada com fonte e limite; identidade divergente, runtime, subsistemas, direitos de uso pessoal, build limpo, assinatura e renovação permanecem pendentes; distribuição sem autorização fica bloqueada. `analysis/parity-matrix.md` contém todos os subsistemas exigidos, porém nenhum aprovado; `analysis/subsystems.md` localiza bootstrap, uma leitura de entrada e escrita pontual de paleta; não identifica com segurança mapas, áudio, diálogos, itens, batalhas, progressão ou persistência. Alternativas condicionais: reavaliar hash novo antes de qualquer offset; investigação dirigida Ghidra/ambiente REA compatível para análise; avaliação jurídica antes de distribuir; build em macOS sem segredos e assinatura local em Windows se houver IPA compatível. Assim, **a revisão documental não aprova os gates e não conclui a viabilidade**.

**Ações seguintes:** completar inventário Ghidra com limites, validar build no runner macOS, testar IPA real/assinatura no iPhone, criar casos e implementação nativa com regras comprovadas, verificar persistência e direitos. Estado detalhado de cada etapa em `specs/001-port-nativo-firered/tasks.md`.
