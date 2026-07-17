# Push Notifications (FCM + Supabase)

**Last updated:** 2026-07-18  
**Status overview:** [STATUS.md](STATUS.md)  
**Pending work:** [PENDING.md](PENDING.md)  
**Docs index:** [../README.md](../README.md)

Entangl uses **Supabase** for auth, DB, in-app notification rows, and **Firebase Cloud Messaging** only for **mobile** device push delivery. **Web Push is skipped** (table `push_subscriptions` is legacy / unused by the Flutter app).

## Architecture

```
Like / comment / follow / …
        → DB trigger → public.notifications
        → Database Webhook → Edge Function send-push
        → device_tokens → FCM HTTP v1
        → Android / iOS
```

## Flutter client

| Piece | Location |
|-------|----------|
| FCM + local notifs | `lib/data/services/notification_service.dart` |
| Token CRUD | `lib/data/repositories/device_tokens_repository.dart` |
| Auth / settings bind | `lib/features/notifications/providers/push_bootstrap_provider.dart` |
| Init order | `lib/main.dart` — Firebase → background handler → local notifs → Supabase |
| Logout cleanup | `AuthNotifier.signOut` unregisters token before session ends |

## Database

Migration: `supabase/migrations/20260717153000_device_tokens.sql`

```bash
# Apply to linked remote project
supabase db push
```

## Edge Function deploy (already done for Entangl)

```bash
# From repo root
supabase functions deploy send-push --no-verify-jwt

# Secrets (set once)
supabase secrets set FIREBASE_PROJECT_ID=entangl-c11b2
supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat .secrets/firebase-service-account.json)"
supabase secrets set PUSH_WEBHOOK_SECRET="<random hex>"

# Vault secret for DB trigger (name must match)
# select vault.create_secret('<same secret>', 'push_webhook_secret', 'send-push webhook');
```

`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are injected automatically for Edge Functions.

## DB → Edge Function (pg_net trigger)

Not a Dashboard Webhook. Production uses:

- Extension: `pg_net`
- Function: `public.notify_send_push()` (SECURITY DEFINER)
- Trigger: `on_notification_send_push` **AFTER INSERT** on `public.notifications`
- Auth: header `x-webhook-secret` from Vault secret `push_webhook_secret`

Migration: `supabase/migrations/20260717154500_notify_send_push.sql`

Smoke test:

```bash
curl -i -X POST \
  'https://lmohyfcmiftvuluhyaqh.supabase.co/functions/v1/send-push' \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $PUSH_WEBHOOK_SECRET" \
  -d '{"user_id":"<uuid>","actor_id":"<uuid>","type":"like","id":"<uuid>"}'
# Expect: {"sent":0,"reason":"no_tokens"} if user has no device_tokens row
# Expect: 401 without the secret header
```

## Android

- Google Services plugin applied in `android/app/build.gradle.kts`
- `POST_NOTIFICATIONS` + default channel `entangl_push` in `AndroidManifest.xml`
- `google-services.json` present

## iOS

- `UIBackgroundModes` → `remote-notification` in `Info.plist` (if configured)
- `Runner.entitlements` with `aps-environment` = `development` (switch to `production` for App Store builds)
- **Required manually:** upload APNs Auth Key (.p8) in Firebase Console → Project settings → Cloud Messaging
- **Gap (as of 2026-07-18):** `ios/Runner/GoogleService-Info.plist` is **not** present in the repo tree — add via FlutterFire CLI before shipping iOS push

## Payload contract

```json
{
  "type": "like|dislike|comment|reply|follow",
  "notification_id": "<uuid>",
  "actor_id": "<uuid>",
  "post_id": "",
  "comment_id": "",
  "user_id": "<uuid>",
  "title": "…",
  "body": "…"
}
```

## Manual test checklist

1. Login on device → row appears in `device_tokens`
2. Logout → row removed
3. Toggle Push off in Settings → token removed; toggle on → re-registered
4. Trigger a like from another account → tray notification + in-app list
5. Tap notification → profile / post / comments sheet as appropriate

## Test invoke (without webhook)

```bash
curl -i -X POST \
  'https://lmohyfcmiftvuluhyaqh.supabase.co/functions/v1/send-push' \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "00000000-0000-0000-0000-000000000001",
    "user_id": "<recipient-uuid>",
    "actor_id": "<actor-uuid>",
    "type": "like",
    "post_id": "<post-uuid>"
  }'
```
