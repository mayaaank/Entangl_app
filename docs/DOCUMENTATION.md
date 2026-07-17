# Entangl — Product & Technical Documentation Suite

**Version:** 1.0.0+1  
**Last Updated:** July 18, 2026  
**Framework:** Flutter (SDK >=3.0.0)  
**Backend:** Supabase (PostgreSQL, Auth, Storage) + **FCM** for mobile push  
**State Management:** Riverpod  

> **Documentation index:** [README.md](README.md)  
> **Architecture:** [architecture/FOLDER_STRUCTURE.md](architecture/FOLDER_STRUCTURE.md) · [architecture/ARCHITECTURE_AUDIT.md](architecture/ARCHITECTURE_AUDIT.md)  
> **UX audit:** [ux/UI_UX_AUDIT.md](ux/UI_UX_AUDIT.md)  
> **Notifications:** [notifications/STATUS.md](notifications/STATUS.md) · [notifications/PENDING.md](notifications/PENDING.md) · [notifications/PUSH.md](notifications/PUSH.md)

---

# TABLE OF CONTENTS

## Part 1: Product Documentation
1. [Application Overview](#1-application-overview)
2. [Screen-by-Screen Documentation](#2-screen-by-screen-documentation)
3. [Feature Documentation](#3-feature-documentation)
4. [User Journey Maps](#4-user-journey-maps)
5. [Business Logic & System Behavior](#5-business-logic--system-behavior)
6. [Error Handling, Validation & User Feedback](#6-error-handling-validation--user-feedback)

## Part 2: Technical Documentation
7. [Architecture Overview](#7-architecture-overview)
8. [Database Schema](#8-database-schema)
9. [Data Layer & Repository Documentation](#9-data-layer--repository-documentation)
10. [State Management](#10-state-management)
11. [Authentication & Authorization](#11-authentication--authorization)
12. [Routing System](#12-routing-system)
13. [Third-Party Integrations](#13-third-party-integrations)
14. [Real-Time Features & Async Operations](#14-real-time-features--async-operations)
15. [System Execution Flow](#15-system-execution-flow)
16. [Security Considerations](#16-security-considerations)
17. [Performance Optimizations](#17-performance-optimizations)

## Part 3: Operational & Developer Resources
18. [Setup & Deployment](#18-setup--deployment)
19. [Developer Handoff Notes](#19-developer-handoff-notes)
20. [QA/Testing Scenarios](#20-qatesting-scenarios)
21. [Known Limitations & Future Improvements](#21-known-limitations--future-improvements)

---

# PART 1: PRODUCT DOCUMENTATION

## 1. Application Overview

### 1.1 What is Connect?

Connect is a modern social media platform built with Flutter and powered by Supabase as a Backend-as-a-Service. The application enables users to create accounts, publish posts with images, engage with content through likes/dislikes, comment and reply, follow/unfollow other users, create ephemeral stories (24-hour expiry), and receive real-time activity notifications.

### 1.2 Core Value Proposition

- **Feed-based content consumption:** Infinite-scrolling feed with posts from the community
- **Dual reaction system:** Both like AND dislike support (unlike typical social apps)
- **Ephemeral stories:** Image and video stories that expire after 24 hours
- **Rich social graph:** Follow/follower relationships with profile statistics
- **Threaded comments:** Nested reply support on posts
- **Activity notifications:** In-app notification feed (DB triggers) plus optional **mobile FCM** push; deep links by type (follow → profile, like/comment → post context)
- **User search:** Discover other users by username or full name

### 1.3 Target Audience

Social media users seeking a platform with both positive (like) and negative (dislike) content feedback mechanisms, combined with ephemeral story content.

### 1.4 Design Language

- **Theme:** Dark mode only (light theme defined but inactive)
- **Primary Gradient:** Violet (#6D28D9) to Pink (#DB2777)
- **Background:** Near-black (#131313)
- **Typography:** Inter font family with weights 400-800
- **Design System:** Material 3 with custom overrides
- **Visual Style:** Gradient accents, pill-shaped containers, backdrop blur effects, stadium-shaped buttons

---

## 2. Screen-by-Screen Documentation

### 2.1 Splash Screen

**Route:** `/`  
**File:** `lib/features/auth/screens/splash_screen.dart`  
**Auth Required:** No

**Purpose:** Initial loading screen displayed on app launch.

**Behavior:**
1. Displays app icon (180x180px from `assets/icon.png`) centered on a `#0E0E0E` background
2. Plays entrance animation: Scale from 0.82 to 1.0 (easeOutBack curve) + Fade from 0.0 to 1.0 over 1400ms
3. Waits 1800ms total
4. Checks Supabase session existence
5. Auto-navigates to `/home` if session exists, `/login` if not

**UI Elements:**
- Centered app icon with scale + fade animation
- Solid dark background

---

### 2.2 Login Screen

**Route:** `/login`  
**File:** `lib/features/auth/screens/login_screen.dart`  
**Auth Required:** No

**Purpose:** Authenticate existing users via email and password.

**Form Fields:**
| Field | Type | Validation |
|-------|------|------------|
| Email | Email keyboard | Must be valid email format |
| Password | Text (visibility toggle) | No client-side validation |

**User Flow:**
1. User enters email and password
2. User taps "Sign In" button
3. Form validation runs
4. If valid, button shows loading spinner, sign-in request sent to Supabase
5. On success: navigates to `/home`
6. On failure: displays humanized error message in snackbar

**UI Elements:**
- "Welcome back" hero title (gradient text, 48px)
- Email TextFormField
- Password TextFormField with eye icon toggle
- Full-width gradient "Sign In" button
- "Don't have an account? Sign Up" link (navigates to `/register`)
- Decorative background circle element

---

### 2.3 Register Screen

**Route:** `/register`  
**File:** `lib/features/auth/screens/register_screen.dart`  
**Auth Required:** No

**Purpose:** Create a new user account.

**Form Fields:**
| Field | Type | Validation |
|-------|------|------------|
| Full Name | Text | Required, non-empty |
| Username | Text | Min 3 chars, alphanumeric + underscores only |
| Email | Email keyboard | Must contain @ |
| Password | Text (visibility toggle) | Min 6 characters |

**User Flow:**
1. User fills in all four fields
2. Username is automatically lowercased on submission
3. User taps "Create Account" button
4. Form validation runs
5. If valid, button shows loading spinner, registration request sent to Supabase
6. On success: navigates to `/home`
7. On failure: displays humanized error message

**UI Elements:**
- "Create Account" hero title (gradient text, 48px)
- Four AuthField components
- Full-width gradient "Create Account" button
- "Already have an account? Sign In" link (navigates to `/login`)
- Decorative bottom-left circle element

---

### 2.4 Home Screen (Feed)

**Route:** `/home`  
**File:** `lib/features/feed/screens/home_screen.dart`  
**Auth Required:** Yes  
**Navigation Bar Index:** 0

**Purpose:** Main content consumption screen displaying the community feed with stories.

**Screen Structure:**

**AppBar (Floating, Snapping):**
- "Connect" brand name (gradient text)
- Search icon button (opens UserSearchDelegate)
- Notification bell icon with unread badge (red dot when unread count > 0)
- Settings icon button (default trailing)

**Stories Row:**
- 96px height horizontal scrollable row
- Story circles for users with active (24h) stories
- "Add Story" circle (+ badge) for current user
- Skeleton shimmer loading state while fetching
- Tapping a circle opens StoryViewerScreen

**Feed Content:**
- SliverList of PostCard widgets
- Pull-to-refresh support
- Infinite scroll (triggers load more at 300px from bottom)
- Page size: 20 posts per load

**Empty State:**
- "Nothing here yet" text
- "Create post" CTA button (navigates to `/create-post`)

**Error State:**
- WiFi off icon
- Gradient "Retry" button

**Bottom Navigation:**
- Custom floating pill-shaped bar with backdrop blur
- Three items: Home (icon), Create (center FAB), Profile (icon)
- Animated gradient indicator dot on active item

---

### 2.5 Create Post Screen

**Route:** `/create-post`  
**File:** `lib/features/post/screens/create_post_screen.dart`  
**Auth Required:** Yes

**Purpose:** Compose and publish a new post with optional image attachment.

**Form Fields:**
| Field | Type | Validation |
|-------|------|------------|
| Content | Text (multiline, 4 lines) | Max 500 characters |
| Image | Optional (gallery source) | None |

**Character Counter:**
- Circular progress indicator in top-right
- Color transitions: Primary -> Orange (<=50 remaining) -> Error (<0)

**AppBar Actions:**
- Close button (pops without saving)
- "Story" button (opens CreateStorySheet)
- Post button (gradient, disabled when content empty and no image)

**User Flow:**
1. User types content and/or selects an image
2. Post button enables when content is non-empty OR image is selected
3. User taps "Post"
4. Submitting state shows spinner
5. On success: feed refreshed, profile stats invalidated, returns to previous screen
6. Image picker: Gallery source, 85% JPEG quality

---

### 2.6 Notifications Screen

**Route:** `/notifications`  
**File:** `lib/features/notifications/screens/notifications_screen.dart`  
**Auth Required:** Yes

**Purpose:** Display activity notifications for social interactions.

**AppBar:**
- Back button
- Title: "Notifications"
- "Mark all read" action button

**Notification Types:**
| Type | Icon | Color | Trigger |
|------|------|-------|---------|
| Follow | person_add | Primary | Someone follows you |
| Like | favorite | Red (#EF4444) | Someone likes your post |
| Dislike | thumb_down | Orange (#F97316) | Someone dislikes your post |
| Comment | chat_bubble | Blue (#3B82F6) | Someone comments on your post |
| Reply | reply | Green (#22C55E) | Someone replies to your comment |

**Interactions:**
- Tap notification: Marks as read, then **type-aware deep link**
  - `follow` → actor profile
  - `like` / `dislike` → post preview sheet (comments / profile actions)
  - `comment` / `reply` → comments sheet for that post
  - Missing `post_id` → actor profile fallback
- Swipe to dismiss: Deletes the notification
- Unread indicator: 6px cream dot on left edge; home bell uses unread badge
- Post thumbnail: 40×40 image when notification has associated post

**Empty State:**
- Mascot + "You're all caught up"

**Page Size:** 50 notifications (repository limit)

**Push (mobile):** FCM via `NotificationService` + `device_tokens`; see [notifications/PUSH.md](notifications/PUSH.md) and [notifications/STATUS.md](notifications/STATUS.md).

---

### 2.7 Profile Screen (Own)

**Route:** `/profile`  
**File:** `lib/features/profile/screens/profile_screen.dart`  
**Auth Required:** Yes  
**Navigation Bar Index:** 2

**Purpose:** Display current user's profile with stats, posts, and follow lists.

**Header:**
- Gradient banner (#6D28D9 to #DB2777, 100px height)
- 72px avatar (offset -28px over banner, 3px background border)
- Full name (sectionTitle, 28px)
- @username (username style, primary color)
- Optional bio (bodyMedium)

**Stats Card:**
| Stat | Source | Behavior |
|------|--------|----------|
| Posts | Count from posts table | Static number |
| Followers | Count from follows table (as following_id) | Tappable, opens Followers tab + optimistic delta on follow/unfollow |
| Following | Count from follows table (as follower_id) | Tappable, opens Following tab |

**Action Buttons (Own Profile):**
- "Edit profile" outline button (navigates to `/profile/edit`)
- "Log out" outline button (signs out, navigates to `/login`)

**Tabs:**
| Tab | Content |
|-----|---------|
| Posts | User's own posts (RefreshIndicator + empty state) |
| Followers | List of users who follow this user |
| Following | List of users this user follows |

---

### 2.8 Other User Profile Screen

**Route:** `/profile/:userId`  
**File:** `lib/features/profile/screens/profile_screen.dart`  
**Auth Required:** Yes

**Purpose:** Display another user's profile with follow/unfollow capability.

**Differences from Own Profile:**
- AppBar has custom back button with transparent background and black overlay
- Action button: Follow/Unfollow button instead of Edit/Logout
- Stats card: Followers count shows optimistic delta during follow/unfollow operations

**Follow Button Behavior:**
- Not following: Gradient-filled button, "Follow" label
- Following: Outlined button, "Following" label
- AnimatedContainer transition between states
- Haptic feedback on toggle
- Optimistic UI update with error revert

**Tabs:** Same as own profile (Posts, Followers, Following)

---

### 2.9 Edit Profile Screen

**Route:** `/profile/edit`  
**File:** `lib/features/profile/screens/edit_profile_screen.dart`  
**Auth Required:** Yes

**Purpose:** Update profile information and avatar.

**Form Fields:**
| Field | Type | Validation |
|-------|------|------------|
| Avatar | Image picker (camera/gallery) | Optional |
| Full Name | Text | Required |
| Username | Text | Min 3, max 30 chars, alphanumeric + underscores |
| Bio | Text (4 lines) | Max 160 characters |

**Avatar Picker:**
- 104px CircleAvatar with gradient ring
- Camera icon overlay button
- Tapping opens image picker (camera or gallery)
- Preview updates immediately

**Save Behavior:**
- Gradient "Save" button with loading state
- On save: uploads avatar to Supabase Storage if changed, updates profiles table
- On success: shows success snackbar, pops back
- On error: shows error message

---

### 2.10 Story Viewer Screen

**Route:** Not routed (pushed via Navigator)  
**File:** `lib/features/stories/screens/story_viewer_screen.dart`  
**Auth Required:** Yes

**Purpose:** Full-screen story viewing experience (Instagram/Snapchat-style).

**Progress Bars:**
- Multiple LinearProgressIndicator bars at top (one per story in current user's set)
- Active story: primary gradient color
- Viewed stories: solid primary color
- Unviewed stories: 20% opacity

**Media Display:**
- Images: CachedNetworkImage with FittedBox cover
- Videos: VideoPlayer with FittedBox cover, auto-play/pause on story transition

**Gestures:**
| Gesture | Action |
|---------|--------|
| Tap left 30% | Previous story |
| Tap right 30% | Next story |
| Tap center | Pause/Resume |
| Long press | Pause |
| Release long press | Resume |

**Story Navigation:**
- `_prevStory()` / `_nextStory()` within current user's stories
- `_prevUser()` / `_nextUser()` across users' story groups
- Auto-advances to next user when current user's stories exhausted
- Closes when all stories viewed or dismissed

**Owner Controls (3-dot menu):**
- "View viewers" - opens bottom sheet with list of viewers
- "Delete story" - deletes story, removes from state

**Like Button:**
- Bottom center, heart icon
- Animated scale on toggle (elasticOut curve)
- Light haptic feedback
- Optimistic UI update

**System UI:**
- Immersive sticky mode (hides status bar/navigation)
- Restored on dispose

---

### 2.11 Settings Screen

**Route:** `/settings`  
**File:** `lib/features/settings/screens/settings_screen.dart`  
**Auth Required:** Yes

**Purpose:** Manage app preferences and account actions.

**Sections:**

**1. Notifications (powered by SharedPreferences):**
| Setting | Key | Default |
|---------|-----|---------|
| Push Notifications | `notif_push` | **true** (master FCM on/off) |
| Followers | `notif_followers` | true (**local only** — not enforced on server push yet) |
| Likes | `notif_likes` | true (local only) |
| Dislikes | `notif_dislikes` | false (local only) |
| Comments | `notif_comments` | true (local only) |
| Replies | `notif_replies` | true (local only) |

**2. Account (stubs):**
- Change Password: Opens stub snackbar ("Coming soon")
- Privacy Settings: Opens stub snackbar ("Coming soon")

**3. Danger Zone:**
- Log Out: Functional, signs out and navigates to `/login`
- Delete Account: Muted/disabled, non-functional

---

## 3. Feature Documentation

### 3.1 Authentication System

**Provider:** Supabase Auth  
**Methods:** Email/Password

**Sign-Up Process:**
1. User provides full name, username, email, password
2. Client calls `_client.auth.signUp()` with metadata: `{full_name, username, avatar_url: ''}`
3. Supabase creates user in `auth.users` table
4. Metadata stored in `auth.users.user_metadata`
5. Database trigger (external to codebase) creates row in `profiles` table
6. Session established automatically
7. User navigated to home feed

**Sign-In Process:**
1. User provides email, password
2. Client calls `_client.auth.signInWithPassword()`
3. Supabase validates credentials
4. JWT session established and persisted locally
5. User navigated to home feed

**Sign-Out Process:**
1. Client calls `_client.auth.signOut()`
2. Supabase clears session
3. User navigated to login screen

**Session Persistence:**
- Supabase automatically persists JWT session locally
- Session auto-refreshes when app resumes from background (if expiring within 5 minutes)
- Session checked on splash screen for routing decision

---

### 3.2 Feed System

**Data Source:** `posts` table with joined `profiles`, `likes`, `dislikes`, `comments`

**Feed Fetching:**
- Ordered by `created_at DESC`
- Pagination: 20 posts per page
- Cursor-based pagination using `lt` (less than) on created_at

**Post Structure in Feed:**
Each post fetch includes:
- Post data (id, user_id, content, image_url, created_at)
- Author profile (via `profiles` join on user_id)
- All likes (via `likes` join)
- All dislikes (via `dislikes` join)
- All comments (via `comments` join)

**Optimistic Updates:**
The feed maintains pending state tracking via Sets:
- `_likedIds`: Posts user has optimistically liked
- `_dislikedIds`: Posts user has optimistically disliked
- `_unlikedIds`: Posts user has optimistically unliked
- `_undislikedIds`: Posts user has optimistically undisliked

When fresh data arrives from server, pending state is re-applied to ensure UI consistency during network latency.

**Reaction Logic:**
- Like a post: Removes any existing dislike first, then inserts like
- Unlike a post: Deletes the like record
- Dislike a post: Removes any existing like first, then inserts dislike
- Undislike a post: Deletes the dislike record
- On reaction error: Reverts optimistic UI state

---

### 3.3 Post Creation

**Content Limits:** 500 characters maximum

**Image Handling:**
- Source: Gallery only (camera not available for posts)
- Quality: 85% JPEG
- Upload: Supabase Storage `post-images` bucket at `{userId}/{timestamp}.jpg`
- URL stored in `posts.image_url`

**Post Creation Flow:**
1. User enters text and/or selects image
2. Validates `canSubmit` (content non-empty OR image selected)
3. If image: uploads to storage, gets public URL
4. Creates post record with content and image_url
5. On success: invalidates feed cache, invalidates profile stats, invalidates user posts cache

---

### 3.4 Comments & Replies

**Comment Structure:**
- Top-level comments: `parent_id = null`
- Replies: `parent_id` references parent comment's ID
- One level of nesting (replies to replies not supported)

**Comment Fetching:**
- Fetches top-level comments for a post
- Each comment includes its replies (via `comments!parent_id` relationship)
- Each comment includes author profile (via `profiles!user_id`)

**Comment Input:**
- Pill-shaped TextField at bottom of CommentsSheet
- Reply mode: Shows banner with "@username" and close button
- Submit button: Gradient when text non-empty, disabled otherwise

**Comment Actions:**
- Post owner can reply to any comment
- Comment author can delete their own comment (with confirmation dialog)
- Reply author can delete their own reply

---

### 3.5 Stories System

**Story Lifecycle:**
- Stories expire after 24 hours (client-side filter: `created_at > now() - 24h`)
- Media types: Image or Video
- Max file size: 50 MB

**Story Creation:**
1. User selects photo, video, or captures from camera
2. File validated (size check)
3. Media uploaded to Supabase Storage `stories` bucket
4. Story record created with media_url, media_type
5. Stories list refreshed

**Story Viewing:**
- Full-screen viewer with progress bars
- Auto-advance between stories and users
- View recorded in `story_views` table (upsert)
- Viewers list available to story owner

**Story Interactions:**
- Like/unlike (optimistic update with error revert)
- Delete (owner only)
- View viewers (owner only)

**Story Ordering:**
- Current user's stories appear first
- Other users' stories ordered by most recent

---

### 3.6 Social Graph (Follow System)

**Follow Model:**
- Bidirectional tracking via `follows` table
- `follower_id`: The user who is following
- `following_id`: The user being followed

**Follow Flow:**
1. User taps Follow button
2. Optimistic UI update (button changes to "Following")
3. Haptic feedback triggered
4. Insert follow record in database
5. On success: invalidate profile stats cache, invalidate unread count
6. On error: revert UI to previous state

**Unfollow Flow:**
1. User taps Following button
2. Optimistic UI update (button changes to "Follow")
3. Haptic feedback triggered
4. Delete follow record from database
5. On success: invalidate caches
6. On error: revert UI

**Follow Lists:**
- Followers: Users where `following_id = targetUserId`
- Following: Users where `follower_id = targetUserId`
- Each list item: Avatar + full name + @username, tappable to navigate to profile

---

### 3.7 User Search

**Search Method:** ILIKE query on `username` and `full_name` columns
**Results Limit:** 15 users
**UI:** Flutter SearchDelegate integration via `showSearch`

**Search Flow:**
1. User taps search icon in HomeScreen header
2. UserSearchDelegate opens
3. User types query
4. On query change (non-empty): triggers search
5. Results displayed as ListTiles with avatars
6. Tap result: navigates to `/profile/$userId`

---

### 3.8 Notification System

**Notification Creation:**
- Created server-side (database triggers or edge functions, not in codebase)
- Types: follow, like, dislike, comment, reply
- Each notification links actor, target user, and optionally post/comment

**Notification Fetching:**
- Ordered by `created_at DESC`
- Page size: 50
- Includes actor profile and post data via joins

**Notification Management:**
- Mark as read: Single notification
- Mark all as read: All user notifications
- Delete: Swipe to dismiss
- Unread count: Separate query for badge display

---

## 4. User Journey Maps

### 4.1 New User Onboarding

```
[App Launch]
    |
    v
[Splash Screen] --(1.8s animation)--> [Session Check]
    |                                      |
    | No Session                           | Has Session
    v                                      v
[Login Screen]                         [Home Screen]
    |                                      |
    | "Sign Up" link                       |
    v                                      |
[Register Screen]                          |
    |                                      |
    | Fill: Name, Username, Email, Password|
    | Tap "Create Account"                 |
    v                                      |
[Supabase SignUp]                          |
    |                                      |
    | Success                              |
    v                                      |
[Home Screen] <----------------------------+
    |
    v
[View Feed + Stories]
```

### 4.2 Content Creation Journey

```
[Home Screen]
    |
    | Tap Create FAB or "Create post" CTA
    v
[Create Post Screen]
    |
    | Type content (max 500 chars)
    | Optionally add image from gallery
    | Tap "Post"
    v
[Supabase: Upload Image + Create Post]
    |
    | Success
    v
[Feed Refreshed] <-- [Return to Home]
```

### 4.3 Social Interaction Journey

```
[Home Screen - Viewing Post]
    |
    +-- Tap Like/Dislike --> [Optimistic UI Update] --> [DB Sync]
    |
    +-- Tap Comment Chip --> [CommentsSheet Opens]
    |       |
    |       +-- Type Comment --> Submit --> [Comment Added]
    |       +-- Tap Reply --> Reply Banner Appears --> Submit --> [Reply Added]
    |       +-- Tap Delete (own) --> Confirm --> [Comment Deleted]
    |
    +-- Tap Avatar/Name --> [Profile Screen Opens]
            |
            +-- Tap Follow --> [Optimistic Follow] --> [DB Sync]
            +-- Tap Followers/Following --> [Follow List Opens]
            +-- Tap Any User --> [Navigate to Their Profile]
```

### 4.4 Story Creation & Consumption Journey

```
[Home Screen - Stories Row]
    |
    +-- Tap "+ Add Story" --> [CreateStorySheet Opens]
    |       |
    |       +-- Pick Photo/Video/Camera
    |       +-- Preview
    |       +-- Tap "Share Story" --> [Upload to Storage] --> [Story Created]
    |
    +-- Tap Story Circle --> [StoryViewerScreen Opens]
            |
            +-- Tap Left/Right --> Navigate Stories
            +-- Long Press --> Pause
            +-- Tap Heart --> Like Story
            +-- Tap 3-dot (own) --> View Viewers / Delete
```

---

## 5. Business Logic & System Behavior

### 5.1 Reaction Mutual Exclusivity

Likes and dislikes are mutually exclusive:
- Liking a post that you already disliked automatically removes the dislike
- Disliking a post that you already liked automatically removes the like
- This is enforced at the repository level, not the database level

### 5.2 Story Expiration

- Stories are filtered client-side to only show content created within the last 24 hours
- No server-side cleanup is visible in the codebase
- Expired stories remain in the database but are not fetched

### 5.3 Optimistic UI Pattern

The application extensively uses optimistic UI updates:
- Feed reactions (like/dislike)
- Follow/unfollow
- Story likes
- Comment additions

All optimistic updates follow the same pattern:
1. Update local state immediately
2. Send request to database
3. On success: invalidate relevant caches
4. On error: revert local state to pre-action state

### 5.4 Pending State Reconciliation

The `FeedNotifier` maintains Sets of pending action IDs (`_likedIds`, `_dislikedIds`, `_unlikedIds`, `_undislikedIds`). When fresh data arrives from the server (via `build()`, `refresh()`, or `loadMore()`), the `_applyPending()` method re-applies these pending states to the fresh data, ensuring the UI remains consistent even when server data arrives out of order.

### 5.5 Notification Badge Logic

The notification bell icon displays a red dot when `unreadCountProvider` returns a value > 0. The count is fetched separately from the notification list and invalidated on relevant actions (follow, mark read, etc.).

---

## 6. Error Handling, Validation & User Feedback

### 6.1 Client-Side Validation

| Field | Rule | Location |
|-------|------|----------|
| Username | 3-30 chars, alphanumeric + underscore | RegisterScreen, EditProfileForm |
| Email | Must contain @ | RegisterScreen |
| Password | Min 6 chars | RegisterScreen |
| Post Content | Max 500 chars | CreatePostForm |
| Bio | Max 160 chars | EditProfileForm |
| Story File | Max 50 MB | CreateStorySheet |

### 6.2 Server Error Humanization

The `humaniseAuthError()` function converts Supabase/Postgres errors to user-friendly messages:

| Error Pattern | User Message |
|---------------|-------------|
| Username duplicate (`profiles_username_key`) | "That username is already taken" |
| Email duplicate (`users_email_key`) | "An account with that email already exists" |
| Invalid credentials | "Incorrect email or password" |
| Email not confirmed | "Please verify your email before signing in" |
| Rate limit (`too_many_requests`) | "Too many attempts. Please wait a moment" |
| Weak password | "Password must be at least 6 characters" |
| Network error | "No internet connection" |
| Generic/unrecognized | Error message as-is |

### 6.3 User Feedback Mechanisms

| Feedback Type | Implementation | Duration |
|---------------|----------------|----------|
| Error Snackbar | Red background, error icon, message | 4 seconds |
| Success Snackbar | Green background, check icon, message | 3 seconds |
| Loading Spinner | CircularProgressIndicator in buttons | During operation |
| Haptic Feedback | Light impact on reactions, medium on follow toggle | Immediate |
| Empty States | Icon + text + optional CTA | Persistent |
| Offline Banner | Red 36px banner at bottom, animated | While offline |
| Optimistic Revert | UI reverts on DB error | Immediate |

### 6.4 Connectivity Handling

The `AppLifecycleWrapper` monitors network connectivity:
- Polls DNS servers (8.8.8.8, 1.1.1.1, 208.67.222.222) every 10 seconds
- Initial check delayed by 3 seconds
- Displays animated offline banner when connection lost
- Hides banner when connection restored
- Auto-refreshes Supabase session on app resume

---

# PART 2: TECHNICAL DOCUMENTATION

## 7. Architecture Overview

### 7.1 Architectural Pattern

**Feature-First Layered Architecture:**

```
lib/
├── core/                    # Shared infrastructure
│   ├── constants/           # App-wide constants
│   ├── router/              # GoRouter configuration
│   ├── theme/               # ThemeData, colors, text styles
│   └── utils/               # Utilities (errors, lifecycle, snackbars)
│
├── data/                    # Data layer
│   ├── models/              # Data models (DTOs)
│   ├── repositories/        # Data access logic
│   └── services/            # External service wrappers
│
├── features/                # Feature modules
│   ├── auth/                # Authentication
│   ├── comments/            # Comments & replies
│   ├── feed/                # Home feed
│   ├── notifications/       # Activity notifications
│   ├── post/                # Post creation
│   ├── profile/             # User profiles
│   ├── search/              # User search
│   ├── settings/            # App settings
│   └── stories/             # Stories system
│
├── shared/                  # Cross-cutting components
│   ├── providers/           # Shared providers (theme)
│   └── widgets/             # Reusable widgets
│
└── main.dart                # App entry point
```

### 7.2 Layer Responsibilities

| Layer | Responsibility | Examples |
|-------|----------------|----------|
| **Core** | App-wide configuration | Theme, routing, constants, utilities |
| **Data** | Data access & transformation | Models, repositories, Supabase wrapper |
| **Features** | Business logic & UI per feature | Screens, feature-specific providers |
| **Shared** | Cross-cutting reusable components | PostCard, AvatarWidget, GradientButton |

### 7.3 Entry Point

**File:** `lib/main.dart`

```
main()
  ├── WidgetsFlutterBinding.ensureInitialized()
  ├── Supabase.initialize(url, anonKey)
  ├── SystemChrome.setSystemUIOverlayStyle()
  └── runApp(
        ProviderScope(
          child: AppLifecycleWrapper(
            child: ConsumerApp (GoRouter + Theme)
          )
        )
      )
```

**Widget Tree:**
```
ProviderScope
  └── AppLifecycleWrapper (connectivity + session refresh)
        └── MaterialApp.router
              ├── theme: AppTheme.dark
              ├── routerConfig: GoRouter (with redirect)
              └── debugShowCheckedModeBanner: false
```

### 7.4 File Count Summary

| Category | Files | Approx. Lines |
|----------|-------|---------------|
| Core | 6 | ~766 |
| Data Models | 6 | ~324 |
| Data Repositories | 5 | ~380 |
| Data Services | 1 | ~11 |
| Auth Feature | 4 | ~485 |
| Feed Feature | 3 | ~687 |
| Post Feature | 3 | ~431 |
| Profile Feature | 5 | ~890 |
| Notifications Feature | 3 | ~220 |
| Comments Feature | 2 | ~661 |
| Stories Feature | 4 | ~1380 |
| Search Feature | 2 | ~118 |
| Settings Feature | 3 | ~340 |
| Shared Widgets | 7 | ~1015 |
| Shared Providers | 1 | ~5 |
| Main + Secrets | 2 | ~52 |
| Tests | 1 | ~30 |
| **Total** | **~52** | **~7,395** |

---

## 8. Database Schema

### 8.1 Inferred Schema (from Repository Queries)

> **Note:** The actual SQL schema is managed in Supabase dashboard. The following is inferred from code usage patterns.

### 8.2 Tables

#### `profiles`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | UUID | PK, FK -> auth.users.id | Same as Supabase auth user ID |
| `username` | TEXT | UNIQUE, NOT NULL | Lowercase, 3-30 chars |
| `full_name` | TEXT | NOT NULL | Display name |
| `bio` | TEXT | NULLABLE | Max 160 chars |
| `avatar_url` | TEXT | NULLABLE | Public URL from storage |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Registration timestamp |
| `updated_at` | TIMESTAMPTZ | NULLABLE | Last profile update |

**Unique Constraints:**
- `profiles_username_key` on `username`

---

#### `posts`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | UUID | PK | Auto-generated |
| `user_id` | UUID | FK -> profiles.id | Post author |
| `content` | TEXT | NOT NULL | Max 500 chars |
| `image_url` | TEXT | NULLABLE | Public URL from storage |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Post timestamp |

---

#### `likes`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | UUID/INT | PK | Auto-generated |
| `user_id` | UUID | FK -> profiles.id | User who liked |
| `post_id` | UUID | FK -> posts.id | Post that was liked |

**Unique Constraint:** Likely `(user_id, post_id)` composite unique (prevents double-likes)

---

#### `dislikes`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | UUID/INT | PK | Auto-generated |
| `user_id` | UUID | FK -> profiles.id | User who disliked |
| `post_id` | UUID | FK -> posts.id | Post that was disliked |

**Unique Constraint:** Likely `(user_id, post_id)` composite unique

---

#### `comments`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | UUID | PK | Auto-generated |
| `user_id` | UUID | FK -> profiles.id | Comment author |
| `post_id` | UUID | FK -> posts.id | Post being commented on |
| `content` | TEXT | NOT NULL | Comment text |
| `parent_id` | UUID | FK -> comments.id, NULLABLE | Parent comment (for replies) |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Comment timestamp |

---

#### `follows`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | UUID/INT | PK | Auto-generated |
| `follower_id` | UUID | FK -> profiles.id | User who is following |
| `following_id` | UUID | FK -> profiles.id | User being followed |

**Unique Constraint:** Likely `(follower_id, following_id)` composite unique

---

#### `notifications`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | UUID | PK | Auto-generated |
| `user_id` | UUID | FK -> profiles.id | Notification recipient |
| `actor_id` | UUID | FK -> profiles.id | User who triggered notification |
| `type` | TEXT | NOT NULL | 'follow', 'like', 'dislike', 'comment', 'reply' |
| `post_id` | UUID | FK -> posts.id, NULLABLE | Associated post |
| `comment_id` | UUID | FK -> comments.id, NULLABLE | Associated comment |
| `is_read` | BOOLEAN | DEFAULT false | Read status |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Notification timestamp |

---

#### `stories`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | UUID | PK | Auto-generated |
| `user_id` | UUID | FK -> profiles.id | Story author |
| `media_url` | TEXT | NOT NULL | Public URL from storage |
| `media_type` | TEXT | NOT NULL | 'image' or 'video' |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Story creation timestamp |

---

#### `story_views`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `story_id` | UUID | FK -> stories.id | Story being viewed |
| `viewer_id` | UUID | FK -> profiles.id | User who viewed |

**Composite PK:** `(story_id, viewer_id)`

---

#### `story_likes`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `story_id` | UUID | FK -> stories.id | Story being liked |
| `user_id` | UUID | FK -> profiles.id | User who liked |

**Composite PK:** `(story_id, user_id)`

---

### 8.3 Storage Buckets

| Bucket | Purpose | Path Pattern |
|--------|---------|--------------|
| `avatars` | User profile pictures | `{userId}/avatar.{ext}` |
| `post-images` | Post image attachments | `{userId}/{timestamp}.jpg` |
| `stories` | Story media | Generated by Supabase upload |

### 8.4 Entity Relationships

```
auth.users (1) ──── (1) profiles
                       │
                       ├── (1:N) posts
                       │         │
                       │         ├── (1:N) likes
                       │         ├── (1:N) dislikes
                       │         └── (1:N) comments
                       │                    │
                       │                    └── (1:N) comments (replies, self-ref)
                       │
                       ├── (N:M) follows (self-referential)
                       │
                       ├── (1:N) notifications (as recipient)
                       ├── (1:N) notifications (as actor)
                       │
                       ├── (1:N) stories
                       │         │
                       │         ├── (1:N) story_views
                       │         └── (1:N) story_likes
                       │
                       └── (1:N) comments (as author)
```

---

## 9. Data Layer & Repository Documentation

### 9.1 SupabaseService

**File:** `lib/data/services/supabase_service.dart`

Single source of truth for Supabase client access. This is the **only** file in the entire codebase that imports `supabase_flutter` directly.

```dart
SupabaseService.client          // SupabaseClient
SupabaseService.currentUser     // User?
SupabaseService.currentUserId   // String?
SupabaseService.currentSession  // Session?
```

---

### 9.2 AuthRepository

**File:** `lib/data/repositories/auth_repository.dart`

| Method | Signature | Description |
|--------|-----------|-------------|
| `authStateChanges` | `Stream<AuthState>` | Real-time auth state stream |
| `signUp` | `Future<void>` | Creates account with metadata |
| `signIn` | `Future<void>` | Authenticates with credentials |
| `signOut` | `Future<void>` | Clears current session |

---

### 9.3 PostsRepository

**File:** `lib/data/repositories/posts_repository.dart`

| Method | Signature | Description |
|--------|-----------|-------------|
| `getFeedPosts` | `Future<List<PostModel>>` | Paginated feed with all joins |
| `getUserPosts` | `Future<List<PostModel>>` | User-specific posts with joins |
| `createPost` | `Future<PostModel>` | Create post, optional image upload |
| `deletePost` | `Future<void>` | Delete post by ID |
| `likePost` | `Future<void>` | Remove dislike + insert like |
| `unlikePost` | `Future<void>` | Delete like |
| `dislikePost` | `Future<void>` | Remove like + insert dislike |
| `undislikePost` | `Future<void>` | Delete dislike |
| `getPostLikes` | `Future<List<UserModel>>` | Users who liked a post |
| `getPostDislikes` | `Future<List<UserModel>>` | Users who disliked a post |

**Query Pattern for Feed/Posts:**
```dart
_db.from('posts')
  .select('*, profiles!user_id(*), likes(post_id), dislikes(post_id), comments(post_id)')
  .order('created_at', ascending: false)
  .limit(20)
  .lt('created_at', cursor) // for pagination
```

---

### 9.4 UsersRepository

**File:** `lib/data/repositories/users_repository.dart`

| Method | Signature | Description |
|--------|-----------|-------------|
| `getOwnProfile` | `Future<UserModel?>` | Current user's profile |
| `getProfileStats` | `Future<ProfileStatsModel?>` | Profile + counts + follow status |
| `updateProfile` | `Future<UserModel>` | Update profile, optional avatar upload |
| `followUser` | `Future<void>` | Create follow relationship |
| `unfollowUser` | `Future<void>` | Remove follow relationship |
| `getFollowers` | `Future<List<UserModel>>` | List of followers |
| `getFollowing` | `Future<List<UserModel>>` | List of following users |
| `searchUsers` | `Future<List<UserModel>>` | ILIKE search on username/full_name |

---

### 9.5 CommentsRepository

**File:** `lib/data/repositories/comments_repository.dart`

| Method | Signature | Description |
|--------|-----------|-------------|
| `getComments` | `Future<List<CommentModel>>` | Top-level comments with replies |
| `addComment` | `Future<CommentModel>` | Create comment or reply |
| `deleteComment` | `Future<void>` | Delete comment by ID |

---

### 9.6 NotificationsRepository

**File:** `lib/data/repositories/notifications_repository.dart`

| Method | Signature | Description |
|--------|-----------|-------------|
| `getNotifications` | `Future<List<NotificationModel>>` | 50 notifications with joins |
| `getUnreadCount` | `Future<int>` | Count of unread notifications |
| `markAsRead` | `Future<void>` | Mark single notification read |
| `markAllAsRead` | `Future<void>` | Mark all notifications read |
| `deleteNotification` | `Future<void>` | Delete notification |

---

### 9.7 StoriesRepository

**File:** `lib/data/repositories/stories_repository.dart`

| Method | Signature | Description |
|--------|-----------|-------------|
| `getActiveStories` | `Future<List<UserStories>>` | Stories from last 24h, grouped by user |
| `createStory` | `Future<StoryModel>` | Upload media + create story record |
| `markViewed` | `Future<void>` | Upsert story view |
| `likeStory` | `Future<void>` | Upsert story like |
| `unlikeStory` | `Future<void>` | Delete story like |
| `deleteStory` | `Future<void>` | Delete story |
| `getStoryViewers` | `Future<List<UserModel>>` | Viewers of a story |

---

## 10. State Management

### 10.1 Riverpod Provider Registry

| Provider | Type | Scope | Feature |
|----------|------|-------|---------|
| `routerProvider` | Provider | Global | Core routing |
| `themeProvider` | Provider | Global | Theme mode (dark only) |
| `authRepositoryProvider` | Provider | Global | Auth repository |
| `authStateProvider` | StreamProvider | Global | Auth state stream |
| `authNotifierProvider` | AsyncNotifierProvider | Global | Sign in/up/out |
| `postsRepositoryProvider` | Provider | Global | Posts repository |
| `feedProvider` | AsyncNotifierProvider | Global | Feed state |
| `createPostProvider` | NotifierProvider | Global | Create post form state |
| `usersRepositoryProvider` | Provider | Global | Users repository |
| `ownProfileProvider` | FutureProvider | Global | Current user profile |
| `profileStatsProvider` | FutureProvider.family | Per userId | Profile stats |
| `userPostsProvider` | FutureProvider.family | Per userId | User's posts |
| `followProvider` | NotifierProvider | Global | Follow/unfollow state |
| `editProfileProvider` | NotifierProvider | Global | Edit profile form state |
| `commentsRepositoryProvider` | Provider | Global | Comments repository |
| `commentsProvider` | AsyncNotifierProvider.family | Per postId | Comments for a post |
| `commentInputProvider` | NotifierProvider | Global | Comment input state |
| `notificationsRepositoryProvider` | Provider | Global | Notifications repository |
| `notificationsProvider` | AsyncNotifierProvider | Global | Notifications list |
| `unreadCountProvider` | FutureProvider | Global | Unread notification count |
| `storiesRepositoryProvider` | Provider | Global | Stories repository |
| `storiesProvider` | AsyncNotifierProvider | Global | Stories list |
| `createStoryProvider` | NotifierProvider | Global | Create story form state |
| `searchQueryProvider` | StateProvider | Global | Search text |
| `searchResultsProvider` | FutureProvider.family | Per query | Search results |
| `notificationSettingsProvider` | NotifierProvider | Global | Notification preferences |

### 10.2 Provider Patterns Used

**AsyncNotifier (Complex async state):**
- Used for: Feed, Comments, Notifications, Stories, Auth actions
- Manages loading, error, data states with `AsyncValue`
- Supports `build()` for initialization, custom async methods

**Notifier (Synchronous state):**
- Used for: Create post form, Edit profile form, Follow toggle, Comment input, Create story, Settings
- Manages plain state with synchronous updates

**FutureProvider (One-shot async):**
- Used for: Own profile, Profile stats, User posts, Unread count, Search results
- Simple async fetch, auto-caching

**FutureProvider.family (Parameterized async):**
- Used for: Profile stats (by userId), User posts (by userId), Comments (by postId), Search results (by query), Reactions (by postId)

**StreamProvider (Reactive stream):**
- Used for: Auth state changes from Supabase

**StateProvider (Simple reactive value):**
- Used for: Search query text

### 10.3 Cache Invalidation Strategy

Cache invalidation is performed explicitly after mutations:

| Mutation | Invalidated Providers |
|----------|----------------------|
| Sign out | N/A (session cleared, redirect) |
| Create post | `feedProvider`, `profileStatsProvider`, `userPostsProvider` |
| Delete post | `feedProvider`, `userPostsProvider` |
| Like/Dislike | N/A (optimistic update, no cache invalidation needed) |
| Follow/Unfollow | `profileStatsProvider`, `unreadCountProvider` |
| Update profile | N/A (returns updated model) |
| Add comment | `commentsProvider` (local append) |
| Delete comment | `commentsProvider` (local remove) |
| Create story | `storiesProvider` (refresh) |
| Mark notification read | `unreadCountProvider` |
| Delete notification | `unreadCountProvider` |

---

## 11. Authentication & Authorization

### 11.1 Authentication Protocol

- **Method:** Email + Password via Supabase Auth
- **Session:** JWT token, auto-persisted by Supabase SDK
- **Metadata:** `full_name`, `username`, `avatar_url` stored in `auth.users.user_metadata`

### 11.2 Session Lifecycle

```
[App Launch]
    |
    v
Supabase.initialize()
    |
    v
SplashScreen checks currentSession
    |
    +-- Session exists --> /home
    +-- No session --> /login

[App Resume from Background]
    |
    v
AppLifecycleWrapper detects resumed state
    |
    v
Check session expiry
    |
    +-- Expires within 5 min --> refreshSession()
    +-- Still valid --> No action
```

### 11.3 Authorization Model

**Access Control:** Route-based, binary (authenticated vs unauthenticated)

| Route Category | Access |
|----------------|--------|
| Public | `/`, `/login`, `/register` |
| Protected | All other routes |

**Authorization Enforcement:** GoRouter `redirect` callback checks `Supabase.instance.client.auth.currentSession != null`

**Data-Level Authorization:** Handled by Supabase Row Level Security (RLS) policies (configured in Supabase dashboard, not visible in codebase). Expected policies:
- Users can only update their own profile
- Users can only delete their own posts/comments/stories
- Notifications are only visible to the recipient

### 11.4 Role Model

Single user role - no admin/moderator distinction in the current implementation. All authenticated users have identical permissions.

---

## 12. Routing System

### 12.1 GoRouter Configuration

**File:** `lib/core/router/app_router.dart`

### 12.2 Route Table

| Route Constant | Path | Screen | Auth |
|----------------|------|--------|------|
| `splash` | `/` | `SplashScreen` | No |
| `login` | `/login` | `LoginScreen` | No |
| `register` | `/register` | `RegisterScreen` | No |
| `home` | `/home` | `HomeScreen` | Yes |
| `createPost` | `/create-post` | `CreatePostScreen` | Yes |
| `notifications` | `/notifications` | `NotificationsScreen` | Yes |
| `profile` | `/profile` | `ProfileScreen` | Yes |
| `otherProfile` | `/profile/:userId` | `OtherProfileScreen` (same widget, different param) | Yes |
| `editProfile` | `/profile/edit` | `EditProfileScreen` | Yes |
| `settings` | `/settings` | `SettingsScreen` | Yes |

### 12.3 Redirect Logic

```
redirect: (context, state) {
  hasSession = currentSession != null
  loc = state.matchedLocation
  isAuthPage = loc in ['/', '/login', '/register']

  if (!hasSession && !isAuthPage)  --> '/login'
  if (hasSession && loc == '/login') --> '/home'
  otherwise --> null (no redirect)
}
```

### 12.4 Non-Routed Screens

These screens are pushed via `Navigator.push` rather than GoRouter:
- `StoryViewerScreen` - Full-screen story viewer
- `CommentsSheet` - DraggableScrollableSheet (modal bottom sheet)
- `ReactionsSheet` - Modal bottom sheet
- `CreateStorySheet` - Modal bottom sheet
- `UserSearchDelegate` - SearchDelegate via `showSearch`

---

## 13. Third-Party Integrations

### 13.1 Supabase (Backend-as-a-Service)

**Package:** `supabase_flutter ^2.5.6`

| Service | Usage |
|---------|-------|
| Auth | Email/password authentication, session management |
| Database | PostgreSQL via REST API (all data operations) |
| Storage | File storage for avatars, post images, story media |
| Realtime (Postgres channels) | Not used in Flutter app |
| FCM mobile push | Implemented (`NotificationService`, `device_tokens`, Edge `send-push`) |
| Web Push | Skipped (`push_subscriptions` table unused by app) |

**Configuration:**
- URL: `https://lmohyfcmiftvuluhyaqh.supabase.co`
- Anon Key: Stored in `lib/core/secrets.dart`

### 13.2 Image Picker

**Package:** `image_picker ^1.1.2`

| Usage | Source |
|-------|--------|
| Post images | Gallery only |
| Profile avatar | Camera or Gallery |
| Story media | Camera, Gallery, or Video |

### 13.3 Video Player

**Package:** `video_player ^2.9.2`

- Used exclusively in StoryViewerScreen for video story playback
- Initialized with network URL
- Auto-play/pause on story transition

### 13.4 Cached Network Image

**Package:** `cached_network_image ^3.3.1`

- Used for all network images: avatars, post images, story media
- Provides placeholder and error widget support
- Automatic disk caching

### 13.5 Shared Preferences

**Package:** `shared_preferences ^2.3.2`

- Used exclusively for notification settings persistence
- Keys: `push_enabled`, `followers_enabled`, `likes_enabled`, `dislikes_enabled`, `comments_enabled`, `replies_enabled`

### 13.6 Other Dependencies

| Package | Version | Usage |
|---------|---------|-------|
| `timeago` | ^3.6.1 | Relative time formatting ("2h ago") |
| `intl` | ^0.19.0 | Not actively used (declared) |
| `shimmer` | ^3.0.0 | Loading skeleton animations (story circles) |
| `flutter_secure_storage` | ^9.2.2 | Declared but not actively used |

---

## 14. Real-Time Features & Async Operations

### 14.1 Real-Time Features

**Current Status (2026-07-18):**

| Channel | Status |
|---------|--------|
| Supabase **Realtime** (`onPostgresChanges`) | **Not used** in Flutter for feed/notifications |
| **Auth** stream | Used (`authStateProvider`) |
| **FCM** mobile push | Implemented — delivery when app is background/killed; foreground FCM also refreshes badge/list |
| In-app list without FCM | Pull-to-refresh / open screen / mark-read invalidation |

**Implications:**
- Feed does not auto-update via Realtime when others post
- Notification **rows** appear on next fetch; **live in-app badge without FCM** still requires a Realtime subscription (planned — see [notifications/PENDING.md](notifications/PENDING.md))
- OS push (Android/iOS) is separate from Supabase Realtime

### 14.2 Asynchronous Operations

**All data operations are async and follow this pattern:**

```
User Action (UI)
    |
    v
Notifier Method (optimistic update)
    |
    v
Repository Method (DB call)
    |
    +-- Success --> Invalidate caches
    +-- Error --> Revert optimistic state, show error
```

**Key Async Operations:**

| Operation | Optimistic | Error Revert |
|-----------|------------|--------------|
| Like/Dislike post | Yes | Yes |
| Follow/Unfollow | Yes | Yes |
| Like story | Yes | Yes |
| Create post | No (loading state only) | Yes (error display) |
| Create story | No (loading state only) | Yes (error display) |
| Add comment | Yes (local append) | Not explicitly reverted |
| Delete post | Yes (local remove) | Yes (error revert) |
| Delete comment | Yes (local remove) | Not explicitly reverted |
| Delete notification | Yes (local remove) | Not explicitly reverted |

---

## 15. System Execution Flow

### 15.1 Feed Loading Flow

```
[HomeScreen builds]
    |
    v
FeedNotifier.build()
    |
    v
PostsRepository.getFeedPosts()
    |
    v
SupabaseClient.from('posts').select('*, profiles, likes, dislikes, comments')
    |
    v
[Supabase REST API responds with JSON]
    |
    v
[JSON mapped to List<PostModel>]
    |
    v
FeedNotifier._applyPending() - re-applies optimistic state
    |
    v
[UI renders PostCard widgets]
```

### 15.2 Post Creation Flow

```
[User taps Post button in CreatePostScreen]
    |
    v
CreatePostNotifier.submit()
    |
    +-- canSubmit == false --> Return (no action)
    +-- canSubmit == true --> Continue
    |
    v
isSubmitting = true
    |
    v
PostsRepository.createPost(content, imageFile)
    |
    +-- imageFile != null:
    |     ├── Upload to Storage: avatars/{userId}/{timestamp}.jpg
    |     └── Get public URL
    |
    v
SupabaseClient.from('posts').insert({user_id, content, image_url})
    |
    v
[Supabase responds with created post]
    |
    +-- Success:
    |     ├── submitted = true
    |     ├── ref.invalidate(feedProvider)
    |     ├── ref.invalidate(profileStatsProvider)
    |     ├── ref.invalidate(userPostsProvider)
    |     └── Navigator.pop()
    |
    +-- Error:
    |     ├── error = exception
    |     └── isSubmitting = false
```

### 15.3 Like Post Flow (Optimistic)

```
[User taps Like chip on PostCard]
    |
    v
FeedNotifier.toggleLike(postId)
    |
    v
[Optimistic Update]
  - If currently liked: _unlikedIds.add(postId)
  - If not liked: _likedIds.add(postId)
  - _dislikedIds.remove(postId), _undislikedIds.remove(postId)
  - UI updates immediately via _applyPending()
    |
    v
[DB Sync]
  - PostsRepository.likePost(postId)
  - Inside repo: undislikePost() (if disliked) -> insert like
    |
    +-- Success:
    |     ├── _likedIds.remove(postId)
    |     ├── _unlikedIds.remove(postId)
    |     └── Clean state, UI consistent with DB
    |
    +-- Error:
    |     ├── _likedIds.remove(postId)
    |     ├── _unlikedIds.remove(postId)
    |     └── UI reverts to pre-action state
```

### 15.4 Follow User Flow (Optimistic)

```
[User taps Follow button on OtherProfileScreen]
    |
    v
FollowNotifier.toggle()
    |
    v
[Optimistic Update]
  - isFollowing = !isFollowing
  - HapticFeedback.mediumImpact()
  - UI updates immediately
    |
    v
[DB Sync]
  - If following: UsersRepository.followUser(userId)
  - If unfollowing: UsersRepository.unfollowUser(userId)
    |
    +-- Success:
    |     ├── isFollowing = finalState
    |     ├── ref.invalidate(profileStatsProvider)
    |     ├── ref.invalidate(unreadCountProvider)
    |     └── Clean state
    |
    +-- Error:
    |     ├── isFollowing = !finalState (revert)
    |     └── showErrorSnackBar()
```

### 15.5 Story Viewing Flow

```
[User taps Story Circle in StoryCirclesRow]
    |
    v
Navigator.push(StoryViewerScreen)
    |
    v
StoryViewerScreen.initState()
  - SystemChrome.setEnabledSystemUIMode(immersiveSticky)
  - _timer starts for current story
    |
    v
[Media renders: CachedNetworkImage or VideoPlayer]
    |
    v
[User gesture or timer triggers next story]
    |
    v
_nextStory() or _nextUser()
  - markViewed(storyId) -> Supabase upsert
    |
    v
[All stories viewed or user dismisses]
    |
    v
Navigator.pop()
StoryViewerScreen.dispose()
  - SystemChrome.restoreSystemUI()
  - _timer.cancel()
  - videoPlayer.dispose()
```

---

## 16. Security Considerations

### 16.1 Identified Security Concerns

| Issue | Severity | Location | Description |
|-------|----------|----------|-------------|
| **Hardcoded Credentials** | HIGH | `lib/core/secrets.dart` | Supabase URL and anon key are hardcoded in source. Should use environment variables or a secrets management solution. |
| **Anon Key Exposure** | MEDIUM | Runtime | The Supabase anon key is embedded in the app binary and can be extracted. Supabase RLS policies MUST be properly configured. |
| **No Input Sanitization** | LOW | Multiple | User inputs are passed directly to Supabase queries. Relying on Supabase parameterization (safe) but no client-side sanitization. |
| **No Rate Limiting** | MEDIUM | Client | No client-side rate limiting on actions (likes, follows, comments). Server-side rate limiting depends on Supabase configuration. |
| **Broken Test** | LOW | `test/widget_test.dart` | Test references `MyApp` which doesn't exist. Provides false sense of test coverage. |

### 16.2 Security Best Practices (Current)

- Supabase auth session handled by SDK (secure token management)
- Sign-out properly clears session
- No sensitive data stored in SharedPreferences
- `flutter_secure_storage` declared but unused (could be leveraged)

### 16.3 RLS Policy Requirements (Supabase Dashboard)

The following Row Level Security policies should be configured:

```sql
-- profiles: Users can read all, update only own
-- posts: Users can read all, create as own, delete own
-- likes/dislikes: Users can read all, create/delete own
-- comments: Users can read all, create as own, delete own
-- follows: Users can read all, create/delete own
-- notifications: Users can only read their own
-- stories: Users can read all, create as own, delete own
-- story_views: Users can create own views
-- story_likes: Users can read all, create/delete own
```

---

## 17. Performance Optimizations

### 17.1 Implemented Optimizations

| Optimization | Location | Description |
|--------------|----------|-------------|
| **Image Caching** | All network images | `CachedNetworkImage` with automatic disk caching |
| **Pagination** | Feed, Notifications | Cursor-based pagination (20/30 items per page) |
| **Optimistic UI** | Reactions, Follow, Stories | Immediate UI feedback before server confirmation |
| **Pending State Reconciliation** | FeedNotifier | Maintains action Sets to reconcile fresh DB data |
| **Cached Profile Stats** | profileStatsProvider | FutureProvider caches until invalidated |
| **Shimmer Loading** | StoryCirclesRow | Animated loading skeleton instead of blank space |
| **Session Auto-Refresh** | AppLifecycleWrapper | Proactively refreshes session before expiry |
| **Video Player Disposal** | StoryViewerScreen | Video player properly disposed on story transition |

### 17.2 Potential Performance Concerns

| Concern | Impact | Location |
|---------|--------|----------|
| **Full Join Queries** | Database load | Feed/posts queries join 4 tables (profiles, likes, dislikes, comments) |
| **No Image Compression** | Upload bandwidth | Post images uploaded at 85% quality without size limit |
| **No Story Cleanup** | Storage growth | Expired stories never deleted from database or storage |
| **No Debounce on Search** | API calls | Every keystroke triggers a new search query |
| **Video Preloading** | Bandwidth | Video stories not preloaded, may cause buffering |
| **No Feed Caching** | Network calls | Feed refetched on every app launch/return |
| **N+1 Query Pattern** | Database load | `getProfileStats()` makes 5 separate queries instead of one |

---

# PART 3: OPERATIONAL & DEVELOPER RESOURCES

## 18. Setup & Deployment

### 18.1 Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | >=3.0.0 | Framework |
| Dart SDK | Bundled with Flutter | Language |
| Xcode | Latest (macOS) | iOS builds |
| Android Studio / SDK | Latest | Android builds |
| Git | Any | Version control |

### 18.2 Environment Setup

```bash
# 1. Clone repository
git clone <repository-url>
cd Entangl_app

# 2. Install dependencies
flutter pub get

# 3. Run code generation (for Riverpod annotations, if used)
dart run build_runner build

# 4. Run the app
flutter run
```

### 18.3 Supabase Configuration

The application requires a Supabase project with the following:

1. **Database Tables:** profiles, posts, likes, dislikes, comments, follows, notifications, stories, story_views, story_likes
2. **Storage Buckets:** `avatars`, `post-images`, `stories` (public access)
3. **Auth Settings:** Email/password enabled
4. **RLS Policies:** As documented in Section 16.3

**Credentials:** Currently hardcoded in `lib/core/secrets.dart`:
```dart
class Secrets {
  static const supabaseUrl = 'https://lmohyfcmiftvuluhyaqh.supabase.co';
  static const supabaseAnonKey = '...';
}
```

### 18.4 Build Commands

```bash
# Generate app icons
flutter pub run flutter_launcher_icons

# Analyze code
flutter analyze

# Run tests
flutter test

# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release

# Build iOS
flutter build ios --release
```

### 18.5 Platform-Specific Configuration

**Android:**
- Package: `entangl_app`
- Min SDK: Flutter default (21)
- Permissions: INTERNET, ACCESS_NETWORK_STATE
- Launch mode: singleTop
- Soft input mode: adjustResize

**iOS:**
- Bundle display name: "Connect"
- Bundle name: `entangl_app`
- Orientations: Portrait, Landscape Left, Landscape Right

---

## 19. Developer Handoff Notes

### 19.1 Code Conventions

- **Naming:** camelCase for variables/methods, PascalCase for classes, UPPER_SNAKE for constants
- **File naming:** snake_case (e.g., `home_screen.dart`, `auth_provider.dart`)
- **Organization:** Feature-first with layered subdirectories
- **Widget structure:** ConsumerWidget/ConsumerStatefulWidget for Riverpod integration

### 19.2 Important Patterns

**Riverpod Provider Creation:**
```dart
// Repository provider
final myRepositoryProvider = Provider((ref) => MyRepository());

// AsyncNotifierProvider
class MyNotifier extends AsyncNotifier<MyState> {
  @override
  Future<MyState> build() async => ...;
  Future<void> myAction() async { ... }
}
final myProvider = AsyncNotifierProvider<MyNotifier, MyState>(MyNotifier.new);

// NotifierProvider
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => MyState();
  void myAction() { ... }
}
final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);
```

**Optimistic Update Pattern:**
```dart
Future<void> toggleAction(String id) async {
  // 1. Optimistic update
  state = AsyncData(applyPending(state.value!, id));

  try {
    // 2. DB call
    await repository.doAction(id);
    // 3. Clean up pending state
  } catch (e) {
    // 4. Revert
    state = AsyncData(revertPending(state.value!, id));
    showErrorSnackBar(context, e.toString());
  }
}
```

### 19.3 Known Technical Debt

| Issue | Impact | Priority |
|-------|--------|----------|
| Hardcoded Supabase credentials | Security risk | HIGH |
| Broken test file | False coverage | MEDIUM |
| Unused dependencies (intl, flutter_secure_storage) | Bundle size | LOW |
| No .gitignore for secrets.dart | Credential leak | HIGH |
| Light theme defined but unused | Dead code | LOW |
| Web manifest colors don't match app | Brand inconsistency | LOW |
| No database migrations in repo | Setup friction | MEDIUM |

### 19.4 Adding a New Feature

**To add a new screen:**
1. Create screen file in `lib/features/<feature>/screens/`
2. Add route to `AppRoutes` class in `lib/core/router/app_router.dart`
3. Add route definition to GoRouter routes list
4. Create provider in `lib/features/<feature>/providers/`
5. Create repository method in appropriate repository file
6. Add navigation from existing screens

**To add a new model:**
1. Create file in `lib/data/models/`
2. Define class with `fromJson()`, `toJson()`, `copyWith()` methods
3. Add JSON key mapping
4. Import in relevant repositories

### 19.5 Adding a New Provider Type

```dart
// 1. Define state class
class MyState {
  final String data;
  final bool isLoading;
  MyState({this.data = '', this.isLoading = false});
  MyState copyWith({String? data, bool? isLoading}) => ...
}

// 2. Define notifier
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => MyState();

  void updateData(String newData) {
    state = state.copyWith(data: newData);
  }
}

// 3. Define provider
final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);

// 4. Use in widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProvider);
    return ...
  }
}
```

---

## 20. QA/Testing Scenarios

### 20.1 Authentication Test Scenarios

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| AUTH-001 | Successful registration | Enter valid name, username, email, password; tap Create Account | Account created, navigated to /home |
| AUTH-002 | Duplicate username | Register with existing username | Error: "That username is already taken" |
| AUTH-003 | Duplicate email | Register with existing email | Error: "An account with that email already exists" |
| AUTH-004 | Short username | Register with username < 3 chars | Validation error, form not submitted |
| AUTH-005 | Invalid username chars | Register with username containing spaces/special chars | Validation error |
| AUTH-006 | Short password | Register with password < 6 chars | Validation error |
| AUTH-007 | Invalid email | Register with email missing @ | Validation error |
| AUTH-008 | Successful login | Enter correct email/password | Navigated to /home |
| AUTH-009 | Failed login | Enter incorrect email/password | Error: "Incorrect email or password" |
| AUTH-010 | Sign out | Tap Log Out from profile | Session cleared, navigated to /login |
| AUTH-011 | Session persistence | Close app, reopen | Session persists, navigated to /home |
| AUTH-012 | Session expiry | Wait for session to expire, use app | Session refreshed or redirected to /login |
| AUTH-013 | Uppercase username | Register with uppercase username | Username stored as lowercase |

### 20.2 Feed Test Scenarios

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| FEED-001 | Feed loads | Open /home with posts in DB | Posts displayed in chronological order |
| FEED-002 | Empty feed | Open /home with no posts | "Nothing here yet" with "Create post" CTA |
| FEED-003 | Pull to refresh | Pull down on feed | Feed reloads |
| FEED-004 | Infinite scroll | Scroll to bottom | Next 20 posts loaded |
| FEED-005 | Like post | Tap like chip on post | Like count increments, chip turns primary |
| FEED-006 | Unlike post | Tap liked chip again | Like count decrements, chip returns to default |
| FEED-007 | Dislike post | Tap dislike chip on post | Dislike count increments, chip turns error |
| FEED-008 | Dislike replaces like | Like post, then dislike | Like removed, dislike added |
| FEED-009 | Like replaces dislike | Dislike post, then like | Dislike removed, like added |
| FEED-010 | Delete own post | Tap 3-dot -> Delete on own post | Post removed from feed |
| FEED-011 | Network error on feed | Disable network, open feed | Error state with retry button |
| FEED-012 | Like with network error | Like post with no network | Optimistic update reverts on error |

### 20.3 Post Creation Test Scenarios

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| POST-001 | Text-only post | Type content, tap Post | Post created, appears in feed |
| POST-002 | Post with image | Type content, add image, tap Post | Post with image created |
| POST-003 | Empty post | Tap Post with no content/image | Button disabled, no action |
| POST-004 | Character limit | Type 501+ characters | Counter shows negative, still submittable |
| POST-005 | Image picker | Tap "Add photo" | Gallery opens |
| POST-006 | Remove image | Tap X on image preview | Image cleared, button state updates |
| POST-007 | Navigate to story creation | Tap "Story" button in app bar | CreateStorySheet opens |

### 20.4 Profile Test Scenarios

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| PROF-001 | Own profile loads | Navigate to /profile | Profile with stats displayed |
| PROF-002 | Other profile loads | Tap user avatar/name | Other user's profile with Follow button |
| PROF-003 | Follow user | Tap Follow on other profile | Button changes to "Following", stats update |
| PROF-004 | Unfollow user | Tap Following on other profile | Button changes to "Follow", stats update |
| PROF-005 | Follow revert on error | Follow with network error | Button reverts to "Follow" |
| PROF-006 | Edit profile | Navigate to /profile/edit, change fields, save | Profile updated |
| PROF-007 | Avatar upload | Tap avatar camera icon, select image | Avatar updated |
| PROF-008 | Username validation | Edit username to < 3 chars | Validation error |
| PROF-009 | Bio character limit | Type 161+ chars in bio | Counter prevents or shows overflow |
| PROF-010 | Followers tab | Tap Followers count | List of followers displayed |
| PROF-011 | Following tab | Tap Following count | List of following displayed |
| PROF-012 | Posts tab empty | View profile of user with no posts | "No posts yet" empty state |
| PROF-013 | Navigate from follow list | Tap user in followers/following list | Navigate to their profile |
| PROF-014 | k formatting | View profile with 1000+ followers | Shows "1.0k" format |

### 20.5 Comments Test Scenarios

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| COM-001 | Open comments | Tap comment chip on post | CommentsSheet slides up |
| COM-002 | Add comment | Type text, tap send | Comment appears in list |
| COM-003 | Reply to comment | Tap "Reply" on comment | Reply banner appears, submit adds reply |
| COM-004 | Delete own comment | Tap delete on own comment, confirm | Comment removed |
| COM-005 | Delete own reply | Tap delete on own reply | Reply removed |
| COM-006 | Empty comments | Open comments on post with no comments | "No comments yet" or empty state |
| COM-007 | Dismiss sheet | Drag down or tap close | Sheet closes |
| COM-008 | Comment count update | Add comment, dismiss sheet | Post comment count increments |

### 20.6 Stories Test Scenarios

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| STORY-001 | Story circles load | Open /home with active stories | Circles with gradient rings displayed |
| STORY-002 | Story circles loading | Open /home, stories fetching | Shimmer skeleton displayed |
| STORY-003 | View story | Tap story circle | Full-screen viewer opens |
| STORY-004 | Navigate stories | Tap right/left side of screen | Next/previous story displayed |
| STORY-005 | Pause story | Long press on screen | Story pauses |
| STORY-006 | Resume story | Release long press | Story resumes |
| STORY-007 | Auto-advance | Wait for timer | Automatically advances to next story |
| STORY-008 | Like story | Tap heart button | Like count increments |
| STORY-009 | Create story (photo) | Tap +, select photo, share | Story appears in circles row |
| STORY-010 | Create story (video) | Tap +, select video, share | Story with video indicator appears |
| STORY-011 | File size limit | Attempt to upload >50MB file | Error snackbar displayed |
| STORY-012 | View viewers | Tap 3-dot -> View viewers on own story | Bottom sheet with viewer list |
| STORY-013 | Delete story | Tap 3-dot -> Delete on own story | Story removed |
| STORY-014 | Story expiration | View stories older than 24h | Not displayed in circles row |
| STORY-015 | System UI | View story | Status bar hidden |
| STORY-016 | System UI restore | Dismiss story viewer | Status bar restored |

### 20.7 Notifications Test Scenarios

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| NOTIF-001 | Notification badge | Have unread notifications | Red dot on bell icon |
| NOTIF-002 | Open notifications | Tap bell icon | Notifications list displayed |
| NOTIF-003 | Mark as read | Tap notification | Read, navigates to actor profile |
| NOTIF-004 | Mark all read | Tap "Mark all read" | All notifications marked read |
| NOTIF-005 | Delete notification | Swipe to dismiss | Notification deleted |
| NOTIF-006 | Empty notifications | No notifications | "You're all caught up" displayed |
| NOTIF-007 | Notification types | Receive each type | Correct icon and color displayed |

### 20.8 Search Test Scenarios

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| SEARCH-001 | Open search | Tap search icon | SearchDelegate opens |
| SEARCH-002 | Empty query | Open search without typing | "Search by name or @username" |
| SEARCH-003 | Valid query | Type existing username | Matching results displayed |
| SEARCH-004 | No results | Type non-existent query | "No results for 'query'" |
| SEARCH-005 | Navigate to profile | Tap search result | Navigate to /profile/$id |
| SEARCH-006 | Case insensitivity | Type username in different case | Results match (ILIKE) |

### 20.9 Settings Test Scenarios

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| SET-001 | Toggle notification setting | Toggle any setting | Setting persists across app restarts |
| SET-002 | Open settings | Navigate to /settings | Three sections displayed |
| SET-003 | Log out from settings | Tap Log Out | Session cleared, navigated to /login |
| SET-004 | Change password stub | Tap Change Password | "Coming soon" snackbar |
| SET-005 | Privacy settings stub | Tap Privacy Settings | "Coming soon" snackbar |
| SET-006 | Delete account | Tap Delete Account | Button muted, no action |

### 20.10 Connectivity Test Scenarios

| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| CONN-001 | Offline detection | Disable network | Red offline banner appears |
| CONN-002 | Online restoration | Re-enable network | Offline banner disappears |
| CONN-003 | Offline banner animation | Toggle network repeatedly | Banner animates in/out |

### 20.11 Edge Cases

| ID | Scenario | Expected Behavior |
|----|----------|-------------------|
| EDGE-001 | Rapid-fire likes | Each toggle processed, final state correct |
| EDGE-002 | Follow/unfollow rapidly | Final state matches last action |
| EDGE-003 | Navigate to own profile via /profile/:userId | Should work, shows own profile actions |
| EDGE-004 | Deep link to /profile/nonexistentId | Should show error or empty state |
| EDGE-005 | App killed during upload | Upload incomplete, no orphaned records |
| EDGE-006 | Very long username | Truncated or wrapped in UI |
| EDGE-007 | Very long bio | Truncated at 160 chars |
| EDGE-008 | Image upload during slow network | Loading state maintained, timeout handled |
| EDGE-009 | Video story on slow network | Buffering state, error on timeout |
| EDGE-010 | Multiple story circles, rapid tapping | Story viewer opens for tapped user |

---

## 21. Known Limitations & Future Improvements

### 21.1 Current Limitations

| Limitation | Description | Impact |
|------------|-------------|--------|
| **No Supabase Realtime for feed/notif list** | No Postgres channel subscriptions in app | In-app list/badge need pull or FCM foreground refresh |
| **Unread count not RPC** | Client counts unread rows | Heavier than `get_unread_notification_count` |
| **Type prefs local-only** | Settings sub-toggles do not filter FCM send | May still receive muted types |
| **No Image Compression** | Images uploaded at original size | Slow uploads, high storage usage |
| **No Story Cleanup** | Expired stories never deleted | Database and storage grow indefinitely |
| **No Pagination for Comments** | All comments loaded at once | Performance degradation on posts with many comments |
| **Search debounce** | Implemented in custom search screen (300ms) | — resolved |
| **Single Theme** | Light theme defined but not used | No user theme choice |
| **Admin features** | Admin requests + approval flow exist | Partial (not full moderation suite) |
| **Push notifications** | FCM + Edge Function implemented | Ops verify + iOS plist may still be needed |
| **No Post Editing** | Posts can be created and deleted but not edited | Users cannot fix typos |
| **No Direct Messaging** | No chat/messaging feature | Limited social interaction |
| **No Hashtags/Mentions** | No content discovery mechanism | Hard to find relevant content |
| **No Bookmarks/Saves** | Cannot save posts for later | No personal content curation |
| **Broken Tests** | Default Flutter test doesn't match app | No meaningful test coverage |
| **Hardcoded Secrets** | Credentials in source code | Security risk, difficult to manage environments |
| **No Analytics** | No event tracking or crash reporting | No usage insights |

### 21.2 Recommended Improvements

| Priority | Improvement | Description |
|----------|-------------|-------------|
| **HIGH** | Environment variables | Move Supabase credentials to .env file |
| **HIGH** | RLS policies | Ensure all tables have proper Row Level Security |
| **HIGH** | Write tests | Implement meaningful widget and unit tests |
| **HIGH** | Notification Realtime + RPC count | See [notifications/PENDING.md](notifications/PENDING.md) |
| **MEDIUM** | Supabase Realtime for feed | Optional live feed inserts |
| **MEDIUM** | Image compression | Compress images before upload |
| **MEDIUM** | Story cleanup | Implement edge function to delete expired stories |
| **MEDIUM** | Server notification prefs | Enforce Settings type toggles in `send-push` |
| **MEDIUM** | Feed caching | Cache feed locally for offline viewing |
| **LOW** | iOS FCM readiness | `GoogleService-Info.plist` + APNs if shipping iOS push |
| **LOW** | Light theme | Activate light theme with user toggle |
| **LOW** | Post editing | Add edit functionality for posts |
| **LOW** | Direct messaging | Implement real-time chat |
| **LOW** | Analytics | Integrate Firebase Analytics or similar |
| **LOW** | Crash reporting | Integrate Sentry or Crashlytics |
| **LOW** | Hashtags | Add hashtag parsing and discovery |
| **LOW** | User mentions | Add @mention functionality in posts/comments |
| **LOW** | Bookmarks | Add save/bookmark feature for posts |

### 21.3 Scalability Considerations

| Concern | Current State | Recommendation |
|---------|---------------|----------------|
| **Database queries** | Full joins on every feed load | Consider materialized views or denormalization |
| **Storage** | No cleanup of expired content | Implement lifecycle policies |
| **Network requests** | No request caching | Add dio/http caching layer |
| **State management** | All providers global | Consider scoped providers for isolated state |
| **Image loading** | Single resolution | Implement responsive/resized images |

---

# APPENDIX

## A. Dependency Reference

### Runtime Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.6       # Backend (auth, DB, storage)
  flutter_riverpod: ^2.5.1        # State management
  riverpod_annotation: ^2.3.5     # Provider code generation
  go_router: ^14.2.7              # Declarative routing
  image_picker: ^1.1.2            # Camera/gallery access
  video_player: ^2.9.2            # Video playback
  cached_network_image: ^3.3.1    # Network image caching
  shared_preferences: ^2.3.2      # Local key-value storage
  flutter_secure_storage: ^9.2.2  # Secure storage (unused)
  timeago: ^3.6.1                 # Relative time formatting
  intl: ^0.19.0                   # i18n (unused)
  shimmer: ^3.0.0                 # Loading skeletons
  cupertino_icons: ^1.0.8         # iOS icons
```

### Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0           # Lint rules
  build_runner: ^2.4.12           # Code generation
  riverpod_generator: ^2.4.3      # Riverpod code generator
  flutter_launcher_icons: ^0.14.3 # App icon generation
```

## B. File Structure Reference

```
lib/
├── main.dart
├── core/
│   ├── secrets.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── utils/
│       ├── auth_errors.dart
│       ├── app_lifecycle.dart
│       └── snackbar.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── post_model.dart
│   │   ├── comment_model.dart
│   │   ├── notification_model.dart
│   │   ├── story_model.dart
│   │   └── profile_stats_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── posts_repository.dart
│   │   ├── users_repository.dart
│   │   ├── comments_repository.dart
│   │   ├── notifications_repository.dart
│   │   └── stories_repository.dart
│   └── services/
│       └── supabase_service.dart
├── features/
│   ├── auth/
│   │   ├── providers/auth_provider.dart
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── widgets/auth_field.dart
│   ├── feed/
│   │   ├── providers/feed_provider.dart
│   │   ├── screens/home_screen.dart
│   │   └── widgets/feed_list.dart
│   ├── post/
│   │   ├── providers/create_post_provider.dart
│   │   ├── screens/create_post_screen.dart
│   │   └── widgets/create_post_form.dart
│   ├── profile/
│   │   ├── providers/profile_provider.dart
│   │   ├── screens/
│   │   │   ├── profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   └── widgets/
│   │       ├── profile_header.dart
│   │       ├── follow_list.dart
│   │       └── edit_profile_form.dart
│   ├── notifications/
│   │   ├── providers/notifications_provider.dart
│   │   ├── screens/notifications_screen.dart
│   │   └── widgets/notification_tile.dart
│   ├── comments/
│   │   ├── providers/comments_provider.dart
│   │   └── widgets/comments_sheet.dart
│   ├── stories/
│   │   ├── providers/stories_provider.dart
│   │   ├── screens/story_viewer_screen.dart
│   │   └── widgets/
│   │       ├── story_circles_row.dart
│   │       └── create_story_sheet.dart
│   ├── search/
│   │   ├── providers/search_provider.dart
│   │   └── screens/search_screen.dart
│   └── settings/
│       ├── providers/settings_provider.dart
│       ├── screens/settings_screen.dart
│       └── widgets/settings_section.dart
└── shared/
    ├── providers/theme_provider.dart
    └── widgets/
        ├── connect_nav_bar.dart
        ├── post_card.dart
        ├── gradient_button.dart
        ├── reactions_sheet.dart
        ├── connect_app_bar.dart
        ├── avatar_widget.dart
        └── gradient_text.dart
```

## C. Quick Reference: Provider Usage in Widgets

```dart
// Watching async provider (returns AsyncValue)
final feed = ref.watch(feedProvider);
feed.when(
  data: (posts) => ...,
  loading: () => ...,
  error: (e, st) => ...,
);

// Watching sync notifier provider
final state = ref.watch(createPostProvider);

// Calling notifier method
ref.read(authNotifierProvider.notifier).signIn(email: email, password: password);

// Watching family provider
final stats = ref.watch(profileStatsProvider(userId));

// Invalidating cache
ref.invalidate(profileStatsProvider(userId));
ref.refresh(feedProvider);
```

---

*This documentation is the definitive source of truth for the Connect Flutter application. Last updated May 17, 2026. For any discrepancies between this documentation and the codebase, the codebase takes precedence and this document should be updated accordingly.*
