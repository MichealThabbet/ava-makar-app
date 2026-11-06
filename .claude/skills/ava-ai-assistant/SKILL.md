---
name: ava-ai-assistant
description: Design and build the Ava-Makar AI guide/assistant for visitors and members, grounded only in approved monastery content (RAG) with sources, no generated sacred text, privacy-first and budget-capped. Use for any chat assistant, search answering or AI feature.
---

# AI assistant (guide for visitors and members)

**Status:** in scope (DEC-P0-34). **The owner wants it free (2026-11-06):** you build it, with no paid subscription.

**Tiers (each one works on its own):**
- **Tier 0 — free, offline, no LLM (build first):**
  - intent matching in Arabic and English (keywords, synonyms, normalised Arabic);
  - FTS5 retrieval over approved content and the rules data;
  - templated answers that quote stored text, with the source and a deep link;
  - calendar-engine answers.
- **Tier 1 — free, on device:** a small open-weight model in the browser or app (WebLLM / ONNX Runtime) only to phrase retrieved facts. Ship it only if it is proven fast on an average phone; otherwise keep Tier 0.
- **Tier 2 — optional paid API:** only with the owner's budget approval. The key goes through `request_credential` (never in code, env files or chat).

## What it does
- **Visitors:**
  - visiting hours, the way to the monastery, the retreat rules (from the rules data);
  - today's readings and rite (calendar engine);
  - "where is …" in the books and the tour, opening the right screen (deep links);
  - languages: the five UI languages.
- **Members:** retreat request status, reminders, their saved items.

## Hard rules
- Answers come only from approved content via retrieval:
  - the content database and FTS5 plus embeddings;
  - every answer cites its source (book, section, link).
- Never generate, complete, paraphrase or translate prayers, verses, hymns or rites. Show the stored text, or link to it.
- **Doctrinal or personal spiritual questions:** give the approved reference if one exists; otherwise answer kindly «اسأل أب اعترافك».
- **No personal data in prompts or logs;** members' data is fetched by tool calls with their own token only.
- **Refuse:** off-topic misuse, medical/legal advice, impersonating fathers.

## Architecture
- A NestJS endpoint `/assistant`. Tools:
  - `search_content`;
  - `get_today` (engine);
  - `get_retreat_rules`;
  - `get_my_requests` (auth).
- **Model:** none in Tier 0. Tier 1: smallest open model that passes the evaluation set. Tier 2: the cheapest API model that passes (see the `claude-api` skill), with an answer cache, a daily token cap and a per-user rate limit.
- **Evaluation set:** 50 real questions with expected sources; run before every release; track refusals and wrong-source answers.
