# Architectural Review: Proposed Connect/Entangl Architecture vs. Current System

**Review date:** 2026-07-11  
**Addendum:** 2026-07-18 — notification/FCM status corrected below  
**Docs index:** [../README.md](../README.md)  
**Review scope:** The long “Architectural & Technical Analysis of Connect (Entangl)” document (the proposal) vs. the live codebase and existing docs ([FOLDER_STRUCTURE.md](FOLDER_STRUCTURE.md), [../DOCUMENTATION.md](../DOCUMENTATION.md)).

**Method:** Claims were checked against source layout, feature modules, router, repositories, providers, and dependency usage. Unsupported claims are called out explicitly rather than assumed true.

> ### Notification status addendum (2026-07-18)
>
> Parts of this review described notifications as pull-only with **no** Realtime and **no** push. That is **partially outdated**:
>
> | Claim in original review | Current state |
> |--------------------------|---------------|
> | Notifications pull-only, no push | **Mobile FCM** implemented (client + `device_tokens` + Edge `send-push`) |
> | No Realtime in app | Still true for **Postgres Realtime channels** |
> | No admin | Admin approval / requests exist |
> | No search debounce | Debounce implemented (custom search screen) |
>
> Canonical docs:
>
> - [`../notifications/STATUS.md`](../notifications/STATUS.md) — implementation status  
> - [`../notifications/PENDING.md`](../notifications/PENDING.md) — pending work  
> - [`../notifications/PUSH.md`](../notifications/PUSH.md) — FCM ops  
> - [`../README.md`](../README.md) — docs index

---

## 1. Overall Alignment Summary

The proposal is a **strong descriptive map of the core social product** (feature-first layout, Riverpod notifiers, repository layer, optimistic feed reactions, GoRouter session guards, Supabase Auth/Postgres/Storage). For the **original nine features** it is largely directionally correct.

It is **not fully faithful to the current system**. It:

- Under-documents **shipped growth** (admin approval, email-change workflow, forgot password, story editor, brand rename).
- Overstates **enforcement of layering rules** and **Clean / DIP purity**.
- Misstates several **runtime behaviors** (login redirect path, Realtime, search debounce, secure storage).
- Conflicts with parts of **existing docs** (Realtime, admin, debouncing) and leaves those docs partially stale as well.

| Dimension | Alignment | Score |
|-----------|-----------|-------|
| Folder / layer shape | Strong | **8.5/10** |
| Feature inventory completeness | Incomplete | **6/10** |
| Dependency & isolation rules (as claimed) | Idealized vs actual | **5/10** |
| State management (optimistic UI, Riverpod types) | Strong | **8.5/10** |
| Backend / schema accuracy | Partial | **6.5/10** |
| Navigation / auth lifecycle | Partial | **6/10** |
| Naming / brand currency | Stale (“Connect”, `ConnectNavBar`) | **5/10** |
| Security claims | Partially accurate | **7/10** |
| **Overall fidelity as “as-built” architecture** | Good overview, not source of truth | **6.5/10** |

**Bottom line:** Treat this document as an **aspirational + mostly-accurate core design write-up**, not a production system-of-record. It needs a correction pass before use for onboarding, implementation, or compliance.

---

## 2. Component-by-Component Comparison

### 2.1 High-level architecture (feature-first / layered hybrid)

| Aspect | Proposal | Current system | Alignment |
|--------|----------|----------------|-----------|
| Vertical feature slices + shared `core`/`data`/`shared` | Yes | Yes | **Match** |
| “Influenced by Clean Architecture” | Soft claim | Matches `FOLDER_STRUCTURE.md`: hybrid, **not** strict CA (no use-cases / domain entities / ports) | **Match if soft**; **mismatch if read as formal CA** |
| Unidirectional UI → Notifier → Repo → Supabase | Diagram | Dominant pattern for mutations/queries | **Match** |
| Presentation “entirely decoupled” from network/DB | Stated as rule | **Not true in practice** (see §3) | **Mismatch** |

**Score: 7.5/10** — Shape is right; purity claims are overstated.

**Gaps:** No domain layer, no repository interfaces, no use-case layer. Existing `FOLDER_STRUCTURE.md` is more precise here.

---

### 2.2 Layering & dependency rules

