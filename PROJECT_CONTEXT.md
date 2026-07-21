# PROJECT_CONTEXT.md — current working context

**Last updated:** 2026-07-18  
**Branch:** `feat/paper-doodle-ui`  
**Product:** Entangl Flutter app

This file changes frequently. Permanent rules live in `GROK.md`.

---

## Active focus

1. **Paper-doodle UI refresh** — light cream theme, ink outlines, pastel chips, Stitch-aligned home/profile/create/nav (committed on this branch).
2. **Living knowledge base** — `GROK.md`, `TODO.md`, `PROJECT_CONTEXT.md`, and `docs/{architecture,design-system,roadmap,content}.md`.
3. Prior branch work still in history: UX Phase 1–2, FCM notifications, docs folder reorg (`feat/ux-and-notifications` lineage).

---

## Implementation status (high level)

| Area | Status | Notes |
|------|--------|--------|
| Auth (login/register/forgot/approval) | Shipped | Supabase Auth + status gate |
| Feed + reactions + comments | Shipped | Optimistic patterns on feed |
| Stories | Shipped | Create + viewer + editor |
| Profile + edit + security split | Shipped | UX Phase 2 |
| Search + drafts + discovery | Shipped | UX Phase 2 |
| In-app notifications + deep links | Shipped | Type-aware navigation |
| Mobile FCM push | ~85% | Client + Edge + tokens; verify ops/iOS |
| Paper-doodle design system | In progress | Core screens updated; polish remaining |
| Realtime notif badge | Pending | No client subscription |
| RPC unread count | Pending | RPC exists, unused by client |
| Block/report | Skipped | Product decision |
| Web push | Skipped | — |

---

## Recent progress

- Organized deep docs under `docs/architecture`, `docs/ux`, `docs/notifications`.
- UX Phase 1: skeletons, stories entry, splash.
- UX Phase 2: search debounce/recents, drafts, account security.
- Notifications: FCM token lifecycle, send-push Edge Function, device_tokens.
- **Paper-doodle UI:** tokens, post cards, nav pill, auth fields, profile header, create form, dynamic aspect images; app defaults to light theme.

---

## Known issues / gaps

- Notification type prefs still mostly local (not server-enforced).
- Soft-ask for notification permission + iOS APNs ops still open.
- Dark theme may lag the new paper-doodle light system on some screens.
- `.stitch/` and `.mcp.json` are local design tooling — not committed by default.

---

## Next priorities

1. Visual QA pass on remaining screens vs paper-doodle tokens.
2. Notification backlog: RPC unread count, Realtime badge (see `docs/notifications/PENDING.md`).
3. UX Phase 3 items that are still open (upload progress, double-tap like, etc.).
4. Keep living docs updated at end of each session.

---

## How to onboard a new session

1. Read `GROK.md` (conventions + stack).
2. Read this file (what’s active).
3. Skim `TODO.md` and `docs/roadmap.md`.
4. For deep dives: `docs/README.md` → relevant deep doc.
