# Setup do ambiente Claude Code (VS Code)

Registro passo a passo de tudo que foi instalado, para replicar em outra máquina Windows.
Cada seção diz **o que é**, **por que** e **os comandos exatos**. Ao final haverá um `setup.ps1` consolidado.

> Máquina de origem: Windows 11, Claude Code 2.1.280 (extensão VS Code), Node 25, Python 3.12 + uv, .NET 8, JDK 17 (Corretto), PHP 8.3 (Laragon).

---

## 0. Pré-requisitos

| Ferramenta | Para quê | Instalação |
|---|---|---|
| Node.js LTS+ | LSPs npm e maioria dos MCPs (`npx`) | https://nodejs.org ou `winget install OpenJS.NodeJS` |
| Python 3.10+ | wrapper do jdtls | `winget install Python.Python.3.12` |
| uv | MCPs em Python (ex.: Serena) | `winget install astral-sh.uv` |
| .NET SDK | LSP de C# | `winget install Microsoft.DotNet.SDK.8` (ou 10) |
| Git + GitHub CLI | Git/GitHub | `winget install Git.Git GitHub.cli` |

`%USERPROFILE%\.local\bin` precisa estar no PATH (o instalador do `uv` já adiciona).

### Localizar o executável `claude` da extensão

A extensão do VS Code traz o próprio `claude.exe` (não fica no PATH). Em PowerShell:

```powershell
$claude = (Get-ChildItem "$env:USERPROFILE\.vscode\extensions\anthropic.claude-code-*\resources\native-binary\claude.exe" |
           Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
& $claude --version
```

Todos os comandos abaixo usam `& $claude ...`. Alternativamente, rode os `/plugin ...` e `/mcp` dentro do chat do Claude Code.

---

## 1. Memory MCP (grafo de conhecimento persistente)

**O que é:** servidor MCP oficial que guarda entidades/relações/observações em um arquivo JSONL local. 100% local.

```powershell
& $claude mcp add memory --scope user -e MEMORY_FILE_PATH="$($env:USERPROFILE -replace '\\','/')/.claude/memory/memory.jsonl" -- npx -y @modelcontextprotocol/server-memory
```

Para levar a memória para a outra máquina, copie `%USERPROFILE%\.claude\memory\memory.jsonl`.

---

## 2. Marketplace oficial de plugins da Anthropic

**O que é:** catálogo curado (`anthropics/claude-plugins-official`) de onde saem os plugins abaixo. Adicionar não instala nada.

```powershell
& $claude plugin marketplace add anthropics/claude-plugins-official
```

---

## 3. Plugins LSP (inteligência de código)

**O que fazem:** ligam a ferramenta LSP nativa do Claude Code — ir para definição, achar referências e ver erros de tipo logo após cada edição. 100% local. Cada plugin exige o binário do language server no PATH.

### 3.1 TypeScript/JavaScript (Next.js, React), Python, PHP — via npm

```powershell
npm install -g typescript-language-server typescript pyright intelephense
```

### 3.2 C# — via dotnet tool

`csharp-ls` 0.21+ exige .NET 10; 0.17–0.20 exige .NET 9; **0.16.0 é a última para .NET 8**.

```powershell
# Com .NET 8:
dotnet tool install --global csharp-ls --version 0.16.0
# Com .NET 10 instalado, pode usar a mais recente:
# dotnet tool install --global csharp-ls
```

### 3.3 Kotlin (Android) — zip oficial da JetBrains

Traz um Java 25 embutido (JetBrains Runtime), reaproveitado pelo jdtls abaixo. Versões em https://github.com/Kotlin/kotlin-lsp/releases.

```powershell
$v   = '263.4702.0'
$url = "https://download.jetbrains.com/language-server/kotlin-server/$v/kotlin-server-$v.win.zip"
$zip = "$env:TEMP\kotlin-server.zip"
Invoke-WebRequest $url -OutFile $zip -UseBasicParsing
# conferir SHA-256 com o arquivo $url.sha256
(Get-FileHash $zip -Algorithm SHA256).Hash
Expand-Archive $zip -DestinationPath "$env:USERPROFILE\.local\share\kotlin-lsp" -Force
```

