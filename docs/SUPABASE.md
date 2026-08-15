# Entangl — Supabase reference (what exists, what we changed, what it does)

**Last updated:** 2026-08-12  
**Purpose:** Baseline for restarting the app. Read this before wiping or re-integrating Firebase/FCM.

---

## 1. Project identity

| Item | Value |
|------|--------|
| **Supabase project name** | Entangl |
| **Project ref** | `lmohyfcmiftvuluhyaqh` |
| **API URL** | `https://lmohyfcmiftvuluhyaqh.supabase.co` |
| **Region** | South Asia (Mumbai) |
| **Linked from this repo** | Yes (`supabase link` → this ref) |
| **Auth / data / storage** | Supabase (primary backend) |
| **Push delivery** | Firebase Cloud Messaging (FCM), triggered from Supabase |

App secrets (anon key, etc.) live in `lib/core/secrets.dart` (gitignored). Do not commit keys.

---

## 2. Public tables (current inventory)

| Table | Role | Created by us this session? |
|-------|------|-----------------------------|
| `profiles` | Users (username, name, bio, avatar, **`fcm_token`**) | **No** (pre-existing). We **added** `fcm_token`. |
| `posts` | Feed posts | Pre-existing |
| `likes` / `dislikes` | Reactions | Pre-existing |
| `comments` | Comments / replies (`parent_id`) | Pre-existing |
| `follows` | Social graph | Pre-existing |
| `notifications` | In-app notification inbox | Pre-existing |
| `stories` / `story_views` / `story_likes` | Stories | Pre-existing |
| `device_tokens` | FCM tokens per user/device | **Yes / ensured** (may have existed from earlier work) |
| `push_subscriptions` | Present on remote (legacy/extra) | Pre-existing; not used by current Flutter FCM path |

### 2.1 `device_tokens` (push device registry)

| Column | Type | Meaning |
|--------|------|---------|
| `id` | uuid | PK |
| `user_id` | uuid | Owner (`auth.users` / profile) |
| `token` | text | FCM registration token |
| `platform` | text | `android` / `ios` / `web` / `unknown` |
| `created_at` / `updated_at` | timestamptz | Lifecycle |

- **RLS:** users can only select/insert/update/delete **their own** rows.  
- **Edge Functions** use the **service role** to read any user’s tokens when sending.  
- **What happens:** App calls upsert after login / push enabled → row appears → FCM can target that phone when app is closed.

### 2.2 `notifications` (in-app inbox)

| Column | Type | Meaning |
|--------|------|---------|
| `id` | uuid | PK |
| `user_id` | uuid | **Recipient** (who sees it) |
| `actor_id` | uuid | Who did the action |
| `type` | text | `follow`, `like`, `dislike`, `comment`, `reply`, `new_post` (and any legacy values) |
| `post_id` | uuid? | Related post |
| `comment_id` | uuid? | Related comment |
| `is_read` | bool | Read state |
| `created_at` | timestamptz | When created |

- **What happens:** Social actions insert rows (via DB triggers). App **reads** this table for the Notifications screen / badge.  
- This is **independent of FCM**: in-app list can work even if push fails.

### 2.3 `profiles.fcm_token` (backup)

| Change | Detail |
|--------|--------|
| **Added column** | `profiles.fcm_token text` |
| **Why** | Backup if `device_tokens` upsert fails; `activity-push` can also read this |
| **What happens** | On token register, app tries to update this column as well |

---

## 3. Database functions & triggers (behavior)

### 3.1 Creating in-app notifications

| Trigger | On table | Calls | What happens |
|---------|----------|-------|--------------|
| `trigger_notify_on_like` | `likes` INSERT | `notify_on_like` → `create_notification` | Post owner gets `type=like` |
| `trigger_notify_on_dislike` | `dislikes` INSERT | `notify_on_dislike` | Post owner gets `type=dislike` |
| `trigger_notify_on_comment` | `comments` INSERT | `notify_on_comment` | Post owner / reply parent get `comment` / `reply` |
| `trigger_notify_on_follow` | `follows` INSERT | `notify_on_follow` | Followed user gets `type=follow` |
| `trigger_notify_on_new_post` | `posts` INSERT | `notify_on_new_post` | **Each follower** gets `type=new_post` (**we added/restored this**) |

Core helper:

- **`create_notification(user_id, actor_id, type, post_id?, comment_id?)`**  
  - Skips if `user_id == actor_id` (no self-notify).  
  - Inserts into `public.notifications`.

**Result for product:** recipient sees the event in the **in-app** Notifications list (if they open the app / refresh).

### 3.2 Sending closed-app (system) push

