# Entangl documentation

Central index for living context, product docs, architecture, UX, and notifications.

**Last organized:** 2026-07-18

---

## Living knowledge base (update every session when relevant)

Root + short living docs (preferred for onboarding a new coding session):

| File | Role |
|------|------|
| [../GROK.md](../GROK.md) | Permanent engineering knowledge |
| [../PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) | Current work context |
| [../TODO.md](../TODO.md) | Task tracker |
| [architecture.md](architecture.md) | Architecture living summary |
| [design-system.md](design-system.md) | Design tokens & UI rules |
| [roadmap.md](roadmap.md) | Milestones |
| [content.md](content.md) | Brand & copy |

---

## Layout

```text
docs/
├── README.md                 ← you are here
├── architecture.md           ← living architecture
├── design-system.md          ← living design system
├── roadmap.md                ← living roadmap
├── content.md                ← brand / copy
├── DOCUMENTATION.md          ← full product + technical suite
├── architecture/
│   ├── FOLDER_STRUCTURE.md   ← feature-first architecture map
│   └── ARCHITECTURE_AUDIT.md ← review of proposed vs as-built architecture
├── ux/
│   └── UI_UX_AUDIT.md        ← UI/UX audit + phase roadmap status
└── notifications/
    ├── STATUS.md             ← what is implemented today
    ├── PENDING.md            ← gaps and improvement backlog
    └── PUSH.md               ← FCM deploy, secrets, smoke tests
```

---

## Start here

| Goal | Read |
|------|------|
| New AI / human session | [../GROK.md](../GROK.md) → [../PROJECT_CONTEXT.md](../PROJECT_CONTEXT.md) |
| Understand the whole app | [DOCUMENTATION.md](DOCUMENTATION.md) |
| Architecture (short) | [architecture.md](architecture.md) |
| Code layout & modules | [architecture/FOLDER_STRUCTURE.md](architecture/FOLDER_STRUCTURE.md) |
| Design tokens / UI rules | [design-system.md](design-system.md) |
| Roadmap | [roadmap.md](roadmap.md) |
| Notification system (current) | [notifications/STATUS.md](notifications/STATUS.md) |
| Notification work still open | [notifications/PENDING.md](notifications/PENDING.md) |
| Deploy / debug FCM push | [notifications/PUSH.md](notifications/PUSH.md) |
| UX phases & scores | [ux/UI_UX_AUDIT.md](ux/UI_UX_AUDIT.md) |
| Architecture review notes | [architecture/ARCHITECTURE_AUDIT.md](architecture/ARCHITECTURE_AUDIT.md) |

---

## Notifications (quick)

- **In-app inbox + deep links:** shipped  
- **Mobile FCM push:** implemented (ops/iOS verify)  
- **Web push:** skipped  
- **Realtime badge / RPC count:** pending → [notifications/PENDING.md](notifications/PENDING.md)

---

## Project root

Application entry and config live outside `docs/` (`lib/`, `supabase/`, `pubspec.yaml`).  
Root `README.md` is the short project intro; this folder holds detailed documentation.
