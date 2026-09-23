# Radar de Tecnologia

Anéis: **Adotar** (em uso, recomendado) · **Testar** (vale um piloto real) · **Avaliar** (acompanhar, estudar) · **Evitar** (risco maior que o ganho, por ora).

Cada entrada: data da última revisão, por que está no anel, e o que faria mudar de anel.

| Tecnologia | Categoria | Anel | Revisado | Por quê | Muda de anel se… |
|---|---|---|---|---|---|
| Plugins LSP oficiais (TS, Python, C#, PHP, Java, Kotlin) | Ferramenta dev | Adotar | 2026-09-23 | Oficial Anthropic, local, erros de tipo após cada edição | — |
| Ponytail | Ferramenta dev | Adotar | 2026-09-23 | −10% custo medido pela JetBrains, local, MIT | qualidade cair em projetos reais |
| Agent Skills (`anthropics/skills`) | Ferramenta dev | Adotar | 2026-09-23 | Padrão aberto, Anthropic | — |
| Context7 | Docs de libs (MCP) | Adotar | 2026-09-23 | Docs da versão exata; só a consulta sai (Upstash) | novo incidente de envenenamento de docs |
| Playwright MCP | Navegador/testes | Adotar | 2026-09-23 | Microsoft, Claude testa a própria UI | — |
| Chrome DevTools MCP | Navegador/debug | Adotar | 2026-09-23 | Google; usar com `--no-usage-statistics --no-performance-crux` | — |
| Playwright CLI + skills (`@playwright/cli`) | Navegador/testes | Testar | 2026-09-23 | Microsoft diz ser mais econômico em tokens que o MCP; ainda 0.1.x | chegar a 1.0 / medir economia real |
| Serena | Código (MCP) | Testar | 2026-09-23 | Edição por símbolo; sobrepõe LSPs; hooks custam ~280 ms/ferramenta | ver se o Claude usa sem hooks |
| GitHub MCP (remoto, lockdown + PAT fine-grained) | Git/GitHub | Adotar | 2026-09-23 | Actions, Dependabot, code scanning; blindado contra o ataque de issue maliciosa | — |
| DBHub (Bytebase) | Banco de dados | Adotar | 2026-09-23 | MySQL/Postgres/SQLite/SQL Server, 1 ferramenta por banco, `lazy = true` | — |
| Jira + Confluence (Atlassian MCP) | Gestão de projeto | Adotar | 2026-09-23 | Escolha do usuário; MCP remoto oficial GA desde fev/2026 | — |
| GitHub Issues + Projects | Gestão de projeto | Avaliar | 2026-09-23 | Alternativa gratuita junto do código; token fine-grained não acessa Projects de conta pessoal (usar auto-add) | se Jira ficar pesado para projetos solo |
| Linear | Gestão de projeto | Avaliar | 2026-09-23 | Melhor UX/MCP para times de dev | montar equipe |
| Hostinger MCP (com deny de 34 ferramentas) | Deploy/hospedagem | Testar | 2026-09-23 | Oficial; 351 ferramentas incl. cobrança e VPS — travado contra compras/exclusões | validar deploy Node.js/PHP real |
| Sentry | Monitoramento de erros | Testar | 2026-09-23 | Plano grátis + MCP remoto oficial; hoje não há monitoramento em produção | criar conta e instrumentar ScanTE/AprovIA |
| PostgreSQL + PostGIS | Banco/geo | Avaliar | 2026-09-23 | Padrão ouro para geolocalização (ScanTE); já existe PG 17 instalado nesta máquina | pesquisa de geo concluir |
| Superpowers (obra) | Metodologia | Testar | 2026-09-23 | 290k ⭐, brainstorm→plano→TDD→subagentes; sobrepõe feature-dev | se atrasar tarefas pequenas → desligar |
| Exa | Busca web | Avaliar | 2026-09-23 | Busca semântica e "find similar"; busca nativa basta hoje | radar precisar de busca mais profunda |
| Firecrawl | Scraping | Avaliar | 2026-09-23 | Raspagem estruturada; ideia: coletar dados de atrações/eventos para apps de turismo | projeto de turismo precisar de dados externos |
| Snyk Agent Scan | Segurança de MCP | Avaliar | 2026-09-23 | Audita MCPs/skills contra tool poisoning; exige conta Snyk | instalar MCPs de terceiros menos conhecidos |
| Docker Desktop / MCP Gateway | Infra | Evitar (trabalho) | 2026-09-23 | Licença paga em empresas >250 func.; usuário não quer Docker | — (alternativa livre: Podman Desktop) |
| WhatsApp Flows dinâmicos + `order_details` Pix | Cardápio WhatsApp | Adotar | 2026-09-23 | Cobrança por mensagem de serviço a partir de 01/10/2026 (~US$0,0068 BR): Flow reduz pedido de ~20 para ~3–4 mensagens | — |
| WhatsApp Business Tools MCP (Meta) | WhatsApp | Testar | 2026-09-23 | Oficial, 15/09/2026, rollout gradual; cria WABA, número, templates, testa webhooks | aparecer no painel do app |
| Meta Social Technologies MCP | WhatsApp/Meta | Testar | 2026-09-23 | Oficial beta: docs, changelog, webhooks | sair do beta |
| MCPs de WhatsApp Web não oficiais (`lharries/whatsapp-mcp` etc.) | WhatsApp | Evitar | 2026-09-23 | Violam termos da Meta; risco de banimento; parado desde 07/2025 | — |
| MySQL 8.4 espacial (POINT SRID 4326 + SPATIAL INDEX + bounding box) | Geo (ScanTE) | Adotar | 2026-09-23 | Já é o banco do ScanTE; resolve raio/"perto de mim" | precisar de polígonos/rotas complexas → PostGIS |
| Mapbox (plugin oficial) | Geo | Testar | 2026-09-23 | 3 MCPs + 20 skills (web/Android/Flutter/iOS) | — |
| Google Maps Code Assist MCP | Geo | Adotar | 2026-09-23 | Docs oficiais Google Maps; grátis (experimental) | virar pago |
| Maps Grounding Lite (Google) | Geo/IA no produto | Avaliar | 2026-09-23 | MCP de runtime (lugares, rotas) para assistentes de turismo | projeto de turismo com IA |
| H3 (grade hexagonal) | Geo | Avaliar | 2026-09-23 | Agregações/heatmaps de scans por região | ScanTE precisar de analytics geográfico |
| Viator / GetYourGuide / Duffel | Turismo | Avaliar | 2026-09-23 | APIs de passeios (afiliado) e voos (pay-as-you-go) | projeto de turismo iniciar |
| FSRS (repetição espaçada) | Educação (AprovIA) | Testar | 2026-09-23 | 20–30% menos revisões que SM-2; libs open source | — |
| Mercado Pago (plugin oficial) | Pagamentos | Adotar | 2026-09-23 | Pix, assinaturas, checkout; OAuth; hook anti-vazamento de credenciais | — |
| `codespar/mcp-dev-latam` | Pagamentos/fiscal BR | Avaliar | 2026-09-23 | MCPs comunitários: Pix, NF-e, bancos | necessidade de NF-e |
| Expo (plugin oficial) | Mobile | Adotar | 2026-09-23 | Skills + MCP: docs, EAS, TestFlight; telemetria opt-in | — |
| Dart/Flutter MCP (`dart mcp-server`) | Mobile | Testar | 2026-09-23 | Oficial no SDK Dart 3.9+; hot reload, widgets, testes | instalar Flutter SDK |
| mobile-mcp (mobile-next) | Mobile/testes | Testar | 2026-09-23 | Controle de emulador/celular via adb; telemetria desligada por env | — |
| Graphify | Ferramenta dev | Testar | 2026-09-23 | Local, promete ~70× menos tokens em repos grandes; pré-1.0 | medir ganho real num repo grande (ScanTE/AprovIA) |
| Jev (TypeSafe AI) | Modelo de IA | Avaliar | 2026-09-23 | "System One": decisões tipadas com probabilidade calibrada, US$0,042/M tokens, lançado 15/09/2026. Ideias: classificar/pontuar no ScanTE e AprovIA via SDK oficial (`@typesafe-ai/sdk`, `typesafe_sdk`) | amadurecer (GA, preço definitivo), benchmarks independentes. Plugins de Claude Code são todos de terceiros e recentes — não usar por ora |
| OmniRoute | Gateway de LLM | Evitar | 2026-09-23 | CVE-2026-88062 (RCE, 10/09/2026), endpoint que lê tokens do Cursor sem auth, v3.8.5 sinalizada pelo Socket.dev (MITM/root CA), risco de ToS; código vai para provedores variados | CVEs corrigidas + auditoria independente; e mesmo assim só em VM/container, fora da máquina corporativa |
