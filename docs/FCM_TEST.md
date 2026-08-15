# FCM test guide (Entangl)

Firebase project: **entangl** (`entangl-c11b2`)

## 1. One-time Supabase setup

In the Supabase SQL editor, run:

```text
supabase/device_tokens.sql
```

This stores device tokens so a future Edge Function can send targeted pushes.

## 2. Run the app on a real device

```bash
flutter run
```

- **Android:** physical device or emulator with Google Play.
- **iOS:** physical device (simulator is unreliable for remote push). Upload an APNs key under Firebase Console → Project settings → Cloud Messaging if you have not already.

## 3. Enable push in the app

1. Sign in.
2. Open **Settings**.
3. Turn **Push Notifications** ON (grants OS permission + registers token).
4. In **debug** builds only: tap **Copy FCM Token (debug)** and paste somewhere safe.

You will also see logs like:

```text
[FCM] token registered (dXyz…)
```

## 4. Send a test message from Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/) → project **entangl**.
2. Go to **Messaging** (Engage → Messaging).
3. **Create your first campaign** / **New campaign** → **Firebase Notification messages**.
4. Title / body example:
   - Title: `Entangl`
   - Body: `Test push from Firebase Console`
5. Under **Send test message**, paste the FCM token from step 3.
6. Click **Test**.

### Optional data payload (deep link)

In the message **Additional options** → custom data:

| Key | Value |
|-----|--------|
| `route` | `/notifications` |

Tapping the notification opens the in-app notifications screen when the app handles the open event.

## 5. What to expect

| App state | Expected behavior |
|-----------|-------------------|
| Foreground | Android shows a local banner; iOS can present via system options |
| Background | System tray notification |
| Terminated | Notification; tap opens app → notifications route |

## 6. Troubleshooting

| Issue | Fix |
|-------|-----|
| No token | Enable push toggle; use a real device; check Google Play services (Android) |
| iOS no delivery | APNs key in Firebase; Push capability + development provisioning |
| Token upsert fails silently | Run `device_tokens.sql` and confirm RLS policies |
| Wrong project | Confirm package `com.entangl.entangl_app` / bundle `com.entangl.entanglApp` under project `entangl-c11b2` |

## 7. Production sending (next step)

Console test messages prove client integration. Production likes/follows/comments still need a **server sender** (e.g. Supabase Edge Function using FCM HTTP v1) that:

1. Reads the target user’s rows from `device_tokens`
2. Calls FCM with the notification payload
3. Optionally writes the in-app `notifications` table row
