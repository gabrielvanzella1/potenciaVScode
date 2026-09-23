<#
.SYNOPSIS
  Reinstala o ambiente Claude Code (VS Code) montado em 2026-09-23. Detalhes e motivos: docs/setup-ambiente.md

.DESCRIPTION
  Idempotente: pode rodar mais de uma vez. Não pede nem grava tokens — logins/tokens ficam para o final
  (ver seção 18 do docs/setup-ambiente.md).

.PARAMETER Pular
  Etapas a pular. Valores: lsp, java, kotlin, plugins, serena, graphify, mcps, dbhub, mobile, python3, hostinger
  Ex.: .\setup.ps1 -Pular java,kotlin,mobile
#>
param([string[]]$Pular = @())

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
function Etapa($nome) { Write-Host "`n=== $nome ===" -ForegroundColor Cyan }
function Pula($id) { return $Pular -contains $id }
function Tem($cmd) { return [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

# Baixa um arquivo e confere o SHA-256 publicado em "$Url.sha256".
function Baixar-Verificado($Url, $Destino) {
  Invoke-WebRequest $Url -OutFile $Destino -UseBasicParsing
  $sha = Invoke-WebRequest "$Url.sha256" -UseBasicParsing
  $txt = if ($sha.Content -is [byte[]]) { [Text.Encoding]::ASCII.GetString($sha.Content) } else { $sha.Content }
  $esperado = ($txt.Trim() -split '\s+')[0].ToUpper()
  $obtido = (Get-FileHash $Destino -Algorithm SHA256).Hash
  if ($esperado -ne $obtido) { throw "Checksum não confere para $Url" }
}

# ---------------------------------------------------------------- pré-requisitos
Etapa 'Pré-requisitos'
$faltando = @('node','npm','npx','python','uv','git','gh') | Where-Object { -not (Tem $_) }
if ($faltando) {
  Write-Host "Faltando: $($faltando -join ', ')" -ForegroundColor Yellow
  Write-Host 'Sugestão: winget install OpenJS.NodeJS Python.Python.3.12 astral-sh.uv Git.Git GitHub.cli'
  throw 'Instale os pré-requisitos e rode de novo.'
}

$claude = (Get-ChildItem "$env:USERPROFILE\.vscode\extensions\anthropic.claude-code-*\resources\native-binary\claude.exe" -ErrorAction SilentlyContinue |
           Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
if (-not $claude) { throw 'Extensão Claude Code do VS Code não encontrada. Instale-a e abra uma vez.' }
Write-Host "claude: $claude"

$bin = "$env:USERPROFILE\.local\bin"
$share = "$env:USERPROFILE\.local\share"
New-Item -ItemType Directory -Force $bin, $share | Out-Null

# Helpers para não duplicar config
$mcpsAtuais = (& $claude mcp list 2>$null) -join "`n"
function Mcp-Existe($nome) { return $mcpsAtuais -match "(?m)^$([regex]::Escape($nome)):" }
function Plugin($id) { & $claude plugin install $id --scope user 2>&1 | Select-Object -Last 1 }

# ---------------------------------------------------------------- python3 (seção 16)
if (-not (Pula 'python3')) {
  Etapa 'python3 real (evita o atalho da Microsoft Store)'
  $pyDir = Split-Path (Get-Command python).Source
  if ($pyDir -notmatch 'WindowsApps' -and -not (Test-Path "$pyDir\python3.exe")) {
    Copy-Item "$pyDir\python.exe" "$pyDir\python3.exe"
  }
  python3 --version
}

# ---------------------------------------------------------------- memory (seção 1)
Etapa 'Memory MCP'
if (-not (Mcp-Existe 'memory')) {
  $mem = ($env:USERPROFILE -replace '\\','/') + '/.claude/memory/memory.jsonl'
  & $claude mcp add memory --scope user -e "MEMORY_FILE_PATH=$mem" -- npx -y @modelcontextprotocol/server-memory
}

# ---------------------------------------------------------------- marketplaces (seções 2, 4, 5)
Etapa 'Marketplaces de plugins'
foreach ($m in 'anthropics/claude-plugins-official','DietrichGebert/ponytail','anthropics/skills') {
  & $claude plugin marketplace add $m 2>&1 | Select-Object -Last 1
}

# ---------------------------------------------------------------- LSPs (seção 3)
if (-not (Pula 'lsp')) {
  Etapa 'Language servers: TS/JS, Python, PHP (npm) e C# (dotnet)'
  npm install -g typescript-language-server typescript pyright intelephense
  if (Tem 'dotnet') {
    $sdkMajor = (dotnet --list-sdks | ForEach-Object { [int]($_ -split '\.')[0] } | Measure-Object -Maximum).Maximum
    if (-not (Tem 'csharp-ls')) {
      # 0.21+ exige .NET 10; 0.17–0.20 exige .NET 9; 0.16.0 é a última para .NET 8
      if ($sdkMajor -ge 10) { dotnet tool install --global csharp-ls }
      elseif ($sdkMajor -eq 9) { dotnet tool install --global csharp-ls --version 0.20.0 }
      else { dotnet tool install --global csharp-ls --version 0.16.0 }
    }
  } else { Write-Host '.NET SDK ausente: pulando csharp-ls' -ForegroundColor Yellow }
}

if (-not (Pula 'kotlin')) {
  Etapa 'Kotlin LSP (traz Java 25 embutido, usado também pelo jdtls)'
  $v = '263.4702.0'   # atualizar em https://github.com/Kotlin/kotlin-lsp/releases
  if (-not (Test-Path "$share\kotlin-lsp\bin\intellij-server.exe")) {
    $zip = "$env:TEMP\kotlin-server.zip"
    Baixar-Verificado "https://download.jetbrains.com/language-server/kotlin-server/$v/kotlin-server-$v.win.zip" $zip
    Expand-Archive $zip -DestinationPath "$share\kotlin-lsp" -Force
    Remove-Item $zip
  }
  Set-Content "$bin\kotlin-lsp.cmd" -Encoding ascii -Value @'
@echo off
rem Wrapper do Kotlin LSP (JetBrains) para o plugin kotlin-lsp do Claude Code.
"%USERPROFILE%\.local\share\kotlin-lsp\bin\intellij-server.exe" %*
'@
}

if (-not (Pula 'java')) {
  Etapa 'Eclipse JDT.LS (Java)'
  $ver = '1.61.0'; $arquivo = 'jdt-language-server-1.61.0-202609031315.tar.gz'   # atualizar em https://download.eclipse.org/jdtls/milestones/
  if (-not (Test-Path "$share\jdtls\bin\jdtls")) {
    $tgz = "$env:TEMP\$arquivo"
    Baixar-Verificado "https://download.eclipse.org/jdtls/milestones/$ver/$arquivo" $tgz
    New-Item -ItemType Directory -Force "$share\jdtls" | Out-Null
    & "$env:SystemRoot\System32\tar.exe" -xzf $tgz -C "$share\jdtls"
    Remove-Item $tgz
  }
  Set-Content "$bin\jdtls.cmd" -Encoding ascii -Value @'
@echo off
rem Wrapper do Eclipse JDT.LS para o plugin jdtls-lsp do Claude Code.
rem JDT.LS exige Java 21+; usa o JetBrains Runtime (Java 25) que vem com o kotlin-lsp,
rem sem mexer no JAVA_HOME do sistema. Para usar outro Java: set JDTLS_JAVA=C:\caminho\java.exe
set "JDTLS_HOME=%USERPROFILE%\.local\share\jdtls"
if not defined JDTLS_JAVA set "JDTLS_JAVA=%USERPROFILE%\.local\share\kotlin-lsp\jbr\bin\java.exe"
python "%JDTLS_HOME%\bin\jdtls" --java-executable "%JDTLS_JAVA%" %*
'@
}

# ---------------------------------------------------------------- plugins (seções 3, 4, 5, 7, 9, 10, 13, 14, 15, 17)
if (-not (Pula 'plugins')) {
  Etapa 'Plugins'
  $plugins = @(
    'typescript-lsp','pyright-lsp','csharp-lsp','php-lsp','jdtls-lsp','kotlin-lsp',
    'security-guidance','feature-dev','claude-code-setup',
    'context7','playwright','superpowers',
    'atlassian','hostinger','mercadopago','mapbox','expo'
  ) | ForEach-Object { "$_@claude-plugins-official" }
  $plugins += 'ponytail@ponytail', 'example-skills@anthropic-agent-skills'
  foreach ($p in $plugins) { Plugin $p }
}

# ---------------------------------------------------------------- Graphify (seção 6)
if (-not (Pula 'graphify')) {
  Etapa 'Graphify'
  if (-not (Tem 'graphify')) { uv tool install graphifyy }
  graphify install --platform claude
}

# ---------------------------------------------------------------- Serena (seção 8)
if (-not (Pula 'serena')) {
  Etapa 'Serena'
  if (-not (Tem 'serena')) { uv tool install -p 3.13 serena-agent }
  $cfg = "$env:USERPROFILE\.serena\serena_config.yml"
  if (-not (Test-Path $cfg)) { serena init }
  $t = [IO.File]::ReadAllText($cfg)
  $t = $t -replace '(?m)^web_dashboard_open_on_launch: true', 'web_dashboard_open_on_launch: false'
  [IO.File]::WriteAllText($cfg, $t, (New-Object Text.UTF8Encoding $false))
  if (-not (Mcp-Existe 'serena')) {
    & $claude mcp add --scope user serena -- serena start-mcp-server --context claude-code --project-from-cwd
  }
}

# ---------------------------------------------------------------- MCPs avulsos (seções 10, 11, 17)
if (-not (Pula 'mcps')) {
  Etapa 'MCPs: Chrome DevTools, GitHub, Google Maps, Meta'
  if (-not (Mcp-Existe 'chrome-devtools')) {
    & $claude mcp add --scope user chrome-devtools -e CHROME_DEVTOOLS_MCP_NO_USAGE_STATISTICS=1 -- npx -y chrome-devtools-mcp@1 --no-usage-statistics --no-performance-crux
  }
  if (-not (Mcp-Existe 'github')) {
    & $claude mcp add --scope user --transport http github 'https://api.githubcopilot.com/mcp/' `
      -H 'Authorization: Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}' `
      -H 'X-MCP-Lockdown: true' `
      -H 'X-MCP-Toolsets: context,repos,issues,pull_requests,actions,code_security,dependabot'
  }
  if (-not (Mcp-Existe 'google-maps-code-assist')) {
    & $claude mcp add --scope user --transport http google-maps-code-assist https://mapscodeassist.googleapis.com/mcp
  }
  if (-not (Mcp-Existe 'meta_social_technologies')) {
    & $claude mcp add --scope user --transport http meta_social_technologies https://mcp.facebook.com/devtools
  }
}

# ---------------------------------------------------------------- DBHub (seção 12)
if (-not (Pula 'dbhub')) {
  Etapa 'DBHub (bancos MySQL do Laragon)'
  npm install -g "@bytebase/dbhub@1"
  $toml = "$env:USERPROFILE\.dbhub\dbhub.toml"
  if (-not (Test-Path $toml)) {
    $dataDir = Get-ChildItem 'C:\laragon\data' -Directory -Filter 'mysql*' -ErrorAction SilentlyContinue |
               Sort-Object Name -Descending | Select-Object -First 1
    if ($dataDir) {
      $ignorar = 'mysql','performance_schema','sys','information_schema'
      $bancos = Get-ChildItem $dataDir.FullName -Directory | Where-Object { $_.Name -notin $ignorar -and $_.Name -notmatch '^#' } |
                Select-Object -ExpandProperty Name
      $linhas = @('# DBHub — bancos locais do Laragon. Gerado pelo setup.ps1. Só bancos de DESENVOLVIMENTO.', '')
      foreach ($b in $bancos) { $linhas += '[[sources]]', "id = `"$b`"", "dsn = `"mysql://root@localhost:3306/$b`"", 'lazy = true', '' }
      foreach ($b in $bancos) { $linhas += '[[tools]]', 'name = "execute_sql"', "source = `"$b`"", 'readonly = false', 'max_rows = 1000', '' }
      New-Item -ItemType Directory -Force (Split-Path $toml) | Out-Null
      [IO.File]::WriteAllLines($toml, $linhas, (New-Object Text.UTF8Encoding $false))
      Write-Host "dbhub.toml gerado com: $($bancos -join ', ')"
    } else { Write-Host 'Laragon/MySQL não encontrado: crie ~/.dbhub/dbhub.toml manualmente (seção 12)' -ForegroundColor Yellow }
  }
  if ((Test-Path $toml) -and -not (Mcp-Existe 'dbhub')) {
    & $claude mcp add --scope user dbhub -- dbhub --transport stdio --config ($toml -replace '\\','/')
  }
}

# ---------------------------------------------------------------- mobile-mcp (seção 17)
if (-not (Pula 'mobile')) {
  Etapa 'mobile-mcp (Android via adb)'
  if (-not (Tem 'adb')) { Write-Host 'adb ausente: winget install Google.PlatformTools' -ForegroundColor Yellow }
  npm install -g "@mobilenext/mobile-mcp@1"
  if (-not (Mcp-Existe 'mobile-mcp')) {
    & $claude mcp add --scope user mobile-mcp -e MOBILEMCP_DISABLE_TELEMETRY=1 -- mcp-server-mobile
  }
}

# ---------------------------------------------------------------- travas Hostinger (seção 14)
if (-not (Pula 'hostinger')) {
  Etapa 'Travas da Hostinger (permissions.deny)'
  $settings = "$env:USERPROFILE\.claude\settings.json"
  $deny = Get-Content (Join-Path $PSScriptRoot 'config\hostinger-deny.json') -Raw | ConvertFrom-Json
  $s = if (Test-Path $settings) { Get-Content $settings -Raw -Encoding utf8 | ConvertFrom-Json } else { New-Object PSObject }
  if (-not $s.permissions) { $s | Add-Member -NotePropertyName permissions -NotePropertyValue (New-Object PSObject) }
  $atuais = @($s.permissions.deny)
  $novos = @($atuais + $deny | Where-Object { $_ } | Select-Object -Unique)
  $s.permissions | Add-Member -NotePropertyName deny -NotePropertyValue $novos -Force
  [IO.File]::WriteAllText($settings, ($s | ConvertTo-Json -Depth 20), (New-Object Text.UTF8Encoding $false))
  Write-Host "$($deny.Count) regras deny garantidas em settings.json"
}

# ---------------------------------------------------------------- verificação e pendências
Etapa 'Verificação'
& $claude mcp list

Write-Host @'

=== Falta você fazer (docs/setup-ambiente.md, seção 18) ===
 1. GitHub: criar token fine-grained e guardar em GITHUB_PERSONAL_ACCESS_TOKEN (seção 11); reabrir o VS Code.
 2. No chat do Claude Code, /mcp → Authenticate em: atlassian, hostinger, mercadopago, mapbox (2), expo, meta_social_technologies.
 3. Copiar a memória, se quiser: %USERPROFILE%\.claude\memory\memory.jsonl
 4. Abrir uma sessão NOVA do Claude Code para carregar tudo.
'@ -ForegroundColor Green
