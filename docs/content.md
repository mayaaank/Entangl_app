# Content & brand voice (living)

**Last updated:** 2026-07-18  
**Product:** Entangl (mobile app — not a marketing site)

This file tracks **user-facing copy**, brand naming, and tone.  
Website-only sections (portfolio, SEO landing pages) are N/A unless a web marketing surface is added later.

---

## Brand

| Item | Value |
|------|--------|
| Product name | **Entangl** |
| Former name | Connect (legacy strings may still appear in old docs/commits) |
| App title | `Entangl` (`MaterialApp.router` title) |
| Tone | Warm, playful, handmade sketchbook — friendly not corporate |
| Visual metaphor | Paper doodle, cream pages, ink outlines, soft pastels |

---

## Taglines / positioning (draft)

- Primary vibe: social that feels like a sketchbook, not a dashboard.
- Avoid: “enterprise”, “AI-powered”, hype metrics.

_(Formal marketing tagline not locked — update when product marketing is defined.)_

---

## In-app copy patterns

| Context | Guidance |
|---------|----------|
| Empty states | Short, encouraging; offer a clear next action (e.g. add story, create post) |
| Errors | Human language; map auth errors via `auth_errors` helpers where present |
| Destructive | Explicit confirm (“Delete post?” / cannot be undone) |
| Approval wait | Set expectations while account is pending |
| Notifications | Actor + action language; deep link to relevant content |

### Examples currently used / preferred

- Delete dialog: **Delete post?** / **This cannot be undone.**
- Nav labels: Home, Search, Create, Notifications, Profile
- Primary CTAs: Post, Following, solid yellow create control

---

## Screen-level notes

| Screen | Copy notes |
|--------|------------|
| Login / Register | Minimal form labels; clear validation messages |
| Approval status | Expectation-setting while waiting |
| Home feed | Brand title treatment in app bar; discovery section when applicable |
| Create post | Placeholder on grid canvas; tool labels (Photo, Camera, etc.) |
| Profile | Stats labels; Follow / Following / Message |
| Settings | Grouped sections with clear section titles |
| Notifications | Empty inbox friendly; error humanised |

---

## SEO / web

Not applicable for the Flutter app binary. If a public site is added later, document headlines, meta, and CTAs here.

---

## History log

| Date | Change |
|------|--------|
| 2026-07-18 | Initial content.md for Entangl brand + in-app voice |
