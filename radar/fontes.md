# Fontes do radar

Consultadas a cada atualização (`/radar`). Adicionar fontes novas ao final de cada seção.

## Ferramentas instaladas — releases e incidentes

Verificar a última release de cada uma (`gh api repos/<repo>/releases/latest`) e buscar "<nome> vulnerability OR CVE OR malicious" desde a última revisão.

| Ferramenta | Repositório / pacote |
|---|---|
| Claude Code | https://github.com/anthropics/claude-code (CHANGELOG.md) |
| Marketplace oficial | https://github.com/anthropics/claude-plugins-official (commits recentes = plugins novos) |
| Agent Skills | https://github.com/anthropics/skills |
| Serena | oraios/serena |
| Graphify | Graphify-Labs/graphify (pacote `graphifyy`) |
| Ponytail | DietrichGebert/ponytail |
| Superpowers | obra/superpowers |
| Context7 | upstash/context7 |
| Playwright MCP | microsoft/playwright-mcp |
| Chrome DevTools MCP | ChromeDevTools/chrome-devtools-mcp |
| GitHub MCP | github/github-mcp-server |
| DBHub | bytebase/dbhub |
| mobile-mcp | mobile-next/mobile-mcp |
| Kotlin LSP | Kotlin/kotlin-lsp |
| Eclipse JDT.LS | https://download.eclipse.org/jdtls/milestones/ |
| csharp-ls | NuGet `csharp-ls` (0.16.0 é a última para .NET 8) |
| Mercado Pago plugin | mercadopago/mercadopago-claude-marketplace |
| Hostinger plugin / API MCP | hostinger/claude-plugin, hostinger/api-mcp-server |
| Mapbox | mapbox/mapbox-agent-skills |
| Expo | expo/skills |

## Segurança de MCP / agentes

- https://vulnerablemcp.info/
- https://owasp.org/www-community/attacks/MCP_Tool_Poisoning
- https://osv.dev (buscar pelos pacotes npm/PyPI instalados)
- Blogs: Invariant/Snyk, Noma Security, Trail of Bits

## Por domínio

| Domínio | Fontes |
|---|---|
| WhatsApp / Meta | https://developers.facebook.com/docs/whatsapp (changelog), https://developers.facebook.com/blog/ , preços e políticas da WhatsApp Business Platform |
| Geolocalização | https://www.mapbox.com/blog , https://mapsplatform.google.com/resources/blog/ , PostGIS e MySQL release notes |
| Turismo | APIs Viator, GetYourGuide, Duffel, Amadeus; notícias de travel tech |
| Educação (AprovIA) | open-spaced-repetition (FSRS), novidades da Claude API (citations, files, batch) |
| Mobile | https://expo.dev/changelog , https://docs.flutter.dev/release/whats-new , https://android-developers.googleblog.com/ |
| Pagamentos BR | https://www.mercadopago.com.br/developers/pt/news , Banco Central (Pix: novidades e regras) |
| Hospedagem | Hostinger developers / changelog da API |

## Descoberta (coisas novas)

- GitHub trending (semanal): tópicos `mcp`, `claude-code`, `agent-skills`
- Hacker News (front page e "Show HN")
- Diretórios: claudemarketplaces.com, mcp.directory, glama.ai
