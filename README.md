# Entangl

Flutter social app (posts, stories, comments, reactions, profiles) with **Supabase** (Auth, Postgres, Storage) and **FCM** for mobile push.

**Visual language:** paper-doodle — cream paper, ink outlines, pastel action chips (light theme default).

## Getting started

```bash
flutter pub get
# Copy secrets (gitignored): lib/core/secrets.dart from project template
flutter run
```

Requires Flutter SDK `>=3.0.0` and a configured Supabase project.  
For push setup, see [docs/notifications/PUSH.md](docs/notifications/PUSH.md).

---

## Documentation

### Living context (start here for any new session)

| File | Purpose |
|------|---------|
| [GROK.md](GROK.md) | Permanent stack, conventions, architecture rules |
| [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) | Current sprint, status, next priorities |
| [TODO.md](TODO.md) | Tasks, bugs, debt, future work |
| [docs/architecture.md](docs/architecture.md) | Living architecture summary |
| [docs/design-system.md](docs/design-system.md) | Colors, type, components, UI rules |
| [docs/roadmap.md](docs/roadmap.md) | Milestones and feature roadmap |
| [docs/content.md](docs/content.md) | Brand voice and in-app copy |

### Deep reference

Full index: [docs/README.md](docs/README.md)

| Area | Link |
|------|------|
| Product & technical suite | [docs/DOCUMENTATION.md](docs/DOCUMENTATION.md) |
| Architecture map | [docs/architecture/FOLDER_STRUCTURE.md](docs/architecture/FOLDER_STRUCTURE.md) |
| Architecture audit | [docs/architecture/ARCHITECTURE_AUDIT.md](docs/architecture/ARCHITECTURE_AUDIT.md) |
| Notifications (status) | [docs/notifications/STATUS.md](docs/notifications/STATUS.md) |
| Notifications (pending) | [docs/notifications/PENDING.md](docs/notifications/PENDING.md) |
| FCM push ops | [docs/notifications/PUSH.md](docs/notifications/PUSH.md) |
| UX audit | [docs/ux/UI_UX_AUDIT.md](docs/ux/UI_UX_AUDIT.md) |

---

## Project structure (code)

```text
lib/
  core/       theme, router, utils
  data/       models, repositories, services
  features/   feature-first modules
  shared/     cross-feature widgets
supabase/     migrations + Edge Functions
docs/         living + deep documentation
```

Agent/session rules: see [GROK.md](GROK.md).