| Rule in proposal | Actual code | Verdict |
|------------------|-------------|---------|
| Screens must not talk to Supabase; only via providers → repos | Screens/widgets call `SupabaseService.currentUserId` / `Supabase.instance` (`post_card`, `profile_screen`, `comments_sheet`, `story_viewer`, `splash`, etc.) | **Violated** |
| Only `lib/data/repositories` may touch `SupabaseService` / `supabase_flutter` | `app_router`, `app_lifecycle`, `auth_provider`, `splash_screen`, `main.dart`, plus multiple feature widgets | **Violated** (even `SupabaseService`’s own comment claims exclusivity that the tree ignores) |
| Presentation must not instantiate repositories | `LoginScreen` does `UsersRepository()` / `AuthRepository()` directly | **Violated** |
| Shared widgets must not import feature screens | Generally true (`PostCard` → `CommentsSheet` is a **feature import from shared**, which **inverts** the stated promotion rule) | **Partial mismatch** |

**Score: 4.5/10** as *documented policy vs as-built*.  
**Score: 7/10** as *intended architecture direction*.

**Design flaw:** Documenting unenforced rules as facts creates false confidence for new engineers and for future refactors.

---

### 2.3 Project structure & naming

| Proposal | Actual | Verdict |
|----------|--------|---------|
| 9 features under `features/` | **10** features: + **`admin`** | **Missing** |
| Auth = splash/login/register | Also **forgot password**, **approval status** | **Missing** |
| Stories = row + viewer + create sheet | Also **`story_editor_screen.dart`** (~800+ LOC canvas editor) | **Missing** |
| Shared: `ConnectNavBar` | **`EntanglNavBar`**, **`EntanglAppBar`** | **Stale naming** |
| Product name “Connect” throughout | App title / brand **Entangl** | **Stale** |
| `secrets.dart.example` setup step | `.gitignore` expects it; **example file not present** in tree from review | **Setup gap** |

**Score: 6/10**

---

### 2.4 Feature modules

| Feature | Proposal accuracy | Notes |
|---------|-------------------|-------|
| **auth** | Partial | Omits approval gate, password reset, email-change auto-process on splash/login |
| **feed** | Strong | Optimistic pending sets + rollback correctly described |
| **post** | Strong | Stickers / create form directionally correct |
| **comments** | Strong with code snag | Nested replies correct; sample uses `copyWith` — **`CommentModel` has no `copyWith`**; code rebuilds via constructor |
| **stories** | Incomplete | Viewer/grouping OK; editor, viewers list, likes omitted or thin |
| **notifications** | Strong (as of 2026-07-18) | Deep links + FCM push; still **no** Postgres Realtime; unread not yet via RPC |
| **profile** | Strong | Follow optimistic delta, family providers match |
| **search** | Overstated | Claims **debounced** results; provider has **no debounce timer** (comment only). Existing `DOCUMENTATION.md` correctly says no debounce |
| **settings** | Strong | Local `SharedPreferences` notification prefs match |
| **admin** | **Absent** | Registration approve/reject + email-change admin UI and repository methods exist |

**Score: 6.5/10** overall feature fidelity.

---

### 2.5 State management (Riverpod)

| Claim | Actual | Verdict |
|-------|--------|---------|
| Mix of `AsyncNotifier`, `Notifier`, `FutureProvider`, `StreamProvider` | Correct | **Match** |
| Optimistic feed + `_applyPending` | Correct in `FeedNotifier` | **Match** (high value) |
| Comments as `FamilyAsyncNotifier` | Correct | **Match** |
| Auth as `AsyncValue.guard` | Correct | **Match** |
| Dependency inversion via **abstract** repos | Concrete classes only; no interfaces | **Overclaim** |
| `riverpod_annotation` + build_runner required | Dep in pubspec; **no generated `*.g.dart`**; providers hand-written | **Setup overclaim** |

**Score: 8/10** for patterns; **6/10** for DIP/codegen claims.

---

### 2.6 Backend / Supabase

| Claim | Actual | Verdict |
|-------|--------|---------|
| Auth + Postgres + Storage | Yes | **Match** |
| “Real-time operations” (§6 intro) | **No** Realtime channels/subscriptions in app code | **Contradiction** (later Priority 4 admits this) |
| Schema ERD | Core tables match inferred model | **Partial** — missing `profiles.status`, `story_views`, `story_likes` |
| RLS assumed in diagram | Client assumes policies; **no SQL/policy artifacts in repo** | **Unsupported in-repo** |
| Notification creation | Client reads only; creation not in Flutter code | Doc implies system has notifications; **server-side source not proven here** |
| Nested PostgREST joins | Yes | **Match** |
| Storage buckets stories/post-images/avatars | Yes | **Match** |

