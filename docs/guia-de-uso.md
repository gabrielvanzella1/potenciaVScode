# Guia de uso — seu ambiente Claude Code

Como tirar proveito de cada ferramenta no dia a dia. Os exemplos são pedidos que você digita no chat do Claude Code. Quase tudo funciona em **linguagem natural** — os comandos com `/` são atalhos.

> Dica geral: digite `/` no chat para ver todos os comandos e skills disponíveis. Plugins aparecem como `/nome-do-plugin:comando` quando há nomes repetidos.

---

## 0. Primeiro dia (uma vez só)

1. **Abra uma sessão nova** do Claude Code (tudo que foi instalado só carrega em sessão nova).
2. **Logins:** digite `/mcp`, escolha cada servidor marcado "needs authentication" → **Authenticate**: atlassian, mercadopago, mapbox (2), expo, meta_social_technologies (e hostinger em casa).
3. **GitHub:** crie o token e salve na variável (ver `docs/setup-ambiente.md`, seção 11). Reabra o VS Code.
4. Confira: `/mcp` (servidores) e `/plugin` (plugins). `/context` mostra quanto do contexto cada coisa ocupa.

---

## 1. Programando (automático + pedidos)

| Ferramenta | Como usar |
|---|---|
| **LSPs** (TS/JS, Python, C#, PHP, Java, Kotlin) | Automático. Depois de cada edição o Claude vê os erros de tipo e corrige sozinho. Pedidos: *"ache todas as referências de `calcularFrete`"*, *"vá para a definição de `UserService`"* |
| **Serena** | *"use o serena para renomear `userId` para `clienteId` no projeto todo"*, *"use o serena para substituir o corpo da função `validarPedido`"*. Painel: http://localhost:24282/dashboard/ |
| **Graphify** (projetos grandes) | Na pasta do projeto: `graphify claude install` (uma vez), depois no chat `/graphify .` para gerar o grafo. Pergunte: *"como o módulo de pagamentos se conecta ao de pedidos?"*, *"quais arquivos dependem de `config.php`?"* |
| **Context7** | Acrescente **"use context7"** ao pedido: *"crie o endpoint de data_exchange do WhatsApp Flows em Node, use context7"* |
| **Ponytail** | Automático (modo `full`): código mais enxuto, sem libs desnecessárias. Trocar intensidade: `/ponytail lite`, `/ponytail full`, `/ponytail ultra`, `/ponytail off`. Skills: `/ponytail-review` (revisar excesso no diff), `/ponytail-audit` (auditar o projeto), `/ponytail-debt` (dívida técnica), `/ponytail-gain` (quanto economizou) |
| **Superpowers** | Para features maiores, peça: *"vamos fazer um brainstorm da feature X"* → ele conduz brainstorm → plano escrito → TDD → subagentes → revisão. Para bugs: *"depure sistematicamente o erro Y"*. Se atrapalhar tarefas pequenas: `/plugin` → desabilitar `superpowers` |
| **feature-dev** | `/feature-dev adicionar filtro por distância no ScanTE` — 7 fases com agentes explorador, arquiteto e revisor |
| **security-guidance** | Automático: avisa na hora sobre padrões perigosos, revisa o diff ao fim de cada resposta e revisa cada `git commit`. Você não precisa fazer nada |
| **claude-code-setup** | Em cada projeto novo: *"analise este projeto e recomende automações (hooks, skills, MCPs)"* |
| **Skills da Anthropic** | Automáticas quando o assunto aparece: frontend-design (*"crie uma landing page para o AprovIA"*), webapp-testing, mcp-builder, skill-creator (*"crie uma skill para o padrão de API dos meus projetos"*) |

---

## 2. Testando

| Ferramenta | Pedidos de exemplo |
|---|---|
| **Playwright** | *"abra http://localhost/vitrinewhats, adicione 2 itens ao carrinho e confira o total"*, *"teste o login do scante-admin com usuário inválido e tire um screenshot"* |
| **Chrome DevTools** | *"abra a landing page e me diga os Core Web Vitals"*, *"quais erros aparecem no console ao enviar o formulário?"*, *"por que a requisição /api/pedidos está lenta?"* |
| **mobile-mcp** (Android) | Ligue o emulador (ou celular com depuração USB). *"liste os dispositivos conectados"*, *"abra o app X, faça o cadastro com dados de teste e me mostre cada tela"*, *"instale este APK e teste o fluxo de pedido"* |

---

## 3. Banco de dados (DBHub)

**Antes:** inicie o MySQL no Laragon.

- *"no banco scante_admin, liste as tabelas e as colunas da tabela de scans"*
- *"no vitrinewhats, quais produtos estão sem preço?"*
- *"no scante_admin, crie uma coluna POINT SRID 4326 com índice espacial para latitude/longitude e migre os dados existentes"* (ele pede confirmação antes de cada SQL que altera dados)

Bancos disponíveis: app, estuda_concursos, laboratorio, myactive, projetovendatudo, scante_admin, sistema_ativos, sistema_ativos_v1, vitrinewhats, vztech_helpdesk. Adicionar/remover: editar `%USERPROFILE%\.dbhub\dbhub.toml`.

---

## 4. GitHub e Jira

| Ferramenta | Pedidos |
|---|---|
| **GitHub** (após o token) | *"por que a última Action do repo X falhou?"*, *"abra uma issue com este bug e os passos para reproduzir"*, *"há alertas do Dependabot nos meus repos?"*, *"revise o PR #12"* |
| **Jira/Confluence** | *"crie uma história no Jira para o filtro por distância do ScanTE"*, skill `spec-to-backlog` (*"transforme esta especificação em épicos e histórias"*), `triage-issue`, `generate-status-report` (*"gere o relatório de status da sprint"*), `capture-tasks-from-meeting-notes` |

---

## 5. Deploy na Hostinger (em casa — no trabalho a rede bloqueia)

- *"faça deploy deste site estático no meudominio.com.br"*
- *"faça deploy deste app Node/Next.js na Hostinger"*
- *"liste meus domínios e os registros DNS de meudominio.com.br"*

Compras, pagamentos e exclusões estão **bloqueados** por segurança (seção 14 do setup). Se precisar de um deles, faça pelo hPanel.

---

## 6. Seus domínios

### Cardápio no WhatsApp
Fluxo recomendado (ver `radar/pesquisas/2026-09-23-seus-projetos.md`):
1. *"use context7 e a documentação da Meta: desenhe um Flow dinâmico de cardápio com telas categorias → itens → adicionais → carrinho → endereço, lendo do banco vitrinewhats"*
2. *"implemente o endpoint data_exchange com a criptografia exigida pela Meta"*
3. *"gere a mensagem order_details com Pix e o webhook de confirmação"*
- **Meta MCP:** *"pesquise na documentação da Meta os limites de telas de um Flow"*, *"quais mudanças recentes no changelog da WhatsApp Cloud API?"*

### ScanTE (geolocalização)
- *"use o mapbox para criar um mapa com os pontos de scan do banco scante_admin, com clusters"*
- skills do Mapbox entram sozinhas: store locator, geocoding, rotas, Android/Flutter
- *"pesquise no Google Maps Code Assist como usar o Places API (New) para buscar estabelecimentos próximos"*

### Pagamentos (Mercado Pago)
- `/mp-connect` — conectar sua conta (OAuth)
- `/mp-integrate` — *"integre Pix e cartão no checkout do AprovIA com assinatura mensal"*
- `/mp-webhooks` — configurar e validar webhooks
- `/mp-test-setup`, `/mp-test-cards` — ambiente de teste e cartões de teste
- `/mp-review` — revisar a integração antes de ir para produção
- O hook bloqueia automaticamente tokens `APP_USR-…` em arquivos — use variáveis de ambiente.

### Apps
- **Expo/React Native:** skills automáticas (expo-router, eas-update, eas-app-stores, expo-upgrade…). *"configure o EAS Build para Android"*, *"atualize o app para o SDK mais recente do Expo"*
- **Flutter:** quando instalar o SDK, adicione o `dart mcp-server` (seção 17 do setup) — aí o Claude roda testes, vê widgets e faz hot reload
- **Android nativo:** LSPs Kotlin/Java + mobile-mcp para testar no emulador

---

## 7. Radar de tecnologia

- `/radar` — atualização completa (segurança → novidades → descobertas), gera relatório em `radar/pesquisas/` e atualiza `radar/radar.md`
- `/radar whatsapp` (ou `geo`, `mobile`, `pagamentos`…) — foca num domínio
- **Rotina semanal** (depois de liberar o app do Claude no GitHub): toda segunda 08:00 chega um Pull Request no repositório `potenciaVScode` — leia, comente e faça merge do que concordar
- Viu algo interessante? *"avalie a ferramenta X e coloque no radar"*

---

## 8. Memória

| Tipo | Como usar |
|---|---|
| **Memória automática do Claude Code** | *"lembre que no ScanTE usamos MySQL 8.4 com SRID 4326"* — fica para as próximas sessões |
| **Memory MCP (grafo)** | *"registre no grafo de memória que o projeto AprovIA usa o banco estuda_concursos e FSRS"* / *"o que você sabe sobre o AprovIA no grafo de memória?"* |

---

## 9. Controle de custo e contexto

Cada plugin ocupa um pouco do contexto em **toda** sessão (medido: Expo ~4,4k tokens, Mapbox ~1,7k, Atlassian ~1,1k, Ponytail ~1k, Superpowers ~0,8k, Hostinger ~0,8k, Mercado Pago ~0,7k).

- `/context` — ver o que está ocupando espaço
- `/plugin` → desabilitar o que não usa no momento (ex.: Expo e Mapbox fora de projetos mobile/geo)
- Por projeto: no `.claude/settings.json` do projeto, `"enabledPlugins": { "expo@claude-plugins-official": true }` liga só ali (desabilite globalmente e habilite por projeto)
- `security-guidance` gasta uso da assinatura a cada resposta; para desligar só a revisão por turno: variável `ENABLE_STOP_REVIEW=0`
