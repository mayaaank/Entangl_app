# TODO.md — Entangl task tracker

**Last updated:** 2026-07-18

Status legend: `[ ]` open · `[~]` in progress · `[x]` done · `[-]` skipped/wontfix

---

## Completed (recent)

- [x] FCM mobile push client (token lifecycle, local notifications, deep links)
- [x] Supabase `device_tokens` + Edge Function `send-push` pipeline
- [x] UX Phase 1 — feed skeletons, stories empty entry, adaptive splash
- [x] UX Phase 2 — search debounce/recents, post drafts, account security split
- [x] Docs reorg — `docs/architecture`, `docs/ux`, `docs/notifications` + index
- [x] Paper-doodle design tokens + core UI screens (home, post card, nav, profile, create, auth, settings)
- [x] Living knowledge base files (`GROK.md`, `PROJECT_CONTEXT.md`, living `docs/*.md`)

---

## In progress

- [~] Paper-doodle consistency pass on remaining surfaces (comments sheet, story viewer chrome, admin)
- [~] Design-system documentation vs code alignment

---

## Pending — notifications

- [ ] Use `get_unread_notification_count` RPC for badge
- [ ] Supabase Realtime subscription for live in-app badge
- [ ] Soft-ask notification permission UX
- [ ] iOS APNs / production FCM ops verification
- [ ] Server-side enforcement of notification type preferences
- [-] Web Push

See also: `docs/notifications/PENDING.md`.

---

## Pending — UX / product

- [ ] Double-tap like / richer media gestures
- [ ] Upload progress indicator
- [ ] Dislike education tooltip
- [ ] Profile banner / highlights polish
- [ ] Analytics hooks
- [-] Block / report / mute (deferred)

See also: `docs/ux/UI_UX_AUDIT.md` Phase 3+.

---

## Bugs

_(Add with repro steps when found.)_

---

## Technical debt

- [ ] Align any remaining dark-theme surfaces with paper-doodle light primary
- [ ] Review legacy widget names / unused mascot imports after nav redesign
- [ ] Keep `docs/DOCUMENTATION.md` brand wording (Connect → Entangl) consistent over time
- [ ] Consider documenting repository method inventory as features grow

---

## Future enhancements

- Explore / recommendations
- Multi-image & video feed posts
- Bookmarks, reposts/quotes
- DMs / lightweight messaging
- Full a11y audit (VoiceOver / TalkBack)
- Performance budget on mid-tier Android
