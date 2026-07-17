# Entangl — Comprehensive UI/UX Audit

**Role lens:** Senior Product Designer · UX Researcher · Mobile UI · Flutter Performance Consultant  
**Date:** 2026-07-11  
**Progress update:** 2026-07-18  
**Docs index:** [../README.md](../README.md)  
**Basis:** Live Flutter source (`lib/`), design tokens (`AppColors`, `AppTextStyles`, `AppTheme`), feature screens, and architecture context (feature-first, Riverpod, optimistic updates, Supabase, GoRouter).  
**Constraint:** Recommendations leverage the existing stack; they do not propose rewriting architecture.

> ### Implementation progress (2026-07-18)
>
> Several findings below have been **addressed** since the original audit. Treat remaining items as backlog, not “never done.”
>
> | Audit finding | Status |
> |---------------|--------|
> | Notification tap always → profile | **Fixed** — type-aware deep links |
> | Full-screen spinners / no skeletons | **Improved** — feed/profile/notif skeletons; non-destructive feed refresh |
> | No “Add story” when empty | **Fixed** |
> | Search no debounce / Material chrome | **Fixed** — custom search + 300ms debounce + recents |
> | No drafts | **Fixed** — local post drafts |
> | Long splash | **Improved** — adaptive splash |
> | No push | **Superseded** — mobile FCM + Edge Function (ops/iOS verify remain) |
> | Notification Realtime | **Still pending** — see [`../notifications/PENDING.md`](../notifications/PENDING.md) |
> | Type prefs only local | **Still pending** |
>
> Canonical notification docs: [`../notifications/STATUS.md`](../notifications/STATUS.md), [`../notifications/PENDING.md`](../notifications/PENDING.md). Docs index: [`../README.md`](../README.md).

---

## Executive Summary

Entangl has a **distinct, intentional visual identity** — warm ink surfaces, cream CTAs, botanical reaction colors, frog/ghost mascots, and elastic micro-interactions. That is rare for a social MVP and is a real brand asset.

What holds it back from feeling *flagship* is less “pretty pixels” and more **perceived performance, information architecture, and social workflow completeness**:

| Strength | Weakness |
|----------|----------|
| Cohesive dark “zine/ink” system | Dual visual languages (cream CTAs vs residual violet–pink gradient branding) |
| Optimistic likes/dislikes + haptics | Feed/profile/notifications still use full-screen spinners instead of skeletons |
| Story ring skeleton + pulse | Empty stories hide “Add story” entirely |
| Mascot empty/error states with personality | No true onboarding; approval wait is dead-end waiting |
| Floating pill nav with delight | Only 3 destinations; Search/Notifications/Settings buried |
| Good empty states on several screens | Notification taps go to **actor profile**, not the related post |
| Instant follow UI | Settings / admin poorly discoverable |
| Instant reaction spring | Image load uses spinner placeholders, not progressive/blur |

**Core thesis:** The app often *is* fast where it optimistically updates, but *feels* slower where loading, navigation, and discovery still force wait states or extra taps. Fixing **perceived speed + fewer taps to core social goals** will outperform another visual redesign.

---

## Scorecard

| Dimension | Score | Rationale |
|-----------|------:|-----------|
| **Overall UX** | **6.8 / 10** | Delightful brand moments; incomplete social IA and friction in auth gates / discovery |
| **UI polish** | **7.4 / 10** | Strong token system and card craft; residual inconsistency (gradients, Material Search, legacy light theme) |
| **Visual design** | **7.6 / 10** | Distinctive, premium-dark, playful; hierarchy sometimes competes with mascot decoration |
| **Accessibility** | **4.5 / 10** | Almost no Semantics; contrast mixed; tap targets uneven; motion not reduced |
| **Navigation** | **6.0 / 10** | Clear home/create/profile; weak “where is X?” for search/settings/admin/notifications |
| **Performance perception** | **6.2 / 10** | Optimistic reactions win; full-screen loaders and image spinners lose |

---

## 1. First Impression Audit

### What exists today

| Step | Behavior (as implemented) |
|------|---------------------------|
| Splash | ~2.5s animation (mascots + “entangl” whisper) → session + **approval status** check |
| Login | Card UI, doodles, Ghost mascot, cream CTA, forgot-password link |
| Register | Frog mascot reacts to username validation; routes to **approval status** on success |
| Approval | Pending/rejected hold screen; refresh + logout only |
| Home | Brand wordmark, stories, feed |

### Strengths

- Splash feels **branded**, not stock Flutter blue.
- Login/register invest in **atmosphere** (ink card, doodles, mascot personality).
- Register feedback loop (confused/sad/happy/jumping frog) is genuine delight and reduces form anxiety.
- Cream primary buttons + press scale + light haptic feel intentional and modern.

### Weaknesses

