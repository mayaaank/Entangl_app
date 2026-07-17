# Entangl

Flutter social app (posts, stories, comments, reactions, profiles) with **Supabase** (Auth, Postgres, Storage) and **FCM** for mobile push.

## Documentation

All detailed docs live under [`docs/`](docs/README.md):

| Area | Link |
|------|------|
| Docs index | [docs/README.md](docs/README.md) |
| Product & technical suite | [docs/DOCUMENTATION.md](docs/DOCUMENTATION.md) |
| Architecture map | [docs/architecture/FOLDER_STRUCTURE.md](docs/architecture/FOLDER_STRUCTURE.md) |
| Architecture audit | [docs/architecture/ARCHITECTURE_AUDIT.md](docs/architecture/ARCHITECTURE_AUDIT.md) |
| Notifications (status) | [docs/notifications/STATUS.md](docs/notifications/STATUS.md) |
| Notifications (pending) | [docs/notifications/PENDING.md](docs/notifications/PENDING.md) |
| FCM push ops | [docs/notifications/PUSH.md](docs/notifications/PUSH.md) |
| UX audit | [docs/ux/UI_UX_AUDIT.md](docs/ux/UI_UX_AUDIT.md) |

## Getting started

```bash
flutter pub get
# Copy secrets (gitignored): lib/core/secrets.dart from project template
flutter run
```

Requires Flutter SDK `>=3.0.0` and a configured Supabase project.  
For push setup, see [docs/notifications/PUSH.md](docs/notifications/PUSH.md).