**Score: 6.5/10**

**Conflict with existing docs:** `DOCUMENTATION.md` states Realtime is **not** used. Proposal intro conflicts with both code and that doc; improvement §18 aligns with code.

---

### 2.7 Data models

Most mappings (`UserModel`, `PostModel`, `CommentModel`, `NotificationModel`, `StoryModel`, `ProfileStatsModel`) **match**.

Gaps:

- `UserModel.status` and approval helpers **not** in ERD/model section.
- Comment factory description is fine; **UI state update snippet is idealized**.

**Score: 7.5/10**

---

### 2.8 Repository layer

| Repo | Proposal | Actual | Gap |
|------|----------|--------|-----|
| Auth | signUp/signIn/signOut | + `resetPassword`, `updatePassword`, `updateEmail` | Incomplete API surface |
| Users | profile/follow/search | + admin + email-change workflow methods | Incomplete |
| Posts / Comments / Stories / Notifications | Largely complete | Stories methods broader (viewers, likes) | Minor |

Repository pattern **exists and is used**; testability claim is architectural potential, **not** demonstrated (single trivial widget test).

**Score: 7/10**

---

### 2.9 Navigation & auth guards

| Claim | Actual | Verdict |
|-------|--------|---------|
| GoRouter + session redirect | Present | **Match** |
| Route table listed | Missing `/forgot-password`, `/approval-status`, `/admin/requests` | **Incomplete** |
| Login success: “AuthState stream → router redirect → `/home`” | Login **manually** checks profile approval, optional email-change processing, then `context.go` | **Incorrect lifecycle** |
| Router `refreshListenable` / reactive auth rebuild | **Not configured** | Stream does **not** drive GoRouter automatically as described |
| Splash: session → home/login only | Splash also routes to **approval** and processes **email_change_approved** | **Incomplete** |

**Score: 5.5/10**

---

### 2.10 UI / design system

Theme tokens (ink/cream, Inter/Comic Neue, mascots, `flutter_animate`) appear **aligned** with the zine redesign. Nav bar naming is wrong (`ConnectNavBar` → `EntanglNavBar`). Micro-interaction claims are plausible but not fully re-audited line-by-line.

**Score: 8/10** (minus branding/stale widget names).

---

### 2.11 Dependencies

| Package claim | Reality |
|---------------|---------|
| supabase, riverpod, go_router, image_picker, video_player, cached_network_image, shared_preferences, flutter_animate, google_fonts | **Used** |
| `flutter_secure_storage` “securely persists authentication keys” | **In pubspec; no usage found under `lib/`** — session persistence is Supabase’s, not this package in app code |
| `crop_your_image` / `image_cropper` | Present in pubspec / crop flows; **underplayed** in proposal |
| `riverpod_generator` / build_runner | Present as tooling; **not central to current provider style** |

**Score: 6.5/10**

---

### 2.12 Performance, security, quality ratings

| Topic | Proposal | Assessment |
|-------|----------|------------|
| Image caching via `CachedNetworkImage` | Accurate | + avatar cache bust / eviction exists and is **under-documented** |
| Full feed rebuild on like | Accurate concern | Valid |
| Secrets in `secrets.dart` | Accurate risk | Note: file is gitignored; still poor practice for distribution/CI |
| Client 50MB story limit | Accurate | Server enforcement **not verifiable** from this repo |
| SOLID “D = abstract repos” | Overstated | Concrete deps |
| Architecture 9/10, Security 7/10 | Slightly optimistic if measuring **as-built fidelity + security posture** | Architecture **~7.5**, Security **~6–7** until RLS/admin auth proven |

**Score for this section’s honesty: 7.5/10** (improvements are better than the self-score marketing).

---

### 2.13 Comparison to *existing* architecture docs

| Topic | Proposal | `FOLDER_STRUCTURE.md` | `DOCUMENTATION.md` |
|-------|----------|----------------------|--------------------|
| Strict Clean Architecture | Soft “influenced” | Explicitly **not strict CA** | Feature/layered product doc |
| Realtime | Intro claims RT; later admits missing | Correctly cautious | Explicitly **not used** |
| Admin | Missing | Missing | **Wrong**: still says “No Admin Features” |
| Search debounce | Claims debounced | N/A | Correctly **no debounce** |
| Brand Connect vs Entangl | Connect-heavy | Mixed / older | Older “Connect” |