| Issue | Why it hurts |
|-------|----------------|
| **Forced ~2.5s splash** even with warm session | Feels artificial latency (Nielsen: “system status” should not invent delay) |
| **No onboarding** after approval | First home is cold; no “follow people / create first post” coach |
| **Approval gate as first real product moment** | Breaks excitement; trust drops when users cannot act |
| **Brand gradient reserved for splash treatment only** | Wordmark still uses `GradientText` on home — mixed story about brand language |
| **Register → approval**, not Home | Success emotion is replaced by waiting |
| First paint of feed can be **mascot + “Summoning posts…”** full remaining viewport | Not premium; Instagram shows skeleton feed |

### First 10 seconds verdict

| Criterion | Pass? |
|-----------|-------|
| Feels premium | Partially (visual yes; waiting no) |
| Communicates trust | Weak on approval; strong on form polish |
| Modern | Yes |
| Smooth | Splash delay + full-screen loaders hurt |
| Excitement | High on login art; drops on approval / empty social graph |

**Recommendation:** Reduce splash to ≤800ms when session exists; show skeleton feed immediately; after first approval, run a 3-step lightweight onboarding (avatar, 3 follows, first post).

---

## 2. Visual Design Audit

### Strengths

- **Named semantic palette** (`ink*`, `paper*`, `cream*`, reaction “inks”) is production-grade design systems thinking.
- Cards use warm olive (`paperSage`) not flat `#121212` — differentiation vs Threads/X pure black.
- Soft borders (`borderSubtle`) + dual soft shadows create tactile depth without neon glow spam.
- Stadium buttons, pill chips, 24px post radius feel contemporary.

### Weaknesses

| Issue | Detail |
|-------|--------|
| **Dual brand languages** | Zine cream CTAs vs violet→pink `brandGradient` still on wordmarks / legacy aliases |
| **Emoji ❤️** in reaction summary chip | Breaks icon system; feels temporary |
| **Material `SearchDelegate`** chrome | Default search app bar fights custom ink system |
| **Light theme defined but unused** | Dead design surface; risk of half-themed regressions |
| **Mascot overload risk** | Empty/error/loading all mascot-heavy — can feel toyish vs social platform |
| **Inline TextStyles** in `PostCard` | Bypass `AppTextStyles` — hierarchy drift |
| **Banner profile** is flat `inkWarm` block | Competes poorly with IG/LinkedIn cover language |

### Spacing / hierarchy

- Post card padding is generally good (16/14 rhythm).
- Short posts escalate to **displayMd ~18px** — good scanability; long posts drop to 15px body — good.
- Home header packs brand + search + bell + full stories into one floating app bar — dense but acceptable if stories always matter; when stories empty, **96px of dead header height still reserved** only if stories load empty as `SizedBox.shrink` inside fixed 96 box… actually empty data returns shrink *inside* fixed height container → **empty stories still cost 96px** of blank space. Major visual waste.

---

## 3. Color System Audit

### Current character

| Dimension | Assessment |
|-----------|------------|
| Premium | Yes — warm dark, cream actions |
| Playful | Yes — fern/terracotta/mauve reactions, mascots |
| Social | Moderate — less “Instagram neon”; more indie zine |
| Trustworthy | Cream on ink is clear; terracotta as *error* is softer than red (good emotionally, weaker urgency) |

### Contrast notes (approximate)