Criar `%USERPROFILE%\.local\bin\kotlin-lsp.cmd`:

```bat
@echo off
rem Wrapper do Kotlin LSP (JetBrains) para o plugin kotlin-lsp do Claude Code.
"%USERPROFILE%\.local\share\kotlin-lsp\bin\intellij-server.exe" %*
```

### 3.4 Java (Android) — Eclipse JDT.LS

Exige **Java 21+ para rodar** (seus projetos podem continuar em 17 — o `JAVA_HOME` não é alterado). O `jdtls.bat` do pacote termina com `pause`, que trava o LSP, por isso usamos wrapper próprio. Versões em https://download.eclipse.org/jdtls/milestones/.

```powershell
$f   = 'jdt-language-server-1.61.0-202609031315.tar.gz'
$url = "https://download.eclipse.org/jdtls/milestones/1.61.0/$f"
Invoke-WebRequest $url -OutFile "$env:TEMP\$f" -UseBasicParsing
(Get-FileHash "$env:TEMP\$f" -Algorithm SHA256).Hash   # comparar com $url.sha256
New-Item -ItemType Directory -Force "$env:USERPROFILE\.local\share\jdtls" | Out-Null
tar -xzf "$env:TEMP\$f" -C "$env:USERPROFILE\.local\share\jdtls"
```

Criar `%USERPROFILE%\.local\bin\jdtls.cmd`:

```bat
@echo off
rem Wrapper do Eclipse JDT.LS para o plugin jdtls-lsp do Claude Code.
rem JDT.LS exige Java 21+; usa o JetBrains Runtime (Java 25) que vem com o kotlin-lsp,
rem sem mexer no JAVA_HOME do sistema. Para usar outro Java: set JDTLS_JAVA=C:\caminho\java.exe
set "JDTLS_HOME=%USERPROFILE%\.local\share\jdtls"
if not defined JDTLS_JAVA set "JDTLS_JAVA=%USERPROFILE%\.local\share\kotlin-lsp\jbr\bin\java.exe"
python "%JDTLS_HOME%\bin\jdtls" --java-executable "%JDTLS_JAVA%" %*
```

### 3.5 Instalar os plugins

```powershell
foreach ($p in 'typescript-lsp','pyright-lsp','csharp-lsp','php-lsp','jdtls-lsp','kotlin-lsp') {
  & $claude plugin install "$p@claude-plugins-official" --scope user
}
& $claude plugin list
```

