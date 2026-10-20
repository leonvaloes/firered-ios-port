# Identidade da referência local — T005

Em 2026-10-20, repetida a medição local do arquivo privado na raiz do workspace (leitura de bytes pelo PowerShell, **não** Evidence do REA):

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath 'Pokemon - FireRed Version (USA).gba'
(Get-Item -LiteralPath 'Pokemon - FireRed Version (USA).gba').Length
```

| Propriedade | Resultado observado |
| --- | --- |
| Tamanho | 16777216 bytes (16.777.216) |
| SHA-256 integral | `3d0c79f1627022e18765766f6cb5ea067f6b5bf7dca115552189ad65a5c3a8ac` (PowerShell exibiu maiúsculas; comparação hexadecimal sem distinção de caixa) |
| Cabeçalho, conforme leitura local anterior em `specs/001-port-nativo-firered/viabilidade-inicial.md` e `research.md` | Título `POKEMON FIRE` (0xA0), código `BPRE` (0xAC), fabricante `01` (0xB0), versão `00` (0xBC), valor fixo `0x96`, complemento armazenado `0x68` (0xBD), complemento recalculado `0x68` |

O hash e tamanho acima foram novamente verificados neste trabalho; os campos do cabeçalho foram **transcritos da medição anterior**, não reextraídos aqui. Identificação compatível com FireRed americana, mas nome, cabeçalho e checksum não provam integridade completa, revisão comercial exata, procedência lícita, propriedade ou direito de uso/distribuição. Não foi feita análise de código nem execução da ROM. Nenhum offset de tabelas ou rotinas está validado por esta medição.

**Regra de parada:** antes de usar quaisquer offsets ou perfis derivados desta referência, recalcular SHA-256 integral e tamanho do arquivo efetivamente selecionado; se qualquer um divergir, recusar o perfil e interromper a análise/uso de offsets até identificar e validar separadamente a nova referência. Não publicar ROM, extratos de bytes ou recursos protegidos. Fontes: medição local acima; `specs/001-port-nativo-firered/{viabilidade-inicial.md,research.md}`.