| Pair | Likely WCAG | Note |
|------|-------------|------|
| `textPrimary` on `inkBase` | Pass AA | Strong |
| `textSecondary` (#A89880) on `inkBase` | Borderline AA for small text | OK for secondary |
| `textTertiary` (#6B5F50) on `inkBase` | **Often fails AA** for 12px timestamps | Accessibility risk |
| `cream100` on `textOnCream` | Pass | Excellent CTA |
| `like` green on olive card | Moderate | Active chips OK; inactive icons rely on secondary |

### Recommendations

1. Keep ink/cream as brand spine — it is differentiated.
2. Raise timestamp/caption floor to ≥ `#8A7C6A` or 13–14px for AA.
3. Deprecate interactive use of violet–pink gradient; keep one brand mark only.
4. Define semantic **danger red** separate from dislike terracotta for destructive actions.
5. Document a single **surface ladder** table for designers/devs (already partially in comments — promote to design system doc).

---

## 4. Typography Audit

### Strengths

- Inter scale with tight display tracking (−1.92 / −1.2) feels modern.
- Comic Neue for doodle accent is intentional and on-brand.
- Clear roles: display / title / body / label / timestamp.

### Weaknesses

| Issue | Impact |
|-------|--------|
| **Button text at 13px** (`buttonLarge`/`buttonMedium` → labelMedium 13) | CTAs feel small vs 52px height — weak visual weight |
| **Hardcoded styles in PostCard header** | Drift from design system |
| **No dynamic type strategy** | Fixed sizes; large accessibility textScale may clip |
| **displayXl 48 / 32 on login** | Hero is strong; ensure one H1 per screen only |
| **Line length on feed** | Full width with 16px inset is fine; image-less short posts look great |

### Recommendations

- Primary CTA type → **15–16 / w700**.
- Ban ad-hoc `TextStyle(` in feature widgets; use tokens.
- Test `textScaleFactor` 1.3 and 1.5 on auth + feed.

---

## 5. Navigation Audit

### Structure

```
Bottom: Home | Create(+) | Profile
Header (Home): Brand | Search | Notifications
Profile: Edit / Logout / (admin for owner email)
Settings: buried via profile path / app bar patterns
Admin: /admin/requests (not in main IA)
```

### Strengths

- Floating pill nav is memorable and thumb-friendly.
- Create is center-weighted (correct for content apps).
- Safe-area bottom padding respected (`padding.bottom + 16`).
- Active mascot peek is delightful (optional reduce-motion needed).

### Weaknesses

| Issue | Heuristic |
|-------|-----------|
| **Users cannot answer “where is Search?”** without discovering header icon | Visibility of system status / match real world (IG puts search in tab or prominent) |
| **Notifications not a tab** | High-frequency social surface buried |
| **No settings in bottom IA** | Profile → Edit / Settings path is inconsistent |
| **Create uses `push` not modal sheet option** | Feels like a full page leave (OK) but no draft retention on back |
| **Other profile has custom back; own profile uses nav only** | Mental model split |
| **Admin only via special entry** | Fine if intentional; zero wayfinding for owners |
| **No “you are here” labels** on nav (icons only) | Discoverability for first-time users |

### Back / deep navigation

- GoRouter path profiles work.
- Story viewer uses imperative `Navigator.push` + fade — **escapes router stack** (deep link / system back edge cases).
- Comment sheet is modal (correct).

**Verdict:** Navigation is *pretty* but **not complete for a social app IA**. Score 6.0.

---

## 6. User Flow Audit & Friction Map

### 6.1 Authentication

```
Splash (2.5s)
  → Login / Register
    → (Register) Approval Status  ← FRICTION: cannot use product
    → (Login, unapproved) Approval Status
    → (Login, approved) Home
```

| Friction | Severity |
|----------|----------|
| Artificial splash delay | High (perceived) |
| Approval waiting with only “Check Again” | Critical for activation |
| No social login | Medium (expected in 2026) |
| No progressive profile setup | Medium |
| Login constructs repos directly (architecture smell) | Low UX direct; medium reliability |

### 6.2 Feed

```
Home → Stories row → Posts → Like/Dislike (optimistic) → Comment sheet → Profile → Back
```

| Friction | Severity |
|----------|----------|
| Initial full-screen loader | High perceived slow |
| Empty stories → blank 96px / or no “add story” when list empty | High |
| Infinite scroll bottom always shows spinner pad | Low–medium |
| Pull-to-refresh works but competes with large header displacement | Medium |
| No double-tap like on image | Medium (social expectation) |
| No share / save / repost | Medium missing |

### 6.3 Profile

```
Open → Stats → Follow (optimistic) → Tabs Posts/Followers/Following → Edit → Crop avatar → Save
```

| Friction | Severity |
|----------|----------|
| Full spinner on profile load | High |
| Tabs refetch / flash | Medium |
| Edit profile packs password + email change — cognitive overload | High |
| Logout on profile header (easy mis-tap near social actions) | Medium |

### 6.4 Story

```
Circle → Viewer (immersive) → Tap zones → Like → Next → Exit
Create: Home create / sheet → (optional editor) → Upload
```

| Friction | Severity |
|----------|----------|
| No persistent “Your story” when zero active stories | **Critical** for creation habit |
| Create story path split (sheet vs editor) | Medium complexity |
| 50MB client check good; no upload progress % beyond spinner | Medium |
| Viewers list owner-only — good; discovery of control is ⋮ menu | Low |

### 6.5 Notifications

```
Bell → List → Tap → Actor profile only
```

| Friction | Severity |
|----------|----------|
| **Does not deep-link to post/comment** | **Critical** for task completion |
| Staggered list animations on every open (60ms × i) | Medium perceived lag on long lists |
| Mark all read always visible (even if empty) | Low |
| No filter tabs (All / Mentions) | Medium vs IG/X |

### 6.6 Search

```
Icon → Material SearchDelegate → type → results → profile
```

| Friction | Severity |
|----------|----------|
| No debounce (every keystroke query) | Performance + jank risk |
| No recent searches / suggested users | High discovery miss |
| Visual style mismatch | Medium polish |

### 6.7 Create post

```
Nav + → form → optional image → mood stickers → Post → pop + invalidate
```

| Friction | Severity |
|----------|----------|
| No draft on accidental back | High |
| No camera capture for posts (gallery only per docs) | Medium |
| No progressive upload bar | Medium |
| Character counter good | — |

---

## 7. Perceived Performance Audit

> Backend latency ignored. This is about **what the UI makes users feel**.

### What already feels fast

| Pattern | Where | Why it works |
|---------|-------|--------------|
| Optimistic like/dislike + pending reconciliation | Feed | Instant feedback; spring + haptic |
| Optimistic follow + follower delta | Profile | Button state flips immediately |
| Optimistic story like | Stories | Same pattern |
| Story open fade 180ms | Story viewer | Snappy transition |
| Create button scale spring | Nav | Tactile |

### What feels slow or cheap

| Pattern | Where | User perception |
|---------|-------|-----------------|
| Full-viewport `CircularProgressIndicator` / mascot wait | Feed first load, profile, notifications, search, comments | “App is loading” instead of “content is coming” |
| Image placeholder = dark box + spinner | Post images | Layout jump when image arrives; no LQIP/blur |
| `refresh()` sets `AsyncLoading` wiping feed | Pull-to-refresh / hard refresh | **Content disappears** then reappears — classic anti-pattern |
| Notification item stagger animation | Notifications | Artificial delay before list feels ready |
| Splash fixed 2.5s | Launch | Fake wait |
| No skeleton for post cards | Feed | Blank until all or first page returns |
| Comments sheet spinner | Comments | Modal empty hole |
| Load-more footer spinner always at end | Feed | Suggests endless loading even when done |

### Priority perceived-speed fixes (architecture-friendly)

1. **Never set feed to full `AsyncLoading` on refresh** — keep previous `AsyncData`, overlay subtle top progress.
2. **Post card skeletons** (3–5 cards) matching `paperSage` radius — reuse stories shimmer technique.
3. **BlurHash / gray progressive** images instead of spinner (or `CachedNetworkImage` fade-in with fixed aspect ratio).
4. **Prefetch** next feed page when 50% scrolled (already 300px — good); prefetch story media on circle visible.
5. **Remove or cap** notification list stagger (max 3 items animated).
6. **Session splash ≤ 300–800ms** with content underlay.
7. **Comments:** show sheet chrome immediately; skeleton lines for comments.

These leverage existing Riverpod `AsyncValue` patterns and `flutter_animate` shimmer already used in stories.

---

## 8. Micro-interaction Audit

| Interaction | Quality | Notes |
|-------------|---------|-------|
| CTA press scale | Excellent | 0.96 → elasticOut + haptic |
| Nav create button | Excellent | Medium haptic |
| Like/dislike spring | Excellent | elasticOut 1.3× |
| Follow toggle | Good | Haptic medium/light |
| Story ring press scale | Good | 0.94 |
| Story ring pulse | Good | Reduce-motion missing |
| Comment submit | OK | Loading on send |
| Delete post dialog | Basic Material | Works; not branded deeply |
| Dismiss notification | Good | Standard dismissible |
| Search clear | Basic | Platform default |
| Error snackbars | OK | Humanised auth errors help trust |
| Success feedback | Sparse | Create post relies on navigation back |

### Gaps vs premium social apps

- No **double-tap heart** on media.
- No **hold-to-pause** clarity coaching on first story open.
- No **undo toast** after delete notification / unfollow.
- No **confetti / subtle particle** on first post (optional delight).
- Mascot animations always on — no `MediaQuery.disableAnimations` respect.

---

## 9. Information Architecture

### Content prioritization on Home

1. Brand  
2. Search / Notifications  
3. Stories  
4. Feed  

**Issue:** Stories get permanent real estate even when empty → wrong priority when graph is cold.  
**Issue:** Discovery (search) and activity (notifications) are secondary icons though they drive retention.

### Profile IA

Tabs Posts / Followers / Following is standard and correct.  
Edit profile mixing **identity + security + email admin workflow** is **too many jobs per screen** (violates single job per view).

### Mental model: Dislike

Dislike as first-class peer to Like is a product differentiator vs IG.  
**UX risk:** Users may interpret dislike as hostility; no education, no private “not interested” alternative. Worth onboarding tooltip.

---

## 10. Accessibility Audit

| Check | Status |
|-------|--------|
| Semantics / screen reader labels | **Largely missing** |
| Icon-only buttons (search, bell, nav) | No `tooltip` / `semanticLabel` in most places |
| Contrast tertiary text | **At risk** |
| Min tap target 44–48pt | Mixed (some chips ~ compact) |
| Dynamic type | Not designed |
| Keyboard / focus order on auth | Forms OK; custom GestureDetector buttons may skip focus |
| Reduced motion | **Not supported** |
| Color-only state (like green) | Partially mitigated by icon fill change |
| Image alt text | None |

**Accessibility score: 4.5 / 10**

### Minimum bar fixes

1. Wrap icon buttons with `Tooltip` + `Semantics(button: true, label: …)`.  
2. Ensure reaction chips min height 44.  
3. `prefers-reduced-motion` → disable pulse/float/stagger.  
4. Raise tertiary contrast.  
5. Announce optimistic errors via SnackBar (already) + optional Semantics live region.

---

## 11. Mobile UX / Ergonomics

| Area | Assessment |
|------|------------|
| Thumb zone | Bottom nav + create excellent |
| One-handed | Search/notif top-right hard on large phones |
| Safe areas | Generally respected |
| Keyboard | Auth scrollable; create post needs verify view insets |
| Bottom sheets | Comments use transparent + scroll controlled — good |
| Dialogs | Delete uses center dialog — OK; destructive confirm good |
| Floating nav occlusion | Feed `bottom: 120` padding in list — good; verify home sliver path same |
| Offline banner | 36px bottom — can collide with nav pill; risk of double bottom chrome |

**Recommendation:** Move high-frequency actions (search or activity) into thumb zone; stack offline banner above nav with padding awareness.

---

## 12. Social App Benchmark

| Area | IG | Threads | X | Reddit | BeReal | Snap | LinkedIn | Discord | **Entangl** |
|------|----|---------|---|--------|--------|------|----------|---------|-------------|
| Feed | ★★★★★ | ★★★★ | ★★★★★ | ★★★★ | ★★ | ★★ | ★★★★ | ★★★ | ★★★ (solid cards; weak ranking/chronology only) |
| Stories | ★★★★★ | — | — | — | ★★ | ★★★★★ | — | — | ★★★★ (viewer strong; creation entry weak when empty) |
| Comments | ★★★★ | ★★★★ | ★★★ | ★★★★★ | ★ | ★★ | ★★★ | ★★★★★ | ★★★ (threaded 1-level OK) |
| Profile | ★★★★★ | ★★★★ | ★★★★ | ★★★ | ★★ | ★★★ | ★★★★★ | ★★★★ | ★★★ |
| Navigation | ★★★★★ | ★★★★ | ★★★★ | ★★★★ | ★★★ | ★★★★ | ★★★★ | ★★★★★ | ★★★ |
| Discovery | ★★★★★ | ★★★ | ★★★★★ | ★★★★★ | ★ | ★★★ | ★★★★ | ★★★★ | ★★ (user search only) |
| Notifications | ★★★★★ | ★★★★ | ★★★★★ | ★★★★ | ★★ | ★★★ | ★★★★ | ★★★★★ | ★★ (list OK; deep link fail) |
| Posting | ★★★★★ | ★★★★ | ★★★★ | ★★★★ | ★★★ | ★★★★ | ★★★★ | ★★★ | ★★★ (stickers nice; drafts missing) |

### Where Entangl is **stronger**

- **Brand personality** (mascots, ink palette) vs sterile dark clones.  
- **Explicit dislike** as product stance.  
- **Story editor text overlays** (canvas export) beyond many MVP apps.  
- **Optimistic UI sophistication** (pending sets) beyond many indie apps.

### Where Entangl is **weaker**

- Discovery graph (no explore, topics, suggested follows).  
- Notification task completion.  
- Creation entry points for stories.  
- Feed ranking / following-only modes.  
- Media polish (aspect ratios, double-tap, video posts).  
- Accessibility and system integration (share sheets, widgets).

### Missing expected behaviors

Suggested follows, explore, hashtags/mentions autocomplete, repost/quote, bookmarks, mute/block, report, message/DM, push notification delivery UX, draft autosave, multi-image posts, video posts in feed, “interested/not interested”, activity on own post deep link, verified/admin badges, onboarding checklist.

---

## 13. Design System Consistency Report

### Inconsistencies found

| Area | Inconsistency |
|------|----------------|
| Brand name casing | `entangl` vs `Entangl` vs docs “Connect” |
| Primary action | Cream fill vs residual gradient text |
| Loading | Spinner vs stories shimmer vs mascot loader |
| Empty states | Mascot+copy vs icon circle (feed_list duplicate path) |
| Error UI | Mascot branded vs raw `Text('$e')` on notifications |
| App bars | Custom `EntanglAppBar` blur vs transparent profile AppBar vs Material search |
| Radius | 16 theme shape vs 24 cards vs 28 auth card vs 999 pills — OK if tokenized; **not tokenized** |
| Shadows | `shadowCard` / `shadowFloat` vs ad-hoc `Colors.black26` on profile avatar |
| Icons | Material rounded mix; emoji in reaction total |
| Typography | Token styles vs inline PostCard styles |
| Nav widget naming | Code `EntanglNavBar`; older docs `ConnectNavBar` |
| Light theme | Implemented in `AppTheme.light` but app forces dark |

### Scalable design system recommendation

Create `design_system.md` + Dart tokens:

```
Spacing: 4, 8, 12, 16, 20, 24, 32
Radius: r8, r16, r24, rPill
Elevation: e0, eCard, eFloat
Type: display / title / body / label / monoCaption
Component catalog: ButtonPrimary, ButtonGhost, IconButton, PostCard, ListTileUser, Skeleton*
```

Enforce via shared widgets only — matches feature-first already.

---

## 14. Workflow Audit (Tap Reduction)

### Create Post

**Current:** Home → Create tab → type/caption → (optional) pick image → Post → back  

**Can reduce?**

- Long-press Create → “Post” vs “Story” action sheet (saves later confusion).  
- Keep full screen composer (OK for focus).  
- **Autosave draft** reduces failed completions more than removing a tap.

### Story

**Current:** Often multi-step; **if no stories, entry may be invisible**  

**Must fix:** Always show “Your story” + cell even when empty (1 tap to create).

### Comment

**Current:** Chip → sheet → type → send  

**OK.** Add @ reply prefill (already) — good.  
Reduce: swipe from post to open comments (gesture power user).

### Follow

**Current:** Profile → Follow  

**OK** with optimistic UI.  
Reduce: Follow from search result row (inline button) — saves open profile.

### Search

**Current:** Header icon → type  

**Improve:** Recent + suggested without query (0 taps to value).

### Notifications

**Current:** Bell → tap → wrong destination (profile)  

**Critical path fix:** Tap → post/comments sheet. **Doesn’t reduce taps — makes taps worthwhile.**

### Edit profile

**Current:** Profile → Edit → fields → Save; password/email same surface  

**Split:** Edit Profile | Security | Email request — fewer fields per task, faster completion.

---

## 15. Missing UX Features (Modern Social Baseline)

| Feature | Priority |
|---------|----------|
| Skeleton loaders on feed/profile/notifications | Critical |
| Always-visible “Add story” | Critical |
| Notification → content deep link | Critical |
| Search debounce + recents | High |
| Draft posts | High |
| Undo unfollow / undo delete notification | High |
| Offline-aware empty actions (queue) | High |
| Suggested users / empty-graph onboarding | High |
| Reduce motion | High (a11y) |
| Share sheet / copy link | Medium |
| Mute / block / report | Medium (trust & safety) |
| Push notification OS permission soft-ask | Medium |
| Progressive upload % | Medium |
| Multi-photo posts | Medium |
| Bookmarks | Medium |
| Explore / topics | Phase 3–4 |
| DMs | Phase 4 |

---

## 16. Premium / Flagship Gap Analysis

What prevents “Instagram-class” feel:

1. **Content vanishes on refresh** (`AsyncLoading` wipe).  
2. **Spinners instead of skeletons**.  
3. ~~Broken notification task loop~~ **Fixed** (deep links). Residual: Realtime + numeric badge — see [`../notifications/PENDING.md`](../notifications/PENDING.md).  
4. **Cold-start social graph** with no guidance.  
5. **IA incomplete** (activity/discovery not first-class).  
6. **Media presentation** (no consistent aspect ratio, double-tap, scrub).  
7. **Accessibility neglect** (flagship apps are usable by more people).  
8. **Inconsistent chrome** (Material search vs custom ink).  
9. **Approval limbo** as primary post-signup experience.  
10. **Dual brand grammar** (gradient nostalgia vs cream system).

What already feels premium and should be protected:

- Ink/cream system  
- Optimistic social graph actions  
- Story viewer immersion  
- Mascot *empty states* (not loading states)  
- Nav create haptic craft  

---

# Deliverable Detail Sections

## Screen-by-Screen Audit

### Splash

| | |
|--|--|
| **Strengths** | Brand, motion, mascot pair, intentional pause aesthetic |
| **Weaknesses** | Fixed 2.5s; no progress of real work; approval logic hidden |
| **UX** | Artificial wait; no skip |
| **UI** | Strong |
| **Perf perception** | Poor if session already valid |
| **Recs** | Adaptive duration; show auth resolution status; skeleton of home under fade |

### Login

| | |
|--|--|
| **Strengths** | Card hierarchy, doodles, humanised errors, forgot password |
| **Weaknesses** | Decor can distract; email validation only non-empty (weak) |
| **UX** | Clear primary action |
| **UI** | High polish |
| **Perf** | Button loading state good |
| **Recs** | Stronger email format validation; optional biometric later |

### Register

| | |
|--|--|
| **Strengths** | Frog validation feedback = best-in-app delight |
| **Weaknesses** | Lands in approval purgatory |
| **UX** | Form length OK |
| **UI** | Strong |
| **Recs** | Set expectations *before* submit (“approval may take…”); email verification copy |

### Approval status

| | |
|--|--|
| **Strengths** | Honest status; refresh; logout |
| **Weaknesses** | Zero product value while waiting; anxiety |
| **UX** | Dead end |
| **Recs** | Estimated wait, support contact, limited “browse public” mode if product allows |

### Home / Feed

| | |
|--|--|
| **Strengths** | Floating header, pull-to-refresh, optimistic reactions, empty CTA, error retry with mascot |
| **Weaknesses** | Full-screen load; empty stories gap; header density |
| **Perf** | Refresh wipes list if using loading state; image spinners |
| **Recs** | Skeletons; keep previous data on refresh; collapse stories when empty except Add; fix load-more end state |

### Create post

| | |
|--|--|
| **Strengths** | Character ring, stickers, clear post affordance |
| **Weaknesses** | No draft; gallery-only; limited media UX |
| **Recs** | Draft local; camera; upload progress |

### Comments sheet

| | |
|--|--|
| **Strengths** | Threaded replies, reply banner, delete confirm |
| **Weaknesses** | Spinner-first; local comment count on card can desync from feed model |
| **Recs** | Skeleton; sync count into `PostModel` / feed notifier |

### Story row / viewer / editor

| | |
|--|--|
| **Strengths** | Skeleton row, pulse, immersive viewer, gestures, editor overlays (flagship-leaning) |
| **Weaknesses** | Empty → no create; editor complexity vs discoverability |
| **Recs** | Always “Your story”; first-run gesture coach marks |

### Notifications

| | |
|--|--|
| **Strengths** | Unread styling, dismiss, mark all, type icons, empty mascot |
| **Weaknesses** | Deep link wrong; error shows raw exception; stagger lag |
| **Recs** | Route by type+postId; branded error; remove long stagger |

### Search

| | |
|--|--|
| **Strengths** | Empty mascot guidance |
| **Weaknesses** | Material chrome; no debounce; no suggestions |
| **Recs** | Custom ink search page; debounce 300ms; recents |

### Profile (own / other)

| | |
|--|--|
| **Strengths** | Optimistic follow; stats; tabs; avatar hero potential |
| **Weaknesses** | Spinner load; flat banner; logout placement; edit overload |
| **Recs** | Skeleton header; richer banner; split settings |

### Settings

| | |
|--|--|
| **Strengths** | Clear sections; local toggles |
| **Weaknesses** | Push toggles may not bind to real push pipeline; privacy stub empty |
| **Recs** | Master push toggle is wired to FCM; **type** toggles still local-only — enforce server-side or hide ([PENDING.md](../notifications/PENDING.md)) |

### Admin requests

| | |
|--|--|
| **Strengths** | Clear tabs, badges, approve/reject |
| **Weaknesses** | Not in product IA; no confirmation on approve; loading per-row partial |
| **Recs** | Confirm destructive reject; role-gated entry in settings |

---

## Workflow Diagrams (Friction Highlighted)

### Activation

```
Install → Splash ⚠ delay → Register → ⚠ Approval wait → Home → ⚠ Empty graph → churn risk
```

### Core engagement loop

```
Home → Like ✔ instant → Comment ✔ → ⚠ Notif later opens Profile not Post → confusion
```

### Creation loop

```
Create Post ✔ → Publish ✔ → Feed invalidate
Stories: ⚠ if empty row hidden → user never learns stories exist
```

---

## UI Consistency Report (Checklist)

- [ ] Unify brand string & wordmark treatment  
- [ ] One loading language: skeleton primary, spinner only inline  
- [ ] One empty language: mascot + title + body + optional CTA  
- [ ] One error language: mascot/icon + human message + retry (never raw exception)  
- [ ] Tokenize radii & spacing  
- [ ] Replace emoji reaction summary with icon stack  
- [ ] Custom search screen matching ink system  
- [ ] Remove or quarantine light theme until productized  
- [ ] Standardize AppBar blur vs solid rules  

---

## Perceived Performance Report

| Moment | Feels | Why |
|--------|-------|-----|
| Cold launch | Slow | 2.5s splash + auth + approval + feed fetch serial feel |
| Feed first paint | Slow | Full remaining spinner/mascot |
| Like | Fast | Optimistic + haptic + spring |
| Follow | Fast | Optimistic |
| Pull refresh | Jank/slow if list clears | AsyncLoading anti-pattern |
| Open notifications | Slightly laggy | Staggered entrance |
| Open story | Fast | 180ms fade |
| Image posts | Uneven | Spinner placeholder, no reserved aspect → jump |
| Search typing | Potentially janky | Undebounced network |

**Summary:** Interaction micro-feedback is premium; **page-level loading strategy is not**. Users judge the latter more when deciding “is this app polished?”

---

## Priority Matrix

| ID | Improvement | Priority | UX impact | Dev complexity | Satisfaction lift |
|----|-------------|----------|-----------|----------------|-------------------|
| P0-1 | Feed/profile/notif skeletons; no full wipe on refresh | **Critical** | Very high | Medium | Very high |
| P0-2 | Always show Add Story entry | **Critical** | High | Low | High |
| P0-3 | Notification deep link to post/comment | **Critical** | Very high | Medium | Very high |
| P0-4 | Adaptive splash (≤800ms when session) | **Critical** | High | Low | High |
| P1-1 | Search debounce + custom ink UI + recents | **High** | High | Medium | High |
| P1-2 | Empty-graph onboarding (suggested users) | **High** | Very high | Medium–High | Very high |
| P1-3 | Draft posts (local) | **High** | High | Medium | High |
| P1-4 | Image progressive load + aspect ratio lock | **High** | High | Medium | High |
| P1-5 | Accessibility: semantics, contrast, reduce motion | **High** | High | Medium | Medium–High |
| P1-6 | Split Edit Profile vs Security | **High** | Medium | Medium | Medium |
| P2-1 | Double-tap like; long-press create menu | **Medium** | Medium | Low–Med | Medium |
| P2-2 | Undo toasts | **Medium** | Medium | Low | Medium |
| P2-3 | Upload progress % | **Medium** | Medium | Medium | Medium |
| P2-4 | Offline banner vs nav collision fix | **Medium** | Medium | Low | Low–Med |
| P2-5 | Design token consolidation | **Medium** | Medium | Medium | Medium (dev+UI) |
| P3-1 | Explore / topics | **Nice** | High | High | High |
| P3-2 | Multi-image / video posts | **Nice** | High | High | High |
| P3-3 | Trust & safety (block/report) | **Nice→must for scale** | High | High | Trust |
| P3-4 | Push soft-ask + real push | **Nice→must** | High | High | Retention |
| P4 | DMs, reposts, bookmarks, widgets | **Flagship** | Very high | Very high | Very high |

---

## Final Roadmap

### Phase 1 — Quick Wins (1–2 weeks) — **SHIPPED**

**Goal:** App feels faster and less broken without new backend.

1. ~~Skeleton feed + profile header skeleton~~ **Done**  
2. ~~Non-destructive feed refresh~~ **Done**  
3. ~~Always-visible “Your story” cell~~ **Done**  
4. ~~Adaptive splash~~ **Done**  
5. ~~Notification deep links~~ **Done**  
6. ~~Cap notification list animations~~ **Done**  
7. ~~Search 300ms debounce~~ **Done**  
8. ~~Tooltips/Semantics on header & nav~~ **Done**  
9. ~~Raise tertiary text contrast~~ **Done**  
10. ~~End-of-feed hide spinner~~ **Done**

### Phase 2 — High Impact UX (2–4 weeks) — **SHIPPED (core)**

1. ~~Custom search + recents~~ **Done**  
2. ~~Suggested users~~ **Done**  
3. ~~Local draft posts~~ **Done**  
4. ~~Image aspect ratio + fade-in~~ **Done**  
5. ~~Split profile edit vs security~~ **Done**  
6. ~~Long-press Create → Post / Story~~ **Done**  
7. ~~Reduce-motion helpers~~ **Partial** (helpers + some animations)  
8. ~~Offline banner vs nav~~ **Done**  
9. ~~Notification error humanising~~ **Done**  
10. ~~Approval expectations copy~~ **Done**

### Phase 3 — Premium Polish (1–2 months) — **IN PROGRESS**

1. Double-tap like; media gestures — **Pending**  
2. Upload progress — **Pending**  
3. Design system documentation — **Pending**  
4. Trust & safety (block/report/mute) — **Skipped** (product)  
5. Push permission UX + OS notifications — **FCM largely done**; soft-ask + iOS config + ops verify remain ([PENDING.md](../notifications/PENDING.md))  
6. Richer profile banner / highlights — **Pending**  
7. Analytics — **Pending**  
8. Dislike education tooltip — **Pending**  
9. **Notification Realtime + RPC unread count** — **Pending** (tracked in [PENDING.md](../notifications/PENDING.md))

### Phase 4 — Flagship Experience

1. Explore / recommendations.  
2. Multi-image & video feed posts.  
3. Bookmarks, reposts/quotes.  
4. DMs or lightweight messaging.  
5. Share extensions / system share.  
6. Full a11y audit with VoiceOver/TalkBack.  
7. Performance budget (frame times on mid-tier Android).  
8. Optional Realtime for live notif badge (architecture already noted as future).

---

## Evaluation Principles Applied

| Principle | Application in this audit |
|-----------|---------------------------|
| Nielsen: Visibility of status | Skeletons, non-destructive refresh, upload % |
| Nielsen: Match real world | Notification → content; story entry always present |
| Nielsen: Error prevention | Drafts; confirm deletes (exists); undo |
| Nielsen: Consistency | Design system section |
| Material / HIG motion | 180–300ms transitions; reduce motion |
| HIG touch targets | 44pt minimum callout |
| Cognitive load | Split settings; approval expectation setting |
| Least effort / leverage stack | Prefer Riverpod keepPrevious, shimmer, GoRouter, existing optimistic UI |

---

## Closing Recommendation

**Do not chase a full visual rebrand.** The ink/cream/mascot system is already a moat.

**Chase activation completion and perceived speed:**

1. Content never blank when you already have it.  
2. Every notification finishes a job.  
3. Every new user sees a path to first post and first follow.  
4. Stories are always creatable in one tap.  

Those four changes will move Overall UX more than any gradient tweak.

---

## Appendix — Architecture-aligned implementation notes

| UX change | Touch points (existing) |
|-----------|-------------------------|
| Skeleton feed | `home_screen.dart` `feedAsync.when(loading:)` |
| Non-destructive refresh | `FeedNotifier.refresh` — avoid `state = AsyncLoading` when `state.hasValue` |
| Add story always | `story_circles_row.dart` empty branch |
| Notif deep link | `notifications_screen.dart` `onTap` + model `postId` |
| Splash adaptive | `splash_screen.dart` delay + parallel profile fetch |
| Search debounce | `search_provider.dart` / UI debounce before `searchResultsProvider` |
| Semantics | `entangl_nav_bar.dart`, home header buttons |
| Drafts | `create_post_provider.dart` + local persistence |
| Reduce motion | Mascot + story ring + notif stagger gates |

---

*End of audit.*