**Implication:** The proposal improves narrative structure over raw docs in places, but **does not supersede** them as truth; all three need a synchronized update.

---

## 3. Mismatches and Missing Elements

### Critical mismatches (false or misleading if used as as-built)

1. **Realtime** described as part of backend integration while **no subscriptions** exist.
2. **Login lifecycle** attributed to Auth stream + router; actual path is **imperative navigation + approval checks**.
3. **Layer isolation rules** stated as enforced; **widely broken**.
4. **Search debouncing** claimed; **not implemented**.
5. **`flutter_secure_storage`** claimed for auth keys; **unused in app code**.
6. **DIP / abstract repositories** claimed; **no interfaces**.
7. **Comments `copyWith` sample** does not match **model API**.
8. **9 features** vs **10** (`admin` missing).

### Missing components (present in code, absent or thin in proposal)

| Component | Why it matters architecturally |
|-----------|--------------------------------|
| `features/admin` | Moderation / access control plane |
| Profile `status` state machine (`pending` / `approved` / `rejected` / `email_change_*`) | Product authz beyond JWT presence |
| `ApprovalStatusScreen` | Gated onboarding UX |
| `ForgotPasswordScreen` + `AuthRepository.resetPassword` | Account recovery |
| Email-change request / admin approve / client apply | Cross-actor workflow |
| `StoryEditorScreen` (RepaintBoundary export, overlays) | Major Flutter complexity |
| `story_views` / `story_likes` tables | Incomplete social media model |
| Avatar timestamp upload + `evictFromCache` | Cache-coherence pattern |
| Connectivity multi-DNS poll + offline banner | Resilience (mentioned in older docs; thin here) |
| Lifecycle JWT refresh near expiry | Session reliability |
| Routes: `/forgot-password`, `/approval-status`, `/admin/requests` | Incomplete route graph |

### Assumptions **not** supported by the proposal *or* by verifiable repo artifacts

- **RLS policies** exist and are correct (diagram labels RLS; no policies in repo).
- **Server-side** notification triggers / edge functions.
- **Server-side** storage size limits and story expiry cleanup.
- **Admin authorization** (who may open `/admin/requests` — route exists; **role gate not documented** and not evidenced as hardened).
- **Production readiness** after Priority 1–3 alone (tests, observability, CI still thin).

### Outdated / unnecessary decisions as framed

| Item | Issue |
|------|--------|
| Brand “Connect” / `ConnectNavBar` | Renamed to Entangl |
| Emphasizing build_runner as required | Not required for current hand-written providers |
| Treating Realtime as current capability | Future work only |
| Claiming solid dependency inversion | Premature without interfaces or codegen ports |
| Omitting admin while rating scalability highly | Access-control growth already happened outside the doc |

---

## 4. Potential Risks

| Risk | Severity | Why |
|------|----------|-----|
| **Onboarding on a stale map** | High | Engineers will miss admin/approval/email-change and ship broken auth flows |
| **False security confidence** | High | Client session check ≠ approval status ≠ admin RBAC; RLS unproven in repo |
| **Admin route exposure** | High if unauthenticated/unauthorized clients can call approve APIs | Architecture doc does not specify server-side admin authorization |
| **Boundary erosion** | Medium | Doc says “never”; code does “often” — rules will keep decaying |
| **Scale of feed joins** | Medium | Nested likes/dislikes/comments arrays per post page will degrade as reaction volume grows (offset pagination compounds this) |
| **Search API abuse** | Medium | No debounce + `ilike %q%` can hammer DB |
| **Story storage growth** | Medium | Client 24h filter only; no documented cleanup job |
| **Secrets distribution** | Medium | Static secrets file pattern conflicts with multi-env CI and leak surface (anon key is public by design, but process still matters) |
| **Inconsistent documentation suite** | Medium | Proposal vs `DOCUMENTATION.md` vs code will thrash decisions |
| **Test gap vs “testability” claim** | Medium | Repository pattern without tests is unproven resilience |

---

## 5. Recommended Changes

### A. Correct the architecture document (before treating it as source of truth)

1. **Rename** product/widgets consistently to **Entangl** (`EntanglNavBar`, package name).
2. Add **Feature 10: admin** + auth subflows (approval, forgot password, email change).
3. Rewrite **§4.1 Login** to the real sequence:  
   `signIn` → check `AsyncError` → load profile status → approval route **or** process `email_change_approved` → `context.go(home)`.