| Trigger | On table | Function | What happens |
|---------|----------|----------|--------------|
| `on_notification_send_push` | `notifications` INSERT | `notify_send_push()` | HTTP POST to Edge Function `send-push` via `pg_net` |

`notify_send_push()`:

1. Reads secret from **Vault**: `push_webhook_secret`  
2. POSTs to  
   `https://lmohyfcmiftvuluhyaqh.supabase.co/functions/v1/send-push`  
3. Headers include `x-webhook-secret` / `x-push-secret` + Authorization (anon)  
4. Body: `{ type, table, record: <new notification row> }`  

**Result for product:** if recipient has a valid FCM token stored, they get a **system tray / lock-screen** notification even when the app is closed.

### 3.3 Changes we made to this pipeline

| Change | Why | Effect |
|--------|-----|--------|
| Ensured `device_tokens` + RLS | Store FCM tokens | Closed-app push can find devices |
| Added `profiles.fcm_token` | Backup token storage | More resilient registration |
| Synced Vault `push_webhook_secret` with Edge secret | Old header/secret mismatch → 401 | Push HTTP calls can authorize |
| Updated `notify_send_push` headers | Accept both secret header names | Compatible with old + new function |
| Dropped **duplicate** triggers (`trg_notify_*`, extra dispatch) | Double inserts / mixed 200+401 | Cleaner single path |
| Added/restored `trigger_notify_on_new_post` | “Someone I follow posted” | Followers get inbox (+ push if tokens OK) |
| Migration repair + `db pull` | Local/remote history mismatch | Local `supabase/migrations/` matches remote baseline |

### 3.4 What we should **not** use again without care

| Item | Note |
|------|------|
| `alter database ... app.settings.push_webhook_secret` | **Permission denied** on hosted Supabase |
| Hardcoding secrets in many SQL files | Prefer Vault + Edge secrets |
| Relying on **iOS Simulator** for FCM | Unreliable; use real devices |

---

## 4. Edge Functions (deployed)

| Function | Status | Who calls it | Auth | What it does |
|----------|--------|--------------|------|--------------|
| **`send-push`** | ACTIVE | DB trigger `notify_send_push` (and manual tests) | `PUSH_WEBHOOK_SECRET` via `x-push-secret` or `x-webhook-secret`, or service_role | Loads tokens for `record.user_id`, builds title/body from type + actor profile, sends **FCM HTTP v1** |
| **`activity-push`** | ACTIVE | Flutter app after like/comment/follow/post | User **JWT** (authenticated) | Same FCM send, but called from client so push doesn’t depend only on `pg_net` |

### Secrets (Edge Functions dashboard / CLI)

| Secret | Purpose |
|--------|---------|
| `FIREBASE_PROJECT_ID` | e.g. `entangl-c11b2` |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Google SA JSON for FCM API |
| `PUSH_WEBHOOK_SECRET` | Shared secret for `send-push` |
| `SUPABASE_*` | Auto-injected by platform |

### Vault (database)

| Secret name | Purpose |
|-------------|---------|
| `push_webhook_secret` | Used by `notify_send_push()` so DB can call `send-push` |

These two secrets (**Vault** + **Edge `PUSH_WEBHOOK_SECRET`**) must **match**.

---

## 5. End-to-end flows (what will happen)

### A) User B likes User A’s post

```
B inserts likes row
  → trigger_notify_on_like
  → create_notification(A, B, 'like', post_id)
  → row in notifications for A          ← in-app inbox
  → on_notification_send_push
  → send-push Edge Function
  → FCM to A’s device_tokens            ← system push if token exists
```

Also (current Flutter): B’s app may call **`activity-push`** as a second path.

### B) User B comments on A’s post

Same pattern with `type=comment` (and `reply` if `parent_id` set).

### C) User B follows A

`type=follow` notification for A + push if token exists.

### D) User B creates a post; A follows B

```
B inserts posts row
  → trigger_notify_on_new_post
  → create_notification for each follower (A, …) type=new_post
  → push dispatch per notification row
```

### E) Firebase Console campaign

```
Firebase Console → FCM → devices registered with Firebase
```

**Does not use** Supabase `device_tokens` or Edge Functions.  
Explains: campaign works on Android even when activity push was broken.

### F) In-app only (app open)

App reads `notifications` (and may use Realtime).  
Works without FCM. This is why “I see notifications in the app” while closed-app push failed.

---

## 6. Flutter app responsibilities (Supabase-related)

