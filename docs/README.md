# Entangl documentation

Central index for product, architecture, UX, and notification docs.

**Last organized:** 2026-07-18

---

## Layout

```text
docs/
├── README.md                 ← you are here
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
| Understand the whole app | [DOCUMENTATION.md](DOCUMENTATION.md) |
| Code layout & modules | [architecture/FOLDER_STRUCTURE.md](architecture/FOLDER_STRUCTURE.md) |
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
Root `README.md` is the short project intro; this folder is the detailed documentation suite.
