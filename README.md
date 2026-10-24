# n8n Telegram AI support bots

Three n8n workflows that turn a Telegram bot into a customer support agent for a small
business. Each tier builds on the previous one.

|                                                                    | Basic | Standard | Premium |
| ------------------------------------------------------------------ | :---: | :------: | :-----: |
| Gemini 2.5 Flash replies                                           |  yes  |   yes    |   yes   |
| Polite fallback to the customer + error report to the owner        |  yes  |   yes    |   yes   |
| Photos, stickers and voice messages answered instead of crashing   |  yes  |   yes    |   yes   |
| Conversation memory, one session per customer (Postgres)           |       |   yes    |   yes   |
| Business facts read from a database instead of the prompt          |       |   yes    |   yes   |
| Strict per-message language handling                               |       |          |   yes   |

## How it works

```
Telegram Trigger ──► Is it text? ──no──► "I can only read written messages"
                          │
                         yes
                          │
                          ▼
                       Main AI (Gemini) ──► Send reply
                          │   ├─ Postgres Chat Memory    (Standard, Premium)
                          │   └─ Get business info tool  (Standard, Premium)
                          │
                          └─ on error ──► apology to the customer
                                      └─► error text to the owner's Telegram
```

- **Memory:** each Telegram `chat.id` gets its own session; the last 10 messages are kept as
  context, so the customer does not have to repeat themselves.
- **Business info tool:** the agent queries a `business_info` key-value table
  (`working_hours`, `delivery`, `return_policy`, ...). The owner changes an answer by editing
  one row, not by editing the workflow. The facts are deliberately **not** in the system
  prompt — if they were, the agent would answer from the prompt and never query the table.
- **Error branch:** when Gemini or Telegram fails, the customer gets a sentence instead of
  silence, and the owner gets the raw error on Telegram.

## Setup

**1. Run n8n + Postgres**

```bash
cp .env.example .env     # fill in the values
docker compose up -d
```

Telegram only delivers messages to a public **HTTPS** URL, so `WEBHOOK_URL` must be one: a
reverse proxy, a tunnel, or n8n Cloud.

**2. Create the business table** (Standard and Premium only)

Run `sql/business_info.sql` against the database, then put the business's real answers in it.

**3. Import a workflow**

In n8n: **Workflows → Import from File →** pick one file from `workflows/`.

**4. Connect credentials**

- **Telegram:** a bot token from [@BotFather](https://t.me/BotFather)
- **Google Gemini:** an API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
- **Postgres** (Standard and Premium): host `postgres`, port `5432`, SSL **disabled** for the
  bundled container. Managed databases such as Supabase need SSL enabled, the Session Pooler
  host, and the username form `postgres.<project-id>`.

If the Gemini model dropdown shows a `feat:aiGateway license not supported` error, switch the
field to **By ID** and type the model name by hand.

**5. Fill in the placeholders**

Every placeholder is written in `{{DOUBLE_BRACES}}` so a search for `{{` finds all of them.

| Placeholder                | Where                             | What goes in it                        |
| -------------------------- | --------------------------------- | -------------------------------------- |
| `{{BUSINESS_NAME}}`        | Main AI system prompt             | the business's name                    |
| `{{WORKING_HOURS}}` etc.   | Main AI system prompt, Basic only | the business's real answers            |
| `{{DEFAULT_LANGUAGE}}`     | Main AI system prompt, Premium    | the language to fall back to           |
| `YOUR_TELEGRAM_CHAT_ID`    | "Send error to the owner"         | the owner's own Telegram chat id       |

The three customer-facing sentences — the apology, the non-text notice and the greeting — are
in English. Translate them into the customer's language before going live; a bot that answers
in Azerbaijani but apologises in English reads as a template.

**6. Activate** the workflow and message the bot.

## Tech

n8n · Google Gemini 2.5 Flash · Telegram Bot API · PostgreSQL · Docker Compose

## License

MIT — see [LICENSE](LICENSE).
