# Activity push notifications (likes, follows, comments, new posts)

## Why campaigns work but activity does not

| Path | Who sends? | Status |
|------|------------|--------|
| Firebase Console campaign / test message | Firebase Console → FCM | Works (client is fine) |
| Like / follow / comment / new post | **Your backend** must create a notification + call FCM | Was missing after code loss |

The Flutter app only **receives** FCM and **stores** device tokens.  
It does **not** send pushes when someone posts. That was always a **Supabase** job.

```
Account B likes / follows / posts
        ↓
DB trigger inserts into `notifications`
        ↓
DB trigger → Edge Function `send-push`
        ↓
FCM HTTP v1 → Account A’s device token
        ↓
Phone shows push
```

---

## One-time setup (do these in order)

### 1. Run SQL in Supabase SQL Editor

Project: **Entangl** (`lmohyfcmiftvuluhyaqh`)

Run these files **in order**:

1. `supabase/sql/01_device_tokens.sql`
2. `supabase/sql/02_notification_triggers.sql`
3. Enable extension **pg_net** (Database → Extensions → search `pg_net` → Enable)
4. `supabase/sql/03_push_dispatch.sql`

### 2–4. Firebase service account + Edge Function (already on this project)

This Supabase project **already has**:

| Secret | Purpose |
|--------|---------|
| `FIREBASE_SERVICE_ACCOUNT_JSON` | FCM send credentials |
| `PUSH_WEBHOOK_SECRET` | Protects `send-push` |
| `FIREBASE_PROJECT_ID` | `entangl-c11b2` |

The Edge Function **`send-push` is deployed** (updated for activity pushes).

You only need to re-run SQL (step 1) and wire the DB webhook secret (step 5) if not already set.

If you ever recreate secrets:

```bash
cd /Users/mayaaaank/Developer/Entangl_app
supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat /path/to/service-account.json)"
supabase secrets set PUSH_WEBHOOK_SECRET="YOUR_RANDOM_SECRET"
supabase functions deploy send-push --project-ref lmohyfcmiftvuluhyaqh
```

### 5. Align the push secret in the database

In **Supabase Dashboard → Edge Functions → Secrets**, copy the value of `PUSH_WEBHOOK_SECRET`  
(or reset it to a new value you control).

Then in SQL Editor (same value):

```sql
-- Supabase blocks alter database for app.settings.*
-- Instead run supabase/sql/04_FIX_BACKGROUND_PUSH.sql which embeds the secret in the trigger function.
```

If `alter database` is blocked, open `supabase/sql/03_push_dispatch.sql` and put that secret in the `'x-push-secret'` header, then re-run that file.

### 6. App side (both accounts)

On **each** phone that should receive pushes:

1. Sign in  
2. Settings → **Push Notifications ON**  
3. Accept OS permission  
4. Confirm a row appears in Supabase table `device_tokens` for that user  

---

## How to test activity push

1. Account **A** and Account **B** both registered, push enabled, tokens in `device_tokens`
2. **A** follows **B** (or **B** follows **A** depending on who should be notified)
3. **B** creates a post  
   → **A** should get:
   - row in `notifications` (`type = new_post`)
   - FCM push: “X just posted something new”
4. **A** likes **B**’s post  
   → **B** gets like push
5. Check Edge Function logs: Supabase → Edge Functions → `send-push` → Logs

### Manual function test

```bash
curl -X POST 'https://lmohyfcmiftvuluhyaqh.supabase.co/functions/v1/send-push' \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -H "x-push-secret: YOUR_RANDOM_SECRET" \
  -d '{
    "record": {
      "id": "00000000-0000-0000-0000-000000000001",
      "user_id": "RECIPIENT_USER_UUID",
      "actor_id": "ACTOR_USER_UUID",
      "type": "like",
      "post_id": null,
      "comment_id": null
    }
  }'
```

---

## Troubleshooting

| Symptom | Check |
|---------|--------|
| Campaign works, activity doesn’t | Triggers / Edge Function / secrets not set |
| `notifications` row missing | Run `02_notification_triggers.sql`; check table/triggers exist |
| Row exists, no push | `device_tokens` empty for recipient; function secret mismatch; service account invalid |
| Function 401 | `PUSH_WEBHOOK_SECRET` ≠ `x-push-secret` from SQL |
| Function 500 FIREBASE_SERVICE_ACCOUNT | Secret not set or invalid JSON |
| FCM UNREGISTERED | App reinstalled; open app so token refreshes |
| New post no notify | Trigger only notifies **followers**; A must follow B |

---

## What was restored vs campaigns

- **Campaign** = you manually send from Firebase Console (always independent of Supabase).
- **Activity** = automatic pipeline above (lost with old backend pieces; restored by these SQL + Edge Function files).
