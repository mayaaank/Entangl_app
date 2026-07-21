# Design system (living)

**Last updated:** 2026-07-18  
**Source of truth in code:** `lib/core/theme/`  
**Reference:** Stitch project paper-doodle social (local `.stitch/DESIGN.md` may exist untracked)

---

## Vision

Playful, warm **paper-doodle social** — cream sketchbook backgrounds, thick ink outlines, soft pastel action chips. Handmade and friendly, not neon/tech glassmorphism.

---

## Colors

Primary tokens in `AppColors` (`lib/core/theme/app_colors.dart`).

| Role | Token / hex | Usage |
|------|-------------|--------|
| Paper scaffold | `inkBase` `#FDF8F0` | Main background (name historical) |
| Card white | `paperSage` / `inkMid` `#FFFFFF` | Cards, sheets, nav fill |
| Muted paper | `inkWarm` `#F3EBE0` | Pressed / muted |
| Grid canvas | `paperGrid` `#FAF4EA` | Create post doodle area |
| Ink outline | `borderCard` / `strokeInk` `#1A1610` | 2px borders |
| Text primary | `textPrimary` `#1A1610` | Titles, body |
| Text secondary | `textSecondary` `#6B6560` | Meta, handles |
| Yellow CTA | `cream100` `#F0C84A` | Primary buttons, create FAB |
| CTA pressed | `cream80` `#E8B82E` | Pressed yellow |
| Pastel pink | `pastelPink` `#FFB6C8` | Like chip |
| Pastel mint | `pastelMint` `#A8E6CF` | Comment chip |
| Pastel blue | `pastelBlue` `#A8D4F0` | Share / message |
| Pastel yellow | `pastelYellow` `#F5E08A` | Bookmark-style chip |
| Like semantic | `like` `#E86B8A` | Heart accent |
| Dislike | `dislike` `#C4714A` | Destructive / dislike |

Shadows: `shadowCard`, `shadowDoodle`, `shadowFloat` — soft paper depth, not heavy Material elevation.

---

## Typography

`AppTextStyles` — Google Fonts:

| Role | Family | Weight |
|------|--------|--------|
| Display / brand / titles | **Fredoka** | 600 |
| Body / labels | **Nunito** | 500–800 |

Scale includes `displayXl`…`displayMd`, `title1`/`title2`, `subtitle`, `bodyLarge`/`bodyMedium`/`bodySmall`, and smaller meta styles.

---

## Spacing & shape

- Card radius ~20–24 (post cards ~22)
- Pill / nav radius ~999
- Page horizontal padding common at 16
- Ink border width **2px** on primary cards and floating nav
- Soft margins between feed cards vertical ~8

---

## Components (guidelines)

### Post card (`PostCard`)

- White fill, ink outline, doodle shadow
- Header: avatar + username + time
- Media: `DynamicPostImage` (natural aspect, clamped)
- Actions: pastel rounded chips (like / comment / etc.)

### Navigation (`EntanglNavBar`)

- Floating pill, white fill, 2px ink border
- Destinations: Home · Search · Create(+) · Notifications · Profile
- Create: solid yellow circle with ink ring

### Buttons (`GradientButton` and cream CTAs)

- Prefer solid yellow cream tokens over neon gradients for primary actions in the paper system
- Dark text on yellow (`textOnCream`)

### Auth fields

- Paper input fills (`paperAsh`), ink borders, rounded friendly geometry

### Stories row

- Pastel ring colors; “Your story” first with add affordance

### Profile header

- Large avatar with ink ring; stats strip; dual CTAs (e.g. Following yellow / Message blue)

### Skeletons (`FeedSkeleton`)

- Match light paper cards so loading feels on-brand

---

## Animations

- Micro-interactions ~150–300ms
- Elastic scale on CTA press where used
- Respect `MediaQuery.disableAnimations` / reduced motion

---

## Icons

- Material rounded / outlined pairs on nav
- Avoid emoji-as-icons for core chrome
- Mascots (frog/ghost) remain brand accents, not required on every chrome piece

---

## Responsive / layout

- Mobile-first phone layouts; horizontal padding 16
- Feed images clamp aspect so portrait does not dominate the viewport
- Bottom nav accounts for safe area inset

---

## Accessibility

- Maintain contrast: dark ink on cream/white
- Do not rely on color alone for reaction state when possible (icons + color)
- Future: full VoiceOver/TalkBack audit (roadmap)

---

## Theme modes

| Mode | Status |
|------|--------|
| Light (paper-doodle) | **Default** (`ThemeMode.light`) |
| Dark | Available (`AppTheme.dark`) for immersive overlays; may need parity pass |

---

## Anti-patterns

- Glassmorphism / heavy blur as default chrome
- Neon gradients as primary brand
- Random hex colors outside tokens
- Cropping all feed images to a fixed square when natural aspect is preferred

---

## History log

| Date | Change |
|------|--------|
| 2026-07-18 | Initial design-system.md from paper-doodle token + component rollout |
