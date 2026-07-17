# Notification Module — Pending Work & Improvements

**Last updated:** 2026-07-18  
**Scope:** In-app activity notifications + mobile FCM push  
**Explicitly out of scope:** Web Push, block/report/mute  
**Related:** [STATUS.md](STATUS.md), [PUSH.md](PUSH.md), [../README.md](../README.md)

---

## 1. Current implementation (brief)

The Notification module is **operational** end-to-end for the core path:

```
Social action (like / comment / follow / …)
  → Postgres trigger → public.notifications
  → (optional) pg_net → Edge Function send-push → FCM
  → Flutter: list + badge + deep link
```

| Layer | What exists |
|-------|-------------|
| **DB** | `notifications`, triggers, `create_notification`, `device_tokens`, `notify_send_push` |
| **Edge** | `supabase/functions/send-push` (FCM HTTP v1) |
| **App** | List, mark read/all, dismiss, deep links, FCM service, token lifecycle, settings master toggle |

**Completed work is catalogued in [STATUS.md](STATUS.md).** This file focuses on **gaps and remaining improvements**.

---

## 2. Analysis of gaps

### 2.1 In-app live updates (planned, not coded)

| Gap | Detail |
|-----|--------|
| **No Supabase Realtime** | No `channel` / `onPostgresChanges` in `lib/`. Badge/list do not update when a row is inserted unless the user refreshes or a **foreground FCM** message arrives. |
| **Unread count not using RPC** | DB has `get_unread_notification_count(uuid)`; app still does `select id where is_read = false` and counts client-side. |

### 2.2 Settings honesty

| Gap | Detail |
|-----|--------|
| **Type toggles are local-only** | Followers / Likes / Dislikes / Comments / Replies stored in SharedPreferences; **not** applied by Edge Function or list queries. |
| **Master push toggle** | Works (starts/stops FCM + token). Sub-toggles do not change delivery. |

### 2.3 Platform / ops

| Gap | Detail |
|-----|--------|
| **iOS config** | Ensure `GoogleService-Info.plist` + APNs key if shipping iOS push. |
| **Secrets / vault** | Production needs `FIREBASE_*`, `PUSH_WEBHOOK_SECRET`, Vault `push_webhook_secret` — verify in each environment. |
| **Soft-ask UX** | System permission is requested in `NotificationService.start`; no pre-permission education sheet. |

### 2.4 Product / UX polish

| Gap | Detail |
|-----|--------|
| Badge is **dot-only**, not numeric | `unreadCountProvider` returns a number but UI shows an 8px dot. |
| List **hard limit 50** | No pagination / “load more”. |
| No **grouping** | Each like is a separate row. |
| No **undo** on swipe-delete | Immediate delete. |
| Web Push table unused | `push_subscriptions` remains legacy; intentionally not used. |

### 2.5 Security / hygiene (improvement, not blockers)

| Gap | Detail |
|-----|--------|
| Stale FCM tokens | Edge function can collect invalid tokens; confirm cleanup path is complete. |
| Preference enforcement at send time | Without server prefs, all tokens get all types. |

---

## 3. Remaining work (prioritized backlog)

### P0 — Production verification (ops, not new features)

- [ ] Confirm Edge Function `send-push` is **deployed** on Entangl (`lmohyfcmiftvuluhyaqh`).
- [ ] Confirm secrets: `FIREBASE_PROJECT_ID`, `FIREBASE_SERVICE_ACCOUNT_JSON`, `PUSH_WEBHOOK_SECRET`.
- [ ] Confirm Vault secret name `push_webhook_secret` matches trigger.
- [ ] E2E Android: like as User A → User B receives system notification → tap opens correct deep link.
- [ ] Add / verify **iOS** Firebase config + APNs key if iOS push is required.
- [ ] Smoke test: insert notification with no tokens → `{"sent":0,"reason":"no_tokens"}`.

### P1 — Planned in-app improvements (code)

| ID | Task | Effort | Notes |
|----|------|--------|-------|
| N-1 | Use **`get_unread_notification_count`** for badge | S | Replace client-side list count |
| N-2 | **Realtime** subscription on `notifications` (INSERT/UPDATE for `user_id = me`) | M | Invalidate/refresh list + badge without FCM |
| N-3 | Ensure Realtime is **enabled** for `public.notifications` in dashboard | S | Config only |

### P2 — Settings & preference integrity

