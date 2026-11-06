---
name: ava-retreat-house
description: Build and change the Ava-Makar retreat house (بيت الخلوة) — accounts, booking requests with up to 2 companions, eligibility rules from the calendar engine, encrypted ID and confession-letter attachments, the father's inbox for approvals and inquiries, PDF confirmation by e-mail/WhatsApp, concurrency-safe database. Use for any retreat-house screen, API, rule or data change.
---

# Retreat house

**Sources of truth:**
- `docs/spec/RETREAT_HOUSE_SOURCE_2026-11-04.md` — the monastery text, shown verbatim to users;
- `data/rules/retreat_rules.json` — rules as data, versioned and editable in the CMS;
- DEC-P0-31, 32, 33 and HANDOFF §8.

## Flows
1. **Account:**
   - **Name:** 3 fields (name, father's name, grandfather's name) plus an optional family name, or one full-name field.
   - **Contact and person:** e-mail, phone, address, date of birth.
   - **Church:** confession father, church, governorate (official list) or diocese (free text until the official list arrives — never invent the list).
   - **Occupation:** job, student or graduate.
   - **National ID image.**
2. **Request** (lay youth, clergy and monks, or abroad — all in-app, **no inbound WhatsApp**):
   - **Programme, dates, people:** applicant plus «+ إضافة مرافق» up to 2 (max 3). Each companion has the same fields.
   - **Attachments:** ID image and confession-father letter, **required for every person** (PDF or image).
   - **Instructions:** must be read and accepted.
3. **Eligibility** (server-side, per person; refuse the whole request and name the person and the reason):
   - **Age:** ≥ 16; < 30 except in the major Lord's fasts (`fastOn` ∈ {nativity, paramounNativity, paramounEpiphany, greatLent}).
   - **Gap:** ≥ 60 days since the person's last retreat.
   - **Notice:** ≥ 7 days (clergy: 14 days for Monday to Wednesday).
   - **Length:** ≤ 3 days / 2 nights; people ≤ 3 (clergy ≤ 2).
   - **Blackouts** from the engine: Jan 1 → Epiphany; Nineveh 3 days; Friday ending Lent → Thomas Sunday.
   - **Arrival window:** 08:00–16:00. Clergy arrive before 16:00 and leave before 12:00.
   - **If not eligible:** show the outer retreat house, opposite the cathedral, 01206255666, 08:00–18:00.
4. **Father's inbox** (role `retreat_father` / `retreat_manager`):
   - Lists requests with every person and their attachments; approve or refuse the whole request; assigns room or bed (visitors do not choose rooms).
   - **Inquiries:** full name, phone, governorate, confession father, church, subject, message. He replies in-app; the user is notified in-app and by e-mail.
5. **On approval:** generate a PDF confirmation listing all people, sent by:
   - e-mail;
   - in-app notification;
   - WhatsApp — **outbound only**, through the WhatsApp Business Cloud API template, once the monastery account exists; until then the code path stays disabled behind a flag.

## Data and security
- **Tables:** `persons`, `accounts`, `retreat_programmes`, `rooms`, `retreat_requests`, `request_people`, `attachments`, `request_status_history`, `inquiries`, `inquiry_messages`, `audit_log`.
- **No double booking:** a transaction plus an exclusion or unique constraint on room/bed × night; idempotency key per submission. A test fires parallel requests and asserts one wins.
- **Attachments:** envelope encryption (per-file data key wrapped by a master key held outside the database); **kept, never deleted**.
  - Only `retreat_manager` and `app_admin` may decrypt.
  - Every open is written to `audit_log`.
- **Minimum data elsewhere;** youth-safe defaults; no data in logs.

## Tests (required)
- Eligibility truth table, including fast and blackout edges across years (use the engine).
- Companions failing individually.
- Concurrency.
- Idempotent resubmit.
- The attachment access matrix.
- End-to-end: request → approve → PDF → notifications → cancel.
