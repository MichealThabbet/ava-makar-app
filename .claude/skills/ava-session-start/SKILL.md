---
name: ava-session-start
description: Start of every Ava-Makar session. Reads HANDOFF.md, AGENTS.md, DECISIONS.md and GOAL.md, finds the last verified point, checks git and tools, and sets the budget rules. Use first, before any other work or long reply.
---

# Session start — Ava-Makar

1. **Read, in order:** `HANDOFF.md` (all of it), `AGENTS.md`, the last 10 rows of `DECISIONS.md`, `GOAL.md`. Do not re-read big files you do not need now.
2. **Git:**
   ```bash
   cd /home/user/ava-makar-app 2>/dev/null || git clone https://github.com/MichealThabbet/ava-makar-app /home/user/ava-makar-app
   git checkout codex/p0-plan && git pull --ff-only origin codex/p0-plan
   git status -sb && git log --oneline -8
   ```
   Unpushed commits or a dirty tree from an earlier session: inspect them, then commit or report. Never discard them.
3. **Tools (only when the task needs them):**
   - Flutter `stable 3.47.9` at `/home/user/flutter`. If missing, clone tag 3.47.9 and run `flutter --version`.
   - Engine tests: `cd packages/coptic_calendar && /home/user/flutter/bin/dart test` → expect 36 passing.
   - Playwright and Chromium are pre-installed: `require('playwright')`. Never reinstall them.
4. **Where we are:** take the last verified item in `GOAL.md` and the plan stage in HANDOFF §11. **Continue from there.** Do not redo work, do not restart a stage.
5. **First message to the owner:** one or two lines — where we stand and what is next. Ask only for a decision that changes the work, and give the default you will use.

## Budget rules (owner pays 20 USD/month)
- Short replies; one report per batch of work; at most one combined screenshot per report.
- Grep before reading; read files in ranges; avoid re-running heavy builds.
- No paid external service, no new hosting, no API key use without the owner's yes.

## Hard stops
- Owner says «استنى» or «ما تعملش» → stop immediately.
- Big scope, design or destructive change, or anything outside the repository → wait for «ابدأ».
