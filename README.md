# potenciaVScode

Radar de tecnologia + setup replicável do ambiente Claude Code (VS Code).

- **Radar:** [radar/radar.md](radar/radar.md) — tabela Adotar / Testar / Avaliar / Evitar. Relatórios em [radar/pesquisas/](radar/pesquisas/). Atualizar com `/radar` no Claude Code (ou pela rotina semanal, que abre um Pull Request).
- **Instalar em outra máquina:** `git clone` este repositório, abrir o VS Code com a extensão Claude Code uma vez, e rodar:

  ```powershell
  Set-ExecutionPolicy -Scope Process Bypass
  .\setup.ps1                      # tudo
  .\setup.ps1 -Pular java,kotlin   # pulando etapas
  ```

  Depois seguir as pendências de login da seção 18 de [docs/setup-ambiente.md](docs/setup-ambiente.md).
- **Detalhes de cada ferramenta** (o que faz, por que, riscos): [docs/setup-ambiente.md](docs/setup-ambiente.md).
- **Como usar no dia a dia:** [docs/guia-de-uso.md](docs/guia-de-uso.md).