**Teste feito:** os 6 servidores responderam ao `initialize` do LSP (TS 0,4s · Python 1,3s · PHP 0,9s · jdtls 11s · Kotlin 23s · C# 26s).

---

## 4. Ponytail — "dev sênior preguiçoso"

**O que é:** plugin (MIT, DietrichGebert) que injeta, via hooks Node a cada turno, uma escada de decisão antes de escrever código: nativo/stdlib primeiro, sem libs e abstrações não pedidas. Teste independente da JetBrains: −10,3% de custo, −15% de código, sem perda de qualidade detectada. Hooks 100% locais (código conferido, sem chamadas de rede). Requer `node` no PATH.

⚠️ O repositório oficial é **`DietrichGebert/ponytail`** — guias na internet citam `dietrichayala/ponytail`, que não existe (risco de typosquat).

```powershell
& $claude plugin marketplace add DietrichGebert/ponytail
& $claude plugin install ponytail@ponytail --scope user
```

Modo padrão: `full`. Trocar no chat: `/ponytail lite|full|ultra|off`. Desligar num projeto: variável `PONYTAIL_DEFAULT_MODE=off`.

---

## 5. Agent Skills da Anthropic (`anthropics/skills`)

**O que é:** skills no padrão aberto `SKILL.md` (agentskills.io). O pacote `example-skills` traz frontend-design, webapp-testing, mcp-builder, web-artifacts-builder, theme-factory, canvas-design, skill-creator, doc-coauthoring, etc. Só a descrição fica no contexto até a skill ser usada.

```powershell
& $claude plugin marketplace add anthropics/skills
& $claude plugin install example-skills@anthropic-agent-skills --scope user
```

(docx/xlsx/pptx/pdf já chegam pela sincronização da conta claude.ai; para tê-las localmente: `document-skills@anthropic-agent-skills`.)

---

## 6. Graphify — grafo de conhecimento do código

**O que é:** transforma o repositório (código + docs + SQL + PDFs) num grafo consultável; o Claude consulta o grafo em vez de ler arquivos inteiros (útil em repos grandes). Código parseado localmente com tree-sitter, sem telemetria. Apache-2.0, Graphify-Labs.

Instalação global da CLI + skill `/graphify` (sem hooks globais):

```powershell
uv tool install graphifyy          # sim, dois "y"
graphify install --platform claude # só copia a skill para ~/.claude/skills/graphify
```

**Ativar num projeto grande** (rodar dentro da pasta do projeto): adiciona seção no `CLAUDE.md` + hook PreToolUse só daquele projeto.

```powershell
graphify claude install     # desfazer: graphify claude uninstall
# depois, no chat do Claude Code:  /graphify .
```

---

## 7. Plugins de fluxo de trabalho (oficiais Anthropic)

| Plugin | O que faz |
|---|---|
| `security-guidance` | Avisos regex em cada edição (secrets, `innerHTML`, `pickle`…) + revisão LLM do diff ao fim de cada turno + revisor agentic em cada `git commit`. Usa a sua conta Claude (custa uso). Requer Python 3.10+ do python.org (o plugin ignora o atalho falso da Microsoft Store). |
| `feature-dev` | `/feature-dev`: fluxo de 7 fases com agentes explorer, architect e reviewer. |
| `claude-code-setup` | Analisa um projeto e recomenda hooks, skills e MCPs sob medida. |

```powershell
foreach ($p in 'security-guidance','feature-dev','claude-code-setup') {
  & $claude plugin install "$p@claude-plugins-official" --scope user
}
```

Desligar camadas do security-guidance (variáveis de ambiente): `SECURITY_GUIDANCE_DISABLE=1` (tudo), `ENABLE_STOP_REVIEW=0` (revisão por turno), `ENABLE_COMMIT_REVIEW=0` (revisão no commit).

Não instalados de propósito: `code-simplifier` (duplica o `/simplify` embutido), `frontend-design` (já vem no `example-skills`).

---

## 8. Serena — edição semântica de código (MCP)

**O que é:** ferramentas de IDE para o agente — editar/substituir por símbolo (função, classe, método), renomear em todo o projeto, achar referências. 100% local (usa language servers locais). oraios, v1.7.0.

```powershell
uv tool install -p 3.13 serena-agent     # uv baixa o Python 3.13 isolado; não mexe no Python do sistema
serena init                              # cria %USERPROFILE%\.serena\serena_config.yml (backend LSP)
```

Desligar a aba do navegador que abre a cada sessão (o painel continua em http://localhost:24282/dashboard/):

```powershell
$cfg = "$env:USERPROFILE\.serena\serena_config.yml"
(Get-Content $cfg -Raw) -replace '(?m)^web_dashboard_open_on_launch: true','web_dashboard_open_on_launch: false' |
  Set-Content $cfg -Encoding utf8
```

Registrar no Claude Code (escopo usuário, projeto = pasta atual):

```powershell
& $claude mcp add --scope user serena -- serena start-mcp-server --context claude-code --project-from-cwd
```

### Hooks recomendados pela documentação do Serena (opcional)

Adicionar em `%USERPROFILE%\.claude\settings.json` (chave `"hooks"`). `remind` roda antes de **toda** ferramenta (~280 ms cada, medido); `auto-approve` só age quando você já está em modo permissivo (`acceptEdits`/`auto`).

```json
"hooks": {
  "PreToolUse": [
    { "matcher": "", "hooks": [ { "type": "command", "command": "serena-hooks remind --client=claude-code" } ] },
    { "matcher": "mcp__serena__*", "hooks": [ { "type": "command", "command": "serena-hooks auto-approve --client=claude-code" } ] }
  ],
  "SessionStart": [
    { "matcher": "", "hooks": [ { "type": "command", "command": "serena-hooks activate --client=claude-code" } ] }
  ],
  "SessionEnd": [
    { "matcher": "", "hooks": [ { "type": "command", "command": "serena-hooks cleanup --client=claude-code" } ] }
  ]
}
```

> Decisão em 2026-09-23: **sem hooks** por enquanto (custo de ~280 ms por ferramenta). Ativar só se o Claude estiver ignorando o Serena.

---

## 9. Context7 — documentação atualizada de bibliotecas

**O que é:** busca documentação e exemplos da versão exata de uma biblioteca na hora (Next.js, Prisma, APIs da Meta…). Plugin oficial do marketplace → servidor remoto `mcp.context7.com` (Upstash). Só a consulta sai da máquina (não o código). Funciona sem conta.

```powershell
& $claude plugin install context7@claude-plugins-official --scope user
```

Uso: escrever **"use context7"** no pedido, ex.: *"crie um middleware de auth no Next.js 16, use context7"*.

Se bater limite de uso: criar chave grátis em https://context7.com/dashboard e definir a variável de ambiente do usuário (não versionar):

```powershell
[Environment]::SetEnvironmentVariable('CONTEXT7_API_KEY', 'SUA_CHAVE', 'User')   # reabrir o VS Code depois
```

---

## 10. Navegador: Playwright MCP + Chrome DevTools MCP

Pré-requisito: Google Chrome instalado (usado pelos dois).

**Playwright MCP (Microsoft)** — o Claude abre seu app, clica, preenche formulários e tira screenshots para testar as próprias mudanças. Local.

```powershell
& $claude plugin install playwright@claude-plugins-official --scope user
```

**Chrome DevTools MCP (Google)** — console, rede, traces de performance, Core Web Vitals, Lighthouse. Instalado direto (não pelo plugin) para **desligar a telemetria** (estatísticas de uso e envio de URLs à API CrUX, ambos ligados por padrão):

```powershell
& $claude mcp add --scope user chrome-devtools -e CHROME_DEVTOOLS_MCP_NO_USAGE_STATISTICS=1 -- npx -y chrome-devtools-mcp@1 --no-usage-statistics --no-performance-crux
```

Verificar tudo: `& $claude mcp list` (todos devem aparecer como Connected).

---

## 11. GitHub MCP "blindado"

**O que é:** servidor MCP oficial do GitHub (remoto) — Actions (logs de falha), Dependabot, code scanning, issues, PRs, busca de código. Configurado com três proteções contra o ataque conhecido de "issue maliciosa vaza repo privado":

1. **Token fine-grained** só com os repositórios escolhidos (não o token amplo do `gh`).
2. **Lockdown** (`X-MCP-Lockdown: true`) — esconde conteúdo de issues de quem não tem push.
3. **Toolsets limitados** — `context,repos,issues,pull_requests,actions,code_security,dependabot`.

### Passo 1 — criar o token (no navegador)

github.com → foto → **Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token**

- **Name:** `claude-code-mcp` · **Expiration:** 90 dias
- **Repository access:** *Only select repositories* → escolher os repos
- **Repository permissions:**

| Permissão | Nível |
|---|---|
| Contents | Read and write |
| Issues | Read and write |
| Pull requests | Read and write |
| Actions | Read-only |
| Commit statuses | Read-only |
| Code scanning alerts | Read-only |
| Dependabot alerts | Read-only |
| Metadata | Read-only (obrigatória, vem marcada) |

### Passo 2 — guardar o token como variável de ambiente (PowerShell, na SUA janela)

O token não aparece na tela nem fica em arquivo:

```powershell
$t = Read-Host -AsSecureString "Cole o token do GitHub"
[Environment]::SetEnvironmentVariable('GITHUB_PERSONAL_ACCESS_TOKEN',
  [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($t)), 'User')
```

Depois **feche e reabra o VS Code** (variáveis de ambiente são lidas na inicialização).

### Passo 3 — registrar o servidor

```powershell
& $claude mcp add --scope user --transport http github 'https://api.githubcopilot.com/mcp/' `
  -H 'Authorization: Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}' `
  -H 'X-MCP-Lockdown: true' `
  -H 'X-MCP-Toolsets: context,repos,issues,pull_requests,actions,code_security,dependabot'
```

(Aspas simples de propósito: o `${...}` fica literal no config e o Claude Code substitui na hora de conectar.)

Renovar a cada 90 dias: gerar novo token e repetir o Passo 2.

---

## 12. DBHub — o Claude consulta seus bancos MySQL (Laragon)

**O que é:** MCP da Bytebase (MIT) que dá ao Claude uma ferramenta `execute_sql_<banco>` por banco: ver estrutura, rodar SELECT, testar migrations, investigar bugs nos dados reais. 100% local. Requer Node ≥ 22.5.

Config em `%USERPROFILE%\.dbhub\dbhub.toml` — um `[[sources]]` + um `[[tools]]` por banco. Pontos importantes:

- `lazy = true` em cada source (opção não documentada, achada no código): só conecta no primeiro uso. **Sem isso o servidor falha ao iniciar se o MySQL do Laragon estiver desligado.**
- `readonly = false` + `max_rows = 1000` (bancos de dev). Para produção: usuário MySQL só-leitura + `readonly = true`.

Exemplo de um banco (repetir para cada):

```toml
[[sources]]
id = "scante_admin"
dsn = "mysql://root@localhost:3306/scante_admin"
lazy = true

[[tools]]
name = "execute_sql"
source = "scante_admin"
readonly = false
max_rows = 1000
```

Bancos configurados nesta máquina: app, estuda_concursos, laboratorio, myactive, projetovendatudo, scante_admin, sistema_ativos, sistema_ativos_v1, vitrinewhats, vztech_helpdesk. Listar os da outra máquina: `Get-ChildItem C:\laragon\data\mysql-8.4 -Directory`.

Instalado globalmente (com `npx` o servidor estourava o timeout de 30 s quando todos os MCPs sobem juntos no início da sessão):

```powershell
npm install -g "@bytebase/dbhub@1"
& $claude mcp add --scope user dbhub -- dbhub --transport stdio --config "C:/Users/$env:USERNAME/.dbhub/dbhub.toml"
```

Lembrete: iniciar o MySQL no Laragon antes de pedir consultas ao Claude.

---

## 13. Jira + Confluence (Atlassian)

**O que é:** plugin oficial da Atlassian → servidor remoto `mcp.atlassian.com` (OAuth 2.1). O Claude cria/atualiza issues no Jira, consulta sprints e lê/escreve páginas no Confluence.

Pré-requisito: conta Atlassian gratuita com Jira + Confluence (https://www.atlassian.com/try — plano Free).

```powershell
& $claude plugin install atlassian@claude-plugins-official --scope user
```

Login: numa sessão do Claude Code, digitar `/mcp` → `plugin:atlassian:atlassian` → **Authenticate** (abre o navegador).

---

## 14. Hostinger (com travas de segurança)

**O que é:** plugin oficial da Hostinger → servidor remoto `mcp.hostinger.com` (OAuth), 351 ferramentas (sites, domínios, DNS, e-mail, VPS, e-commerce, cobrança) + 7 skills de deploy (estático, Node.js/Next.js, PHP, WordPress).

```powershell
& $claude plugin install hostinger@claude-plugins-official --scope user
```

Login: `/mcp` → `plugin:hostinger:hostinger` → **Authenticate**.

**Travas:** 34 ferramentas que gastam dinheiro ou destroem algo de forma irreversível ficam **bloqueadas** via `permissions.deny` em `%USERPROFILE%\.claude\settings.json` (compra de domínio/VPS, renovação, formas de pagamento, excluir site/banco/mailbox/loja, recriar VPS, restaurar snapshot/backup, reset/exclusão de DNS, trocar nameservers, destravar domínio…). Lista de nomes obtida de https://github.com/hostinger/api-mcp-server. Prefixo das regras: `mcp__plugin_hostinger_hostinger__`.

```json
"permissions": {
  "deny": [
    "mcp__plugin_hostinger_hostinger__billing_createPurchaseOrderV1",
    "mcp__plugin_hostinger_hostinger__billing_setDefaultPaymentMethodV1",
    "mcp__plugin_hostinger_hostinger__billing_deletePaymentMethodV1",
    "mcp__plugin_hostinger_hostinger__billing_disableAutoRenewalV1",
    "mcp__plugin_hostinger_hostinger__billing_renewSubscriptionV1",
    "mcp__plugin_hostinger_hostinger__DNS_restoreDNSSnapshotV1",
    "mcp__plugin_hostinger_hostinger__DNS_deleteDNSRecordsV1",
    "mcp__plugin_hostinger_hostinger__DNS_resetDNSRecordsV1",
    "mcp__plugin_hostinger_hostinger__domains_cancelOutgoingDomainMoveV1",
    "mcp__plugin_hostinger_hostinger__domains_disableDomainLockV1",
    "mcp__plugin_hostinger_hostinger__domains_purchaseNewDomainV1",
    "mcp__plugin_hostinger_hostinger__domains_disablePrivacyProtectionV1",
    "mcp__plugin_hostinger_hostinger__domains_updateDomainNameserversV1",
    "mcp__plugin_hostinger_hostinger__domains_claimFreeDomainTransferV1",
    "mcp__plugin_hostinger_hostinger__domains_deleteWHOISProfileV1",
    "mcp__plugin_hostinger_hostinger__ecommerce_cancelAnOrderV1",
    "mcp__plugin_hostinger_hostinger__ecommerce_enableManualPaymentMethodV1",
    "mcp__plugin_hostinger_hostinger__ecommerce_createAPaymentProviderConnectLinkV1",
    "mcp__plugin_hostinger_hostinger__ecommerce_deleteAProductV1",
    "mcp__plugin_hostinger_hostinger__ecommerce_deleteStoreV1",
    "mcp__plugin_hostinger_hostinger__ecommerce_deleteAProductVariantV1",
    "mcp__plugin_hostinger_hostinger__hosting_deleteAccountDatabaseV1",
    "mcp__plugin_hostinger_hostinger__hosting_deleteWebsiteV1",
    "mcp__plugin_hostinger_hostinger__hosting_deleteWordPressInstallationV1",
    "mcp__plugin_hostinger_hostinger__mail_deleteMailboxV1",
    "mcp__plugin_hostinger_hostinger__VPS_deleteProjectV1",
    "mcp__plugin_hostinger_hostinger__VPS_deleteFirewallV1",
    "mcp__plugin_hostinger_hostinger__VPS_restoreBackupV1",
    "mcp__plugin_hostinger_hostinger__VPS_purchaseNewVirtualMachineV1",
    "mcp__plugin_hostinger_hostinger__VPS_setNameserversV1",
    "mcp__plugin_hostinger_hostinger__VPS_recreateVirtualMachineV1",
    "mcp__plugin_hostinger_hostinger__VPS_setupPurchasedVirtualMachineV1",
    "mcp__plugin_hostinger_hostinger__VPS_deleteSnapshotV1",
    "mcp__plugin_hostinger_hostinger__VPS_restoreSnapshotV1"
  ]
}
```

⚠️ **Pendente:** após o login OAuth, conferir no `/mcp` se os nomes das ferramentas do servidor remoto batem com esta lista.

---

## 15. Superpowers — método de engenharia

**O que é:** plugin (obra, MIT, no marketplace oficial) com 15 skills que impõem brainstorm → plano → TDD → subagentes → revisão → verificação antes de concluir. ~840 tokens fixos por sessão. Local.

```powershell
& $claude plugin install superpowers@claude-plugins-official --scope user
```

Se ficar pesado para tarefas pequenas: `& $claude plugin disable superpowers@claude-plugins-official` (e `enable` para voltar).

---

## 16. Correção: `python3` apontando para o atalho falso da Microsoft Store

No Windows, `python3` resolve para `...\WindowsApps\python3.exe` (atalho que abre a Store e falha em scripts). Hooks de plugins que chamam `python3` (ex.: Mercado Pago) quebram. Correção: uma cópia do `python.exe` real com o nome `python3.exe` na pasta do Python (que vem antes de WindowsApps no PATH):

```powershell
$dir = "$env:LOCALAPPDATA\Programs\Python\Python312"
Copy-Item "$dir\python.exe" "$dir\python3.exe"
python3 --version    # deve mostrar a versão real
```

Desfazer: apagar `python3.exe` dessa pasta.

---

## 17. Ferramentas dos domínios (pagamentos, mapas, WhatsApp, mobile)

Pesquisa completa: `radar/pesquisas/2026-09-23-seus-projetos.md`.

| Ferramenta | Tipo | Login | O que faz |
|---|---|---|---|
| `mercadopago` | Plugin oficial (MCP remoto + 4 skills + hooks) | OAuth no `/mcp` | Pix, checkout, assinaturas, webhooks, testes; hook bloqueia vazamento de credenciais `APP_USR-…` em arquivos (requer a correção do `python3`, seção 16) |
| `mapbox` | Plugin oficial (3 MCPs remotos + 20 skills) | OAuth/conta Mapbox | Geocoding, rotas, isócronas, estilos, docs; skills Android/Flutter/iOS/web |
| `expo` | Plugin oficial (MCP remoto + skills) | OAuth conta Expo | Docs Expo, libs compatíveis, EAS Build/Update, TestFlight. Telemetria opt-in (desligada por padrão) |
| Google Maps Code Assist | MCP remoto | nenhum | Docs/exemplos oficiais do Google Maps (grátis enquanto experimental) |
| Meta Social Technologies | MCP remoto (beta) | OAuth Meta | Docs Meta/WhatsApp, changelog, webhooks, App Review |
| mobile-mcp | MCP local (mobile-next, Apache-2.0) | — | Controla emulador/celular Android via adb (tocar, deslizar, abrir app, screenshot, instalar APK). Telemetria desligada via variável |

```powershell
foreach ($p in 'mercadopago','mapbox','expo') { & $claude plugin install "$p@claude-plugins-official" --scope user }
& $claude mcp add --scope user --transport http google-maps-code-assist https://mapscodeassist.googleapis.com/mcp
& $claude mcp add --scope user --transport http meta_social_technologies https://mcp.facebook.com/devtools

# mobile-mcp: requer adb no PATH (winget install Google.PlatformTools)
npm install -g "@mobilenext/mobile-mcp@1"
& $claude mcp add --scope user mobile-mcp -e MOBILEMCP_DISABLE_TELEMETRY=1 -- mcp-server-mobile
```

**WhatsApp Business Tools MCP** (oficial Meta, lançado 15/09/2026, rollout gradual): quando aparecer em developers.facebook.com → seu App → WhatsApp → API Setup, adicionar com `& $claude mcp add --scope user --transport http whatsapp-business <URL>`.

**Flutter (quando o SDK estiver instalado):** o servidor MCP oficial vem no SDK do Dart (3.9+):

```powershell
winget install Google.Flutter          # ou https://docs.flutter.dev/get-started/install/windows
& $claude mcp add --scope user dart -- dart mcp-server
```

---

## 18. Pendências que dependem de você (logins e contas)

| Item | O que fazer |
|---|---|
| GitHub | Criar token fine-grained e guardar em `GITHUB_PERSONAL_ACCESS_TOKEN` (seção 11), reabrir VS Code |
| Atlassian | Criar conta grátis Jira+Confluence → `/mcp` → atlassian → Authenticate |
| Mercado Pago, Mapbox (2 servidores), Expo, Meta | `/mcp` → cada um → Authenticate |
| Hostinger | **Na rede do trabalho falha** (`UNABLE_TO_VERIFY_LEAF_SIGNATURE`): a Netskope (inspeção HTTPS corporativa, agente `stAgentSvc`) parece interceptar o tráfego do `claude.exe` para `mcp.hostinger.com` — Node, OpenSSL e WebFetch conectam normalmente. Em casa deve funcionar. Conferir os nomes das ferramentas vs a lista `deny` (seção 14) após o login |
| Conectores claude.ai (Canva, Descript, Runway, Unstructured) | Autorizar em claude.ai → Configurações → Conectores, se quiser usar |

---

## Decisões de NÃO instalar (2026-09-23)

| Item | Motivo |
|---|---|
| Docker MCP Gateway | Usuário não quer Docker; além disso Docker Desktop exige licença paga em empresas >250 funcionários |
| Snyk Agent Scan | Pulado (curadoria manual feita; exigiria conta Snyk) |
| Exa / Firecrawl | Busca nativa do Claude Code basta por ora (no radar) |
| code-simplifier, frontend-design (plugin) | Duplicados |
| OmniRoute | CVEs e risco de ToS (ver radar) |
| Figma MCP | Usuário não usa Figma |

---