| ID | Task | Effort | Notes |
|----|------|--------|-------|
| N-4 | **Either** hide type sub-toggles **or** store prefs server-side and filter in `send-push` | M | Avoid false UX |
| N-5 | Soft-ask permission UI before system dialog | S–M | Product copy + once-per-install |
| N-6 | Optional: per-type mute only for **push** (list still shows all) | M | Product decision |

### P3 — UX enhancements

| ID | Task | Effort |
|----|------|--------|
| N-7 | Numeric badge when count > 0 (cap at 9+) | S |
| N-8 | Paginate notifications (cursor / range) | M |
| N-9 | Undo toast on swipe-delete | S |
| N-10 | Highlight target comment when opening from reply | M |
| N-11 | Empty-state CTA (e.g. explore / create) | S |

### Explicitly deferred / out of scope

| Item | Reason |
|------|--------|
| Web Push / `push_subscriptions` client | Skipped by product decision |
| Block / report / mute | Skipped |
| Grouped notifications | Phase 4+ product design |
| Feed Realtime (posts) | Separate from notification module |

---

## 4. Detailed improvements to implement

### 4.1 RPC unread count

**File:** `lib/data/repositories/notifications_repository.dart`

```dart
// Target behavior
Future<int> getUnreadCount() async {
  final uid = SupabaseService.currentUserId;
  if (uid == null) return 0;
  final res = await _db.rpc(
    'get_unread_notification_count',
    params: {'p_user_id': uid},
  );
  return (res as num?)?.toInt() ?? 0;
}
```

**Acceptance:** Badge matches DB; network payload is a single integer.

### 4.2 Supabase Realtime

**Suggested approach:**

1. Provider (e.g. `notificationsRealtimeProvider`) watches session.
2. Subscribe: `postgres_changes` on `public.notifications`, filter `user_id=eq.<uid>`.
3. On INSERT/UPDATE/DELETE: `ref.invalidate(unreadCountProvider)` + `notificationsProvider.notifier.refresh()` (or append optimistically).
4. Dispose channel on logout / provider dispose.

**Acceptance:** With app open on Home (no FCM required for this path), a new like from another device updates the bell without manual refresh.

### 4.3 Settings sub-toggles

**Option A (fast):** Remove or disable sub-toggles until server-backed.  
**Option B (complete):**

1. Columns or JSON on `profiles` / `notification_prefs` table.  
2. Flutter syncs on toggle.  
3. `send-push` reads prefs and skips disallowed types.  

**Acceptance:** Turning off “Likes” stops FCM for likes; list behavior is defined in product copy.

### 4.4 iOS readiness

1. FlutterFire configure → commit `GoogleService-Info.plist` if missing.  
2. Upload APNs key in Firebase.  
3. Test background/terminated tap → deep link.

### 4.5 Soft-ask permission

Flow: first meaningful moment (e.g. after first follow received, or Settings open) → modal explaining value → “Enable” → `requestPermission`.

---

## 5. Acceptance criteria for “Notification module complete”

| Criterion | Status |
|-----------|--------|
| Social actions create rows (triggers) | Done |
| In-app list + mark read + dismiss | Done |
| Deep link by type | Done |
| FCM register token + logout cleanup | Done (code) |
| FCM delivery E2E on Android | Verify ops |
| FCM on iOS | Pending config |
| Realtime badge without pull | **Pending** |
| RPC unread count | **Pending** |
| Type prefs enforce delivery | **Pending** |
| Web push | Skipped |
| Block/report | Skipped |

---

## 6. Suggested implementation order

1. Ops E2E verify (P0)  
2. N-1 RPC count  
3. N-2 + N-3 Realtime  
4. N-4 settings honesty  
5. iOS + soft-ask (if shipping iOS push)  
6. N-7–N-11 polish as needed  

---

## 7. File map (for implementers)

| Path | Role |
|------|------|
| `lib/data/repositories/notifications_repository.dart` | Fetch / mark / delete / **RPC count** |
| `lib/features/notifications/providers/notifications_provider.dart` | List + unread providers; **Realtime hook** |
| `lib/features/notifications/providers/push_bootstrap_provider.dart` | FCM lifecycle |
| `lib/data/services/notification_service.dart` | FCM + local notifs |
| `lib/data/repositories/device_tokens_repository.dart` | Token CRUD |
| `lib/features/notifications/utils/notification_navigation.dart` | Deep links |
| `lib/features/settings/providers/settings_provider.dart` | Local prefs |
| `supabase/functions/send-push/index.ts` | FCM send |
| `supabase/migrations/20260717153000_device_tokens.sql` | Tokens schema |
| `supabase/migrations/20260717154500_notify_send_push.sql` | Trigger → function |

---

*End of pending-work document.*
