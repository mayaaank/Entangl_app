# GROK.md — Entangl permanent project knowledge

Living guide for AI coding sessions (Grok / Claude Code / Cursor).  
Prefer this file for **stable** conventions. Session status lives in `PROJECT_CONTEXT.md`.

**Product:** Entangl (Flutter social app)  
**Last permanent update:** 2026-07-18

---

## 1. Project overview

Entangl is a mobile-first social app: posts, stories, comments, reactions, profiles, search, settings, admin approval, and in-app + FCM notifications.

**Not a marketing website.** This repo is the Flutter app `entangl_app`.

---

## 2. Tech stack

| Layer | Choice |
|-------|--------|
| Client | Flutter / Dart (`sdk: >=3.0.0 <4.0.0`) |
| State | Riverpod (`flutter_riverpod`, notifiers) |
| Routing | GoRouter |
| Backend | Supabase (Auth, Postgres, Storage, RLS, Edge Functions) |
| Push | Firebase Cloud Messaging (mobile only; web push skipped) |
| Local notifs | `flutter_local_notifications` |
| Images | `cached_network_image`, `image_picker`, crop packages |
| Fonts | Google Fonts — **Fredoka** (display), **Nunito** (body) |
| Motion | `flutter_animate` where used; respect reduced-motion |

Secrets: `lib/core/secrets.dart` — never commit real keys.

---

## 3. Folder structure (code)

```text
lib/
├── main.dart
├── core/           # router, theme, constants, utils, secrets
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/   # SupabaseService, NotificationService
├── features/       # feature-first modules
│   ├── admin/
│   ├── auth/
│   ├── comments/
│   ├── feed/
│   ├── notifications/
│   ├── post/
│   ├── profile/
│   ├── search/
│   ├── settings/
│   └── stories/
└── shared/
    ├── providers/
    └── widgets/    # PostCard, nav, skeletons, avatars, etc.
supabase/
├── migrations/
└── functions/      # e.g. send-push
docs/               # long-form + living docs (see §7)
```

---

## 4. Architecture summary

- **Feature-first** + **repository pattern** + Riverpod. Not strict Clean Architecture (no use-case layer / ports).
- UI → providers/notifiers → repositories → Supabase client.
- Auth session drives GoRouter redirects; profile `status` gates approved users.
- Notifications: Postgres triggers → `notifications` rows → optional Edge Function `send-push` → FCM via `device_tokens`.
- Optimistic updates on feed reactions where implemented.

Detailed maps: `docs/architecture.md`, `docs/architecture/FOLDER_STRUCTURE.md`.

---

## 5. Coding conventions

1. **New features** go under `lib/features/<name>/` with `screens/`, `providers/`, `widgets/` as needed.
2. **Data access only in repositories** under `lib/data/repositories/` — avoid raw Supabase in widgets.
3. Prefer existing design tokens: `AppColors`, `AppTextStyles`, `AppTheme` — no one-off hex when a token exists.
4. **Visual language:** paper-doodle (cream paper, ink outlines, pastel chips). Default **light** theme; dark theme exists for overlays/immersive screens.
5. Keep commits conventional: `feat|fix|docs|chore|ref(scope): …` — imperative subject, no period.
6. **Do not** put `Co-Authored-By: Claude …` (or any AI co-author footer) in commit messages for this project.
7. Do not invent metrics or claim features that are not in code.
8. Prefer small, focused diffs; do not mass-rewrite unrelated docs or files.

---

## 6. Design system (quick)

| Token area | Implementation |
|------------|----------------|
| Colors | `lib/core/theme/app_colors.dart` |
| Type | `lib/core/theme/app_text_styles.dart` |
| Theme | `lib/core/theme/app_theme.dart` |
| Full guide | `docs/design-system.md` |

Key look: cream scaffold `#FDF8F0`, white cards, **2px** ink border `#1A1610`, yellow CTA `#F0C84A`, pastel action chips.

---

## 7. Documentation map

### Living context (update often / when relevant)

| File | Role |
|------|------|
| `GROK.md` | Permanent engineering knowledge (this file) |
| `PROJECT_CONTEXT.md` | Current sprint / status / next steps |
| `TODO.md` | Tasks, bugs, debt |
| `docs/architecture.md` | Architecture living summary |
| `docs/design-system.md` | Design tokens & UI rules |
| `docs/roadmap.md` | Milestones |
| `docs/content.md` | User-facing copy / brand voice |

### Deep reference (audits & ops — do not replace casually)

| Path | Role |
|------|------|
| `docs/README.md` | Docs index |
| `docs/DOCUMENTATION.md` | Full product/tech suite |
| `docs/architecture/*` | Folder map + architecture audit |
| `docs/ux/UI_UX_AUDIT.md` | UX audit & phases |
| `docs/notifications/*` | Push status / pending / ops |

---

## 8. End-of-day documentation workflow

When the user asks to wrap up the day:

1. Review session work and `git` status/diff.
2. Update only sections that changed in living docs.
3. Prefer append/patch over full rewrites.
4. Summarize which docs changed before finishing.

---

## 9. Development commands

```bash
flutter pub get
flutter run
flutter analyze
```

Push setup: `docs/notifications/PUSH.md`.

---

## 10. Explicit non-goals (current)

- Web Push API / browser push
- Block / report / mute (product skipped for now)
- Strict Clean Architecture rewrite
- Replacing Riverpod or Supabase without an explicit decision
