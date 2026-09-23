# potenciaVScode — Radar de Tecnologia + Setup do ambiente

Projeto de pesquisa contínua (não é código de produto). Serve para:

1. **Radar de tecnologia** — acompanhar novidades, atualizações e riscos relevantes aos projetos do usuário: cardápio digital no WhatsApp (Flows, banco `vitrinewhats`), ScanTE (geolocalização, `scante_admin`), AprovIA (concursos, `estuda_concursos`), turismo e apps mobile (Android nativo, Flutter, React Native/Expo, web/PWA).
2. **Setup replicável** — registrar cada ferramenta instalada no Claude Code para reinstalar em outra máquina Windows.

## Estrutura

| Caminho | Conteúdo |
|---|---|
| `radar/radar.md` | Tabela única do radar. Anéis: **Adotar · Testar · Avaliar · Evitar** |
| `radar/fontes.md` | Fontes monitoradas em cada atualização |
| `radar/pesquisas/AAAA-MM-DD-*.md` | Relatórios datados (nunca editar os antigos; criar novos) |
| `docs/setup-ambiente.md` | Passo a passo de instalação, seção por ferramenta |
| `docs/guia-de-uso.md` | Como usar cada ferramenta no dia a dia |
| `setup.ps1` | Script consolidado de instalação |
| `.claude/skills/radar/` | Skill `/radar` — atualização do radar |

## Regras

- Escrever em português do Brasil.
- **Nunca instalar nada durante uma atualização do radar** — só pesquisar, registrar e recomendar. Instalações são feitas uma por uma, com explicação e confirmação do usuário.
- Toda entrada do radar precisa de: data de revisão, por que está no anel, e o que faria mudar de anel.
- Para cada ferramenta nova, registrar sinais de confiabilidade (mantenedor, estrelas, última release, oficial x comunidade), se roda local ou manda dados para fora (e para onde) e riscos (tool poisoning, telemetria, typosquat, CVEs).
- Incidentes de segurança em ferramentas já instaladas vêm **primeiro** em qualquer relatório.
- Toda instalação nova → nova seção em `docs/setup-ambiente.md` + linha no `setup.ps1`.
- Ambiente de trabalho: rede corporativa com Netskope (inspeção HTTPS), Windows 11, sem Docker (licença). Casa: sem essas restrições.
