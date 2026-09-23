---
name: radar
description: Atualiza o radar de tecnologia deste projeto — verifica releases e incidentes de segurança das ferramentas instaladas, pesquisa novidades por domínio (WhatsApp, geolocalização, turismo, educação, mobile, pagamentos) e descobre ferramentas novas. Use quando o usuário pedir "/radar", "atualiza o radar", "o que há de novo" ou "novidades".
---

# Atualização do radar

Siga `CLAUDE.md` do projeto. **Não instale nada** — só pesquise, registre e recomende.

Argumento opcional: um domínio ou ferramenta para focar (ex.: `/radar whatsapp`). Sem argumento: atualização completa.

## Passos

1. **Contexto.** Leia `radar/radar.md` e `radar/fontes.md`. Descubra a data da última revisão (maior data na coluna "Revisado") e o relatório mais recente em `radar/pesquisas/`.

2. **Segurança primeiro.** Para cada ferramenta instalada (tabela "Ferramentas instaladas" em `radar/fontes.md`):
   - última release (`gh api repos/<repo>/releases/latest`, ou a fonte indicada);
   - busca web por `"<nome>" vulnerability OR CVE OR malicious OR compromised` desde a última revisão;
   - se o repositório foi arquivado, trocou de dono ou mudou de licença.
   Qualquer incidente → seção **⚠️ Segurança** no topo do relatório, com o que fazer.

3. **Novidades por domínio.** Para cada domínio em `radar/fontes.md`, busque mudanças desde a última revisão: preços, políticas, APIs novas ou descontinuadas, SDKs, MCPs oficiais novos. Priorize o que afeta os projetos atuais (cardápio WhatsApp, ScanTE, AprovIA, turismo, apps).

4. **Descoberta.** Procure ferramentas novas (MCPs, plugins, skills, bibliotecas) em GitHub trending, marketplace oficial (commits recentes em `anthropics/claude-plugins-official`) e diretórios. Para cada candidata registre: o que faz, mantenedor, ⭐, última release, oficial x comunidade, dados locais x externos (para onde), riscos.

5. **Relatório.** Crie `radar/pesquisas/AAAA-MM-DD-radar.md` (data de hoje) com:
   - ⚠️ Segurança (se houver)
   - 🔔 Mudanças que exigem ação (com prazo, se houver)
   - 🆕 Novidades por domínio
   - 🔭 Ferramentas descobertas
   - 🔁 Mudanças de anel propostas (de → para, e por quê)
   - Fontes (links)

6. **Tabela.** Atualize `radar/radar.md`: data "Revisado" das entradas verificadas, novas linhas para descobertas relevantes e mudanças de anel. Não apague linhas — mova para "Evitar" ou marque como "(descontinuado)".

7. **Resumo ao usuário.** No chat: até 5 destaques, o que exige ação e a pergunta "quer que eu instale/teste algum destes?" — instalações só depois do sim, uma por uma, seguindo `docs/setup-ambiente.md`.
