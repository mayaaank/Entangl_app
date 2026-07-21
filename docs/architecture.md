# Architecture (living summary)

**Last updated:** 2026-07-18  
**Product:** Entangl  
**Deep dives:** [architecture/FOLDER_STRUCTURE.md](architecture/FOLDER_STRUCTURE.md) · [architecture/ARCHITECTURE_AUDIT.md](architecture/ARCHITECTURE_AUDIT.md) · [DOCUMENTATION.md](DOCUMENTATION.md)

---

## System overview

```text
Flutter app (Riverpod + GoRouter)
        │
        ▼
Repositories (lib/data/repositories)
        │
        ▼
Supabase (Auth · Postgres/RLS · Storage · Edge Functions)
        │
        ├── notifications (in-app rows)
        └── send-push → FCM → device_tokens (mobile)
```

---

## Folder organization

| Path | Responsibility |
|------|----------------|
| `lib/core` | Router, theme, constants, lifecycle, secrets |
| `lib/data/models` | DTOs / domain-ish models |
| `lib/data/repositories` | All backend I/O |
| `lib/data/services` | Supabase wrapper, FCM NotificationService |
| `lib/features/*` | Screens, feature providers, feature widgets |
| `lib/shared` | Cross-feature widgets and app-wide providers |
| `supabase/migrations` | Schema, RLS, triggers |
| `supabase/functions` | Edge Functions (e.g. `send-push`) |

---

## Component hierarchy (client)

1. `main.dart` — Firebase + Supabase init, `ProviderScope`, `MaterialApp.router`
2. `AppTheme` light default (`ThemeMode.light`); dark available
3. `GoRouter` — auth redirects, shell routes for main tabs
4. Feature screens compose shared widgets (`PostCard`, `EntanglNavBar`, skeletons)
5. Providers own async state; repositories own queries/mutations

---

## Routing structure

Implemented in `lib/core/router/app_router.dart`.

- Unauthenticated → login / register / forgot password
- Authenticated but not approved → approval status
- Approved → home shell (feed, search, create, notifications, profile) + nested routes
- Admin routes for request review when authorized

---

## Data flow

### Feed post / reaction

`UI` → `feed_provider` (optimistic) → `posts_repository` → Supabase → (triggers may insert notification) → optional push

### Auth

`login/register UI` → `auth_provider` → `auth_repository` → Supabase Auth → session stream → router redirect

### Notifications

1. Social action writes trigger → `public.notifications`
2. Client: `notifications_repository` list/mark-read; badge from unread query (RPC not yet used)
3. Push path: insert trigger → `pg_net` / webhook → Edge `send-push` → FCM using `device_tokens`

---

## Design decisions (current)

| Decision | Rationale |
|----------|-----------|
| Feature-first folders | Scale features without a mono UI package |
| Repositories without interfaces | Pragmatic for app size; DIP optional later |
| Light paper-doodle default | Brand identity from Stitch; dark kept for immersive overlays |
| FCM mobile only | Web push out of scope |
| No Realtime on notifs yet | Ship inbox + FCM first; Realtime is backlog |

---

## Important implementation notes

- Prefer tokens in `AppColors` / `AppTextStyles` for UI work.
- `DynamicPostImage` preserves natural aspect with clamp for feed layout.
- Notification deep links: `lib/features/notifications/utils/notification_navigation.dart`.
- Push bootstrap: `push_bootstrap_provider` + `NotificationService`.

---

## History log

| Date | Change |
|------|--------|
| 2026-07-18 | Initial living architecture.md; paper-doodle UI default light; FCM path documented |
