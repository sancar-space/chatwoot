# Chatwoot — Fork Sancar

> Fork mantido pela [Sancar](https://sancar.space), consultoria especializada em CRM e automação de atendimento.

Este repositório é um fork do [Chatwoot](https://github.com/chatwoot/chatwoot) (open-source, licença MIT) com customizações e infraestrutura de deploy voltadas para o produto **Stella** da Sancar — solução de atendimento com IA, WhatsApp nativo e automações n8n.

---

## O que há de diferente neste fork

| Adição | Descrição |
|---|---|
| `deploy/` | Scripts e configs de deploy (Docker Compose para Coolify, staging e produção) |
| Integração Baileys | Suporte a WhatsApp nativo via `ghcr.io/fazer-ai/baileys-api` (sem Evolution API) |
| Variáveis de ambiente Baileys | `BAILEYS_PROVIDER_*` para conexão interna entre Rails e a Baileys API |
| Docker Compose Coolify | `deploy/docker-compose.coolify-staging.yml` pronto para importar no Coolify |

### Stack completo

```
Chatwoot (este repo)  ←→  Baileys API  ←→  WhatsApp
         ↕
        n8n  ←→  DeepSeek / Groq / ElevenLabs
         ↕
     PostgreSQL + Redis
```

---

## Repositórios relacionados

| Repositório | Descrição |
|---|---|
| [sancar-space/chatwoot](https://github.com/sancar-space/chatwoot) | Este repo — fork do Chatwoot com infra Sancar |
| [sancar-space/n8n-automatizando-chatwoot](https://github.com/sancar-space/n8n-automatizando-chatwoot) | Templates n8n prontos para importar: agente IA, transbordo humano, agendamento, cobranças |

---

## Pasta `deploy/`

A pasta `deploy/` (branch `develop`) contém:

| Arquivo | Descrição |
|---|---|
| `docker-compose.coolify-staging.yml` | Compose completo para staging no Coolify — Chatwoot + Baileys API + PostgreSQL + Redis |
| `n8n-templates/` | Templates n8n (mantidos também no repo dedicado acima) |

### Variáveis de ambiente obrigatórias (Baileys)

Essas variáveis precisam estar presentes nos serviços `rails` e `sidekiq` para que o WhatsApp funcione:

```env
BAILEYS_PROVIDER_DEFAULT_URL=http://baileys-api:3025
BAILEYS_PROVIDER_DEFAULT_API_KEY=<chave gerada — openssl rand -hex 32>
BAILEYS_PROVIDER_DEFAULT_CLIENT_NAME=Stella
BAILEYS_PROVIDER_USE_INTERNAL_HOST_URL=true
INTERNAL_HOST_URL=http://rails:3000
```

---

## Deploy rápido (Coolify)

1. Importe o arquivo `deploy/docker-compose.coolify-staging.yml` no Coolify
2. Configure as variáveis de ambiente (ver seção acima + `.env.example`)
3. Defina os domínios: `chat.SEU_DOMINIO` para o Chatwoot, `n8n.SEU_DOMINIO` para o n8n
4. Faça o primeiro deploy
5. Importe os workflows n8n do repositório [n8n-automatizando-chatwoot](https://github.com/sancar-space/n8n-automatizando-chatwoot) — começando pelo `00-configuracoes.json`

---

## Desenvolvimento local

Os passos de setup local são os mesmos do Chatwoot upstream:

```bash
git clone https://github.com/sancar-space/chatwoot
cd chatwoot
bundle install
pnpm install
cp .env.example .env
# edite .env com suas configurações
bundle exec rails db:create db:migrate
pnpm dev
```

Consulte a [documentação oficial do Chatwoot](https://www.chatwoot.com/docs/contributing-guide/setup-guide) para setup detalhado.

---

## Imagem Docker

Este fork usa como base a imagem:

```
ghcr.io/fazer-ai/chatwoot:latest
```

Essa imagem inclui suporte a WhatsApp nativo via Baileys, interface em PT-BR e funcionalidades internas usadas pela Sancar. Para builds próprias, use o `Dockerfile` neste repositório.

---

## Contribuindo

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para o fluxo de contribuição.

---

## Sobre a Sancar

[Sancar](https://sancar.space) é uma consultoria especializada em CRM e automação de atendimento. Ajudamos empresas a implementar soluções de atendimento com IA, integrações e processos que escalam.

---

## Licença

O Chatwoot upstream é licenciado sob a [licença MIT](LICENSE) e mantido pela [Chatwoot Inc](https://github.com/chatwoot/chatwoot). As adições específicas da Sancar neste fork seguem a mesma licença.
