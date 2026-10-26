# n8n — Automações para Chatwoot

Templates n8n prontos para importar: automações de atendimento com IA integradas ao Chatwoot.

Cada workflow é independente e parametrizável. Importe só o que precisar, ou o conjunto completo para um stack de atendimento com IA, agendamento, cobranças e transbordo humano.

> Desenvolvido e mantido pela [Sancar](https://sancar.space) — consultoria em CRM e automação de atendimento.

---

## Visão geral dos workflows

| Arquivo | Descrição |
|---|---|
| `00-configuracoes.json` | **Executar primeiro** — cria tabelas PostgreSQL, labels e atributos no Chatwoot |
| `01-atendimento-ia.json` | Agente principal de IA (webhook de entrada + LLM + memória PostgreSQL) |
| `02-enviar-arquivo-gdrive.json` | Envia arquivos do Google Drive para o contato |
| `03-buscar-janelas-calendar.json` | Consulta disponibilidade no Google Calendar |
| `04-criar-evento-calendar.json` | Cria evento/agendamento no Google Calendar |
| `04.1-atualizar-agendamento.json` | Atualiza agendamento existente |
| `05-transbordo-humano.json` | Transfere conversa para atendente humano via atribuição |
| `05.1-transbordo-humano-multi-alerta.json` | Transbordo com múltiplos canais de alerta |
| `06-integracao-asaas.json` | Cobranças e links de pagamento PIX via Asaas |
| `07-quebrar-enviar-mensagens.json` | Envio humanizado de mensagens longas (múltiplos balões) |
| `07.1-baileys-quebrar-enviar-mensagens.json` | Variante otimizada para Baileys API (WhatsApp nativo) |
| `08-agente-assistente-interno.json` | Assistente de IA para uso interno da equipe de atendimento |
| `09-cancelar-agendamento.json` | Cancela agendamento no Calendar |
| `10-buscar-criar-contato-conversa.json` | Utilitário: busca ou cria contato/conversa no Chatwoot |
| `11-lembretes-agendamento.json` | Envia lembretes automáticos de agendamento |
| `12-gestao-ligacoes.json` | Gerencia chamadas de voz (ElevenLabs + Twilio) |
| `13-recuperacao-leads.json` | Follow-up automático para leads sem resposta |

---

## Pré-requisitos

### Stack compatível

- **Chatwoot** (qualquer versão recente — preferencialmente o fork [fazer-ai/chatwoot](https://github.com/fazer-ai/chatwoot) para WhatsApp nativo via Baileys)
- **n8n** v1.x ou superior
- **PostgreSQL** (mesmo banco do Chatwoot, schema `n8n` criado pelo `00-configuracoes`)

### Nodes da comunidade

Instale antes de importar os workflows. No n8n: **Settings → Community Nodes → Install**

```
@devlikeapro/n8n-nodes-chatwoot
@elevenlabs/n8n-nodes-elevenlabs
```

---

## Configuração

### 1. Variáveis de ambiente no n8n

Configure em **Settings → Variables** (ou via env do container):

| Variável | Descrição | Obrigatório |
|---|---|---|
| `CHATWOOT_URL` | URL do Chatwoot (ex: `https://chat.exemplo.com.br`) | ✅ |
| `CHATWOOT_TOKEN` | Access Token da conta (Chatwoot → Profile → Access Token) | ✅ |
| `CHATWOOT_ACCOUNT_ID` | ID numérico da conta no Chatwoot | ✅ |
| `DEEPSEEK_API_KEY` | Chave da API DeepSeek | ✅ |
| `GROQ_API_KEY` | Chave Groq — transcrição de áudio via Whisper | Se usar áudio |
| `ELEVENLABS_API_KEY` | Chave ElevenLabs — respostas em voz | Se usar voz |
| `ELEVENLABS_VOICE_ID` | ID da voz ElevenLabs | Se usar voz |
| `GOOGLE_CALENDAR_ID` | ID do calendário Google | Se usar agendamento |
| `ASAAS_API_KEY` | Chave Asaas | Se usar cobranças |

### 2. Credenciais n8n

Crie em **n8n → Credentials**:

| Tipo | Como configurar |
|---|---|
| **DeepSeek** (OpenAI API) | Base URL: `https://api.deepseek.com/v1` · API Key: sua chave DeepSeek |
| **Chatwoot** (Header Auth) | Header: `api_access_token` · Value: Access Token |
| **PostgreSQL** | Host/porta do banco Chatwoot · Schema: `n8n` |
| **Google OAuth2** | Para Calendar e Drive |
| **ElevenLabs** | API Key |
| **Asaas** | API Key |

> Para usar outro LLM no lugar do DeepSeek, edite o node "Chamar IA" no workflow `01`. Qualquer provedor compatível com a API OpenAI funciona.

---

## Importação

### Ordem recomendada

1. **`00-configuracoes.json`** — executar **uma vez** ao configurar o ambiente; cria:
   - Tabelas PostgreSQL (`n8n_historico_mensagens`, `n8n_fila_mensagens`, `n8n_status_atendimento`)
   - Labels no Chatwoot: `testando-atendente`, `atendimento-humano`
   - Atributos de conversa: `id_agente_humano`, `prompt_personalizado`

2. **`01-atendimento-ia.json`** — agente principal; copiar a URL do webhook e configurar no Chatwoot como Agent Bot

3. **`07-quebrar-enviar-mensagens.json`** ou **`07.1`** (Baileys) — copiar URL e referenciar no `01`

4. **`05-transbordo-humano.json`** — copiar URL e referenciar no `01`

5. Demais workflows conforme necessidade

### Como importar no n8n

No n8n: **Workflows → Import from file** → selecione o arquivo `.json`

---

## Transbordo humano

O workflow `05` usa a **API de atribuição do Chatwoot**, não etiquetas:

```
POST /api/v1/accounts/{account_id}/conversations/{conversation_id}/assignments
Body: { "assignee_id": <id_do_agente> }
```

Quando a conversa é atribuída a um atendente, o agente de IA para de responder automaticamente. Para reativar a IA, remova a atribuição no Chatwoot.

O `id_agente_humano` pode ser definido por conversa via atributo customizado no Chatwoot, ou fixado diretamente no workflow.

---

## Modelo de IA padrão

Os workflows usam **DeepSeek Chat** via endpoint OpenAI-compatível:

- **Endpoint:** `https://api.deepseek.com/v1`
- **Modelo:** `deepseek-chat`

Para trocar o provedor (OpenAI, Groq, OpenRouter, etc.), edite o node de chamada de IA no workflow `01` — basta apontar para outro endpoint e modelo.

---

## Stack de deploy recomendado

Para subir o ambiente completo (Chatwoot + n8n + WhatsApp), use o compose em [`sancar-space/chatwoot`](https://github.com/sancar-space/chatwoot) — pasta `deploy/`.

---

## Contribuindo

Pull requests são bem-vindos. Para adicionar um novo workflow:

1. Exporte do n8n como JSON
2. Remova credenciais e valores sensíveis (substitua por referências a variáveis)
3. Adicione ao índice neste README
4. Abra um PR com descrição do caso de uso

---

## Licença

MIT — use, adapte e distribua livremente.
