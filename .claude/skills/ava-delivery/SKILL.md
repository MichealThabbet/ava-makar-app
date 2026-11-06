---
name: ava-delivery
description: Commit, push, publish and verify Ava-Makar work — branch rules, CI on GitHub Actions, GitHub Pages deployment, cache-busting for phones, fixing 403 push errors. Use whenever work is committed, pushed or claimed to be live.
---

# Delivery

## Git
- **Work branch:** `codex/p0-plan`. Design kit branch: `codex/home-design`. Commit after each verified slice.
- **Without the owner's explicit yes, never:**
  - force-push;
  - rewrite history;
  - merge to `main`;
  - deploy outside GitHub Pages.
- **Commit message:** first line imperative and specific; body = what and why. End it with the attribution lines the session reminder gives.
- **Before pushing:**
  - engine tests;
  - `flutter analyze` and `flutter test` in `app/`;
  - the web build if web files changed;
  - re-read your own diff adversarially.

## Publish and verify
- A push to `codex/p0-plan` triggers `.github/workflows/web-preview.yml`: tests, then `flutter build web --no-web-resources-cdn --base-href /ava-makar-app/`, then deploy to `gh-pages`. `app/web/prototype/` is copied with it.
- **Verify** with `mcp__github__actions_list` (owner `MichealThabbet`, repo `ava-makar-app`): the "Web preview" run, then "pages build and deployment", both `success` for your commit. Only then say it is live: https://michealthabbet.github.io/ava-makar-app/ (prototype: `/prototype/`).
- **Phones cache:** bump `?v=N` on every changed CSS, JS or asset URL, and give the owner the link with `?v=N`.
- github.io is not reachable from this container. Verify through the Actions result and local Playwright runs, never by guessing.

## Push refused (403)
- Usually the Claude GitHub App is installed only on the owner's other account `krvng5c6t9-rgb`.
- **Known fix:** install the Claude App on `MichealThabbet` for `ava-makar-app`, and add `krvng5c6t9-rgb` as a collaborator with Write.
- Ask the owner once, with these exact steps. Keep the commit locally and push after he confirms. Never touch the other account's ERP repository.

## Handing over
- Keep `GOAL.md`, `DECISIONS.md` and `HANDOFF.md` current at the end of every session, so a new session can continue from the last verified point.