| Action | Table / API | When |
|--------|-------------|------|
| Sign up / sign in | Supabase Auth + `profiles` | Auth screens |
| Register FCM token | `device_tokens` upsert + optional `profiles.fcm_token` | Login / push ON / app resume |
| Read inbox | `notifications` select | Notifications screen |
| Mark read / delete | `notifications` update/delete | User actions |
| Social write | `posts`, `likes`, `comments`, `follows`, … | Features |
| Optional client push | Edge Function `activity-push` | After like/comment/follow/post |

---

## 7. SQL / files in this repo

| Path | Purpose |
|------|---------|
| `supabase/sql/01_device_tokens.sql` | Create `device_tokens` + RLS |
| `supabase/sql/02_notification_triggers.sql` | Alternate/extra trigger set (some superseded by remote originals) |
| `supabase/sql/03_push_dispatch.sql` | Template for push dispatch |
| `supabase/sql/04_FIX_BACKGROUND_PUSH.sql` | One-shot fix (may contain secrets; gitignored pattern) |
| `supabase/sql/05_profiles_fcm_token.sql` | Add `profiles.fcm_token` |
| `supabase/sql/00_RUN_ALL_ACTIVITY_PUSH.sql` | Combined install script (historical) |
| `supabase/functions/send-push/` | FCM sender (webhook/DB) |
| `supabase/functions/activity-push/` | FCM sender (authenticated client) |
| `supabase/migrations/20260812032928_remote_schema.sql` | Baseline schema after `db pull` |
| `docs/ACTIVITY_PUSH_SETUP.md` | Setup checklist |
| `docs/FCM_TEST.md` | Client FCM test notes |

---

## 8. CLI notes (for restart)

```bash
# Correct commands
supabase link              # select lmohyfcmiftvuluhyaqh
supabase db pull           # NOT "supabase pull"
supabase migration list
supabase db query --linked "select count(*) from device_tokens;"
supabase functions list
supabase functions deploy send-push
supabase functions deploy activity-push
supabase secrets list
```

**Migration history:** remote once had versions that local lacked; they were **repaired/reverted**, then a fresh pull created `20260812032928_remote_schema`. Do not re-run random repair unless you understand the impact.

---

## 9. Testing matrix (what to expect)

| Scenario | In-app row | System push |
|----------|------------|-------------|
| Android phone, push ON, token in `device_tokens`, someone comments | Yes | **Yes** (if FCM + secrets OK) |
| iPhone **Simulator** | Yes | **Usually no** (no real APNs/FCM) |
| Real iPhone, APNs configured in Firebase | Yes | Yes |
| Campaign from Firebase Console | N/A | Yes on registered real devices |
| No row in `device_tokens` for recipient | Yes | **No** (`sent: 0`) |

---

## 10. If you “start again” — minimum Supabase checklist

Keep the **remote** project; rebuild the Flutter app cleanly:

1. Confirm tables: `notifications`, `device_tokens`, `profiles.fcm_token`.  
2. Confirm triggers: like/comment/follow/dislike/new_post + `on_notification_send_push`.  
3. Confirm Edge Functions: `send-push`, `activity-push` deployed.  
4. Confirm secrets: Firebase SA JSON + matching Vault/Edge webhook secret.  
5. On each **real** test phone: login → Push ON → check `device_tokens`.  
6. Test with **two real devices** (not iOS Simulator as the only receiver).  
7. Optional: `flutter clean` locally anytime — does **not** change Supabase.

### Safe to drop later (only if you redesign push)

| Object | Impact if removed |
|--------|-------------------|
| `device_tokens` | Closed-app push breaks |
| `on_notification_send_push` / `notify_send_push` | DB-driven FCM stops (client `activity-push` may still work) |
| `activity-push` function | Client-driven FCM stops |
| `profiles.fcm_token` | Backup path only; app still prefers `device_tokens` |
| `trigger_notify_on_new_post` | Followers no longer get “new post” inbox rows |

### Do **not** drop without a full product rethink

`profiles`, `posts`, `likes`, `comments`, `follows`, `notifications`, `stories*`, Auth users.

---

## 11. Summary (one paragraph)

Supabase remains Entangl’s backend for auth, feed, social graph, and the **in-app** notification inbox. During this rebuild we **wired FCM device storage** (`device_tokens` + optional `profiles.fcm_token`), **kept/fixed server triggers** that insert `notifications` and call **`send-push`**, added/restored **new post → followers**, deployed **`activity-push`** as a client-side FCM path, and aligned **Vault + Edge secrets** so push HTTP calls authorize. In-app notifications mean the **table/trigger** path works; closed-app push also needs **tokens + FCM + real devices**. Local heavy downloads (NDK, Docker, `build/`) were tooling—not Supabase table requirements—and can be cleaned without deleting this remote setup.

---

*This file is the Supabase source of truth for restart. Prefer updating it when you change triggers, functions, or tables.*
