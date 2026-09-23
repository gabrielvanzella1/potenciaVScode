# Pesquisa por domínio — 2026-09-23

Pesquisa feita para os projetos atuais: cardápio no WhatsApp (vitrinewhats), ScanTE (geolocalização), turismo, AprovIA (concursos/estuda_concursos) e apps mobile. Cada seção: **o que mudou**, **ferramentas para o Claude Code** e **ideias de arquitetura**.

---

## 1. Cardápio digital no WhatsApp (Flows)

### O que mudou — e é urgente

- **1º/10/2026 — cobrança de mensagens de serviço.** Respostas dentro da janela de 24h (humano ou IA de terceiros), grátis desde nov/2024, passam a ser cobradas. Templates de utilidade também. **Brasil: ~US$ 0,0068 por mensagem**, sem desconto por volume. Estimativa da Meta para IA de terceiros no Brasil: US$ 27–97 por mil respostas (IA + entrega). [Landbot](https://landbot.io/blog/whatsapp-business-api-pricing-change-october)
- **Política de IA (desde 15/01/2026):** proibidos chatbots de IA de propósito geral ("tipo ChatGPT"); permitidos bots com função definida — pedidos, suporte, reservas, rastreio. Um cardápio/pedido está dentro. [Turn.io](https://learn.turn.io/l/en/article/khmn56xu3a-whats-app-s-2026-ai-policy-explained)
- **Meta Business Agent (01/07/2026):** IA da própria Meta cobrada por token (US$ 2/M tokens).
- **Pagamentos no Brasil:** Payments API com mensagem `order_details` → cliente paga por **Pix copia-e-cola** ou link de pagamento; status chega por webhook. A conciliação é sua (pelo `reference_id` com o PSP). [Meta Docs](https://developers.facebook.com/documentation/business-messaging/whatsapp/payments/payments-br/overview/)
- **Dynamic Flows** (com endpoint de dados, criptografia RSA + AES) agora também suportados via AWS End User Messaging (set/2026). [AWS](https://aws.amazon.com/about-aws/whats-new/2026/09/aws-end-user-messaging-whatsapp-dynamic-flows/)

### Ideia de arquitetura (a virada)

Com cobrança por mensagem, **cada turno de conversa custa**. O desenho mais barato e melhor para o cliente:

1. 1 mensagem de entrada (template ou resposta) → abre um **Flow dinâmico**.
2. Dentro do Flow (várias telas, **zero mensagens extras**): categorias → itens → adicionais/observações → carrinho → endereço/retirada. O endpoint `data_exchange` lê o cardápio do banco (`vitrinewhats`) em tempo real (preço, estoque, horário).
3. Ao concluir o Flow → 1 mensagem `order_details` com **Pix** → webhook confirma → 1 mensagem de confirmação.

Total: ~3–4 mensagens por pedido, em vez de 15–30 num bot conversacional.

### Ferramentas para o Claude Code

| Ferramenta | O que faz | Status |
|---|---|---|
| **Meta Social Technologies MCP** (`https://mcp.facebook.com/devtools`, OAuth) | Busca na documentação da Meta, changelog de APIs, gestão/teste de webhooks, status de App Review | Oficial, **beta**, rollout gradual |
| **WhatsApp Business Tools MCP** | Cria WABA, adiciona/verifica número, registra na Cloud API, **cria templates**, testa mensagens e webhooks | Oficial, lançado 15/09/2026, rollout gradual; endpoint aparece em developers.facebook.com → App → WhatsApp → API Setup. Só dev/teste; produção continua exigindo App Review |
| Context7 (já instalado) | Docs atualizadas da Cloud API/Flows | — |
| `lharries/whatsapp-mcp` e similares (WhatsApp Web) | **Evitar** — não oficial, viola termos da Meta, parado desde 07/2025 | — |

---

## 2. ScanTE — geolocalização

### Onde guardar e consultar

- **MySQL 8.4 (o que você já usa) resolve bem "perto de mim", raio, zonas de entrega:** coluna `POINT SRID 4326` + `SPATIAL INDEX` + filtro por bounding box (`MBRContains`, usa o índice) + `ST_Distance_Sphere` para a distância exata. ⚠️ `ST_Distance_Sphere` sozinho **não usa o índice** — sempre combinar com o bounding box. [OneUptime](https://oneuptime.com/blog/post/2026-03-31-mysql-store-query-latitude-longitude/view)
- **PostgreSQL + PostGIS** quando precisar de polígonos complexos, rotas, análises pesadas. Já existe um PostgreSQL 17 instalado nesta máquina (serviço `postgresql-x64-17`).
- **H3 (grade hexagonal da Uber)** para agregar/heatmaps ("quantos scans por região").

### Mapas e APIs

| Opção | Quando usar |
|---|---|
| **Mapbox** | Mapas customizados, busca/geocoding, rotas, SDKs web/Android/iOS/Flutter |
| **Google Maps Platform** | Places (dados de estabelecimentos/atrações), familiaridade do usuário |
| **MapLibre GL** (open source) | Renderizar mapas sem lock-in de fornecedor |

### Ferramentas para o Claude Code

| Ferramenta | O que faz | Dados |
|---|---|---|
| **Plugin `mapbox`** (oficial, marketplace) | 3 MCPs remotos (`mcp.mapbox.com` runtime: geocoding/rotas/isócronas; `mcp-devkit`: estilos, tokens; `mcp-docs`) + **20 skills** (Android, Flutter, iOS, web, store locator, navegação, migração do Google Maps, segurança de token) | ☁️ Mapbox; precisa de conta/token |
| **Google Maps Platform Code Assist** (`https://mapscodeassist.googleapis.com/mcp`) | Documentação e exemplos oficiais do Google Maps (grounding). Grátis enquanto experimental | ☁️ Google (só a consulta) |
| Maps Grounding Lite (Google) | MCP de **runtime** (buscar lugares, calcular rotas) — para colocar dentro de um produto/assistente | ☁️ Google, pago por uso |
| Plugin `amazon-location-service` (AWS) | Alternativa AWS (mapas, geocoding, rotas) | ☁️ AWS |

---

## 3. Turismo

### APIs de conteúdo e reservas

| Tipo | Opções | Modelo |
|---|---|---|
| Passeios/atrações | **Viator**, **GetYourGuide** (~33 mil atividades, 2.500+ destinos), Tiqets | Afiliado ou merchant |
| Voos | **Duffel** (300+ companhias, sem custo inicial, pay-as-you-go), Amadeus | API |
| Hotéis | Amadeus, Expedia, Booking (afiliados) | API/afiliado |
| Lugares/POIs | Google Places, Mapbox Search, OpenStreetMap | API |

[Travix Lab](https://travixlab.com/blog/best-travel-apis) · [API.market](https://api.market/blog/magicapi/travel-api/best-travel-apis-for-developers)

### Ideias

- **Assistente de roteiro** com escopo definido (dentro da política do WhatsApp): usuário diz datas/interesses → Flow com opções → roteiro com mapa (Mapbox/Google) + links de afiliado (Viator/GetYourGuide).
- **Firecrawl** (radar: Avaliar) para coletar dados de atrações/eventos locais que não estão em API.

---

## 4. AprovIA (concursos)

- **FSRS** — algoritmo open source de repetição espaçada (usado no Anki): **20–30% menos revisões que o SM-2** para a mesma retenção. Bibliotecas prontas em várias linguagens (`open-spaced-repetition`). [StudyGlen](https://studyglen.com/guides/best-spaced-repetition-apps)
- **Geração de questões a partir de editais (RAG):** validar cada afirmação contra o trecho-fonte (sem checagem de sobreposição com a fonte, o RAG alucina). Claude API com **citations** resolve isso nativamente.
- **Jev (TypeSafe)** — radar "Avaliar": classificar dificuldade/assunto de questões e pontuar respostas com probabilidade calibrada, barato.
- Conector **Unstructured** (já disponível na sua conta claude.ai, falta autorizar) — extrair texto/tabelas de PDFs de editais.

---

## 5. Apps mobile

| Stack | Ferramenta oficial para o Claude Code |
|---|---|
| **React Native / Expo** | Plugin `expo` (marketplace oficial): skills + **Expo MCP** remoto — docs do Expo, instala libs compatíveis, EAS Build/Update, TestFlight e, com recursos locais, interage com o app no simulador |
| **Flutter** | `dart mcp-server` (vem no SDK Dart 3.9+): analisa/corrige erros, roda testes, conecta no app rodando, lista widgets, screenshot, hot reload |
| **Android nativo (Kotlin/Java)** | LSPs `kotlin-lsp` + `jdtls-lsp` (já instalados). Controle de emulador/aparelho via ADB: `claude-in-mobile` (comunidade — Avaliar) |

---

## 6. Pagamentos (Brasil)

| Ferramenta | O que faz | Status |
|---|---|---|
| **Plugin `mercadopago`** (oficial) | MCP remoto com OAuth (sem token manual) + skills `mp-integrate`, `mp-webhooks`, `mp-test-setup`, `mp-review`: Checkout Pro/Bricks/API, **Pix**, QR/Point, **assinaturas**, marketplace, 3DS/PCI. Cria aplicação e credenciais pelo agente | Oficial, lançado 30/06/2026 |
| Plugin `stripe` (oficial) | Stripe (aceita Pix no Brasil) | Oficial |
| `codespar/mcp-dev-latam` | MCPs comunitários: Pix, NF-e, bancos, fiscal, logística (BR e LatAm) | Comunidade — Avaliar |
| WhatsApp Payments API (BR) | `order_details` + Pix dentro do WhatsApp (ver seção 1) | Oficial Meta |
