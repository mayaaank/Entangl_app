# Notification Module — Implementation Status & Progress

**Last updated:** 2026-07-18  
**Product:** Entangl  
**Canonical pending backlog:** [PENDING.md](PENDING.md)  
**Push ops guide:** [PUSH.md](PUSH.md)  
**Docs index:** [../README.md](../README.md)

---

## 1. Overall progress

| Track | Progress | Notes |
|-------|----------|--------|
| **In-app activity feed** | **~95%** | List, badge, mark read, deep links working |
| **Server-side creation** | **100%** | Triggers + `create_notification` on remote |
| **Mobile FCM push** | **~85%** | Client + DB + Edge code; verify secrets/iOS |
| **Web Push** | **Skipped** | `push_subscriptions` unused by app |
| **Supabase Realtime (in-app live)** | **0%** | Not coded |
| **RPC unread count** | **0%** | RPC exists; app does not call it |
| **Server-enforced type prefs** | **0%** | Local toggles only |
| **Block / report** | **Skipped** | Product decision |

**Module health:** Core path is **production-capable** on Android if Edge secrets and deploy are verified. Remaining work is Realtime, RPC, prefs integrity, and iOS polish.

---

## 2. What has been completed

### 2.1 Phase 1 UX (quick wins)

| Item | Status | Location |
|------|--------|----------|
| Type-aware deep links | Done | `lib/features/notifications/utils/notification_navigation.dart` |
| Mark one / mark all / dismiss | Done | providers + repository |
| Optimistic mark-read + badge invalidate | Done | `notifications_provider.dart` |
| Skeleton / capped stagger / humanised errors | Done | `notifications_screen.dart` |
| Home bell badge | Done | `home_screen.dart` |
| `getPostById` for deep links | Done | `posts_repository.dart` |

### 2.2 Backend (Supabase)

| Item | Status |
|------|--------|
| `notifications` table + RLS | Done (remote) |
| Triggers: like, dislike, comment, follow | Done |
| Types: follow, like, dislike, comment, reply | Done |
| `device_tokens` + RLS | Done — migration `20260717153000` |
| `notify_send_push` + `pg_net` trigger | Done — migration `20260717154500` |
| Migrations local ↔ remote | Synced (4 migrations) |
| CLI linked project | Entangl `lmohyfcmiftvuluhyaqh` |

### 2.3 Mobile push (FCM)

| Item | Status |
|------|--------|
| `firebase_core` / `firebase_messaging` / local notifications | Done |
| `NotificationService` | Done |
| Token upsert / refresh / delete | Done |
| Bootstrap on auth + settings | Done |
| Sign-out unregisters token | Done (`AuthNotifier`) |
| Cold start / background tap → deep link | Done (`PushNotificationBinder`) |
| Foreground message → refresh list/badge | Done |
| Edge Function `send-push` | In repo |
| Android `google-services.json` + permissions | Present |
| iOS `GoogleService-Info.plist` | Check tree / FlutterFire setup |
| Web Push client | **Skipped** |

### 2.4 Stack (as built)

| Layer | Technology |
|-------|------------|
| UI / state | Flutter, Riverpod, GoRouter |
| Auth / DB | Supabase Auth, Postgres, RLS |
| In-app rows | `notifications` + triggers |
| Device push | **FCM** (not Web Push) |
| Token store | `device_tokens` |
| Send path | `pg_net` → Edge Function → FCM HTTP v1 |
| Local prefs | SharedPreferences (`notificationSettingsProvider`) |

---

## 3. Architecture (current)

```
[Like / Comment / Follow / …]
           │
           ▼
   public.notifications  (INSERT via triggers)
           │
           ├──────────────────────────────┐
           ▼                              ▼
   Flutter pull (list/badge)     notify_send_push (pg_net)
           │                              │
           │                              ▼
           │                     Edge Function send-push
           │                              │
           │                              ▼
           │                        device_tokens → FCM
           │                              │
           ▼                              ▼
   NotificationsScreen /           OS notification
   unreadCountProvider             │
           │                       ▼
           └────── deep link ◄──── tap / cold start
                   openNotificationTarget
```

**Not in diagram (pending):** Supabase Realtime channel on `notifications`.

---

## 4. Key source files

| Path | Responsibility |
|------|----------------|
| `lib/features/notifications/screens/notifications_screen.dart` | Inbox UI |
| `lib/features/notifications/providers/notifications_provider.dart` | List + unread providers |
| `lib/features/notifications/providers/push_bootstrap_provider.dart` | FCM lifecycle |
| `lib/features/notifications/utils/notification_navigation.dart` | Deep links |
| `lib/features/notifications/widgets/notification_tile.dart` | Row UI |
| `lib/data/repositories/notifications_repository.dart` | CRUD / count |
| `lib/data/repositories/device_tokens_repository.dart` | FCM tokens |
| `lib/data/services/notification_service.dart` | FCM + local notifs |
| `lib/data/models/notification_model.dart` | Types + JSON |
| `lib/main.dart` | Firebase + Supabase + binder |
| `supabase/functions/send-push/index.ts` | FCM sender |
| `supabase/migrations/20260717153000_device_tokens.sql` | Tokens |
| `supabase/migrations/20260717154500_notify_send_push.sql` | Push trigger |

---

## 5. Roadmap alignment

| Planned item | Status |
|--------------|--------|
| In-app feed + deep links | **Complete** |
| Skip web push | **Complete** (intentional) |
| Mobile FCM | **Code complete**; ops/iOS verify |
| RPC unread count | **Pending** |
| Realtime in-app badge | **Pending** |
| Server type preferences | **Pending** |
| Block/report | **Skipped** |

---

## 6. Progress snapshot (checklist)

### Done
- [x] DB notification creation pipeline  
- [x] In-app list / mark / delete  
- [x] Deep links by type  
- [x] FCM client + token store  
- [x] Edge send-push source + DB trigger migration  
- [x] Logout token cleanup (auth notifier path)  
- [x] Web push skipped  

### Pending
- [ ] RPC-based unread count  
- [ ] Supabase Realtime subscription  
- [ ] Server-side (or hide) type prefs  
- [ ] iOS Firebase plist + APNs (if shipping iOS push)  
- [ ] Full ops E2E checklist (secrets, deploy, Android field test)  
- [ ] Soft-ask permission UX  
- [ ] Numeric badge / pagination / undo (optional polish)  

---

## 7. Related documentation

| Document | Role |
|----------|------|
| [PENDING.md](PENDING.md) | Full pending backlog + improvement specs |
| [PUSH.md](PUSH.md) | Deploy / secrets / smoke tests for FCM |
| [../DOCUMENTATION.md](../DOCUMENTATION.md) | Product/tech suite |
| [../architecture/FOLDER_STRUCTURE.md](../architecture/FOLDER_STRUCTURE.md) | Architecture map |
| [../architecture/ARCHITECTURE_AUDIT.md](../architecture/ARCHITECTURE_AUDIT.md) | Architecture review + addendum |
| [../ux/UI_UX_AUDIT.md](../ux/UI_UX_AUDIT.md) | UX audit + phase status |

---

*Update this file when notification scope ships or is deprioritized.*