4. Document **splash** status machine the same way.
5. Expand **AppRoutes** + mermaid graph with all routes.
6. Fix backend intro: **Auth + DB + Storage; Realtime not implemented**.
7. Extend ERD: `profiles.status`, `story_views`, `story_likes`.
8. Fix search wording: **“query-driven `FutureProvider.family` (not debounced)”**.
9. Remove or qualify: Realtime streams, secure storage for auth, abstract DIP, required build_runner, `copyWith` snippet.
10. State **as-is vs to-be** dependency rules explicitly; list current violations.
11. Document **admin authorization model** as **TBD/unverified** until RLS/roles are proven.
12. Demote ratings slightly or split into “structure quality” vs “production hardening.”

### B. Align code with the architecture you want (if rules are real)

1. Ban direct `Supabase.instance` / `SupabaseService` in UI; inject `currentUserId` via providers.
2. Stop constructing repositories in screens; always `ref.read(*RepositoryProvider)`.
3. Add `GoRouter(refreshListenable: …)` **or** keep imperative nav but document only one pattern.
4. Add true **search debounce** (300ms) if product needs it.
5. Either use **`flutter_secure_storage`** or drop the dependency.
6. Add repository **interfaces** only if you intend DIP/testing investment; otherwise drop the DIP language.
7. Gate **admin** routes/API with a real role claim + RLS.

### C. Align the *existing* docs package

1. Update `DOCUMENTATION.md` items that still claim **no admin**, and keep **Realtime = not used**.
2. Update `FOLDER_STRUCTURE.md` widget names and admin module.
3. Pick **one** canonical architecture doc; link the others as secondary.

### D. Better approaches where the proposal is weak

| Area | Current / proposed | Better approach |
|------|--------------------|-----------------|
| Authz | Session-only router guard | Session + **profile status** redirect + **server RLS**; admin role separate |
| Feed reactions | Join all like rows | Counts via DB aggregates / RPC; optional Realtime later |
| Pagination | Offset `.range` | Cursor on `created_at,id` for scale |
| Notifications | Poll / open screen | Optional Realtime or push; don’t call pull “streams” |
| Config | `secrets.dart` | `--dart-define` / flavors; never commit real projects keys in shared machines |
| Architecture purity | Narrative CA | Keep **feature-first + repository**; name it honestly |

---

## 6. Final Verdict

| Question | Answer |
|----------|--------|
| Does the proposal correctly describe the **core** system shape? | **Yes** — feature-first Flutter + Riverpod + repositories + Supabase is accurate. |
| Does it faithfully represent the **current** system end-to-end? | **No** — incomplete feature set, stale branding, overstated isolation/Realtime/DIP, incorrect login lifecycle details. |
| Is it safe as the **single** architecture source for implementation/onboarding? | **Not yet** — requires a correction pass and sync with code + older docs. |
| Is it useful? | **Yes**, as a narrative backbone once corrected; optimistic UI and layer diagram sections are high value. |
| Overall as-built fidelity | **6.5 / 10** |
| Overall as target architecture direction | **7.5 / 10** (with Realtime/admin/debounce clearly marked as future) |

### Decision

**Do not implement or onboard from this proposal as-is.**  
**Accept with mandatory revisions** listed in §5A before it replaces or merges with [`FOLDER_STRUCTURE.md`](FOLDER_STRUCTURE.md) / [`../DOCUMENTATION.md`](../DOCUMENTATION.md).

### Highest-priority truth fixes (minimum bar)

1. Add **admin + approval + email-change + forgot-password + story editor**.  
2. Remove false **Realtime / debounce / secure-storage-for-auth / abstract-repo** claims.  
3. Document **actual** auth navigation and **status** gate.  
4. Soften layering rules to **as-is vs intended**, or enforce them in code.  
5. Fix brand naming to **Entangl**.

---

## Related documents

- Proposed architecture under review: user-provided “Architectural & Technical Analysis of Connect (Entangl)”
- Docs index: [`../README.md`](../README.md)
- Architecture map: [`FOLDER_STRUCTURE.md`](FOLDER_STRUCTURE.md)
- Product suite: [`../DOCUMENTATION.md`](../DOCUMENTATION.md)
- Notifications: [`../notifications/STATUS.md`](../notifications/STATUS.md), [`../notifications/PENDING.md`](../notifications/PENDING.md)
- Primary implementation: `lib/`
