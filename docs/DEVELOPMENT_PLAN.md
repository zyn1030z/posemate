# Development Plan

> **Living document — updated at the end of every phase.** Check off tasks as they land; a phase is done only when its checklist is complete **and** the verification gates pass.

**Verification gates (every phase):**
- `flutter analyze` — zero issues
- `dart run build_runner build --delete-conflicting-outputs` — clean
- `flutter test` — green

---

## Phase 1 — Architecture & Dependencies ✅

- [x] Flutter 3.44.8 / Dart 3.12.2 SDK setup, project scaffold (`posely_ai`)
- [x] Dependency resolution — full stack pinned (Riverpod 3, go_router 17, freezed 3, dio 5 + retrofit 4, hive_ce, ML Kit, Firebase, IAP; see pubspec notes for analyzer-driven pins)
- [x] Analysis config — strict-casts/inference/raw-types + curated lint set (`analysis_options.yaml`)
- [x] Core config & flavors — `Flavor`, `Env`, `AppConfig.forFlavor`, dev/uat/prod entrypoints, `bootstrap()`, Android productFlavors (`.dev`/`.uat` suffixes), iOS schemes documented
- [x] Theme tokens — brand palette (emerald #10B981 / #22C55E, dark #0F172A / #111827), Material 3 dark-first `PoselyTheme`
- [x] Error / network / storage core — sealed `AppException`, `ApiResult<T>` + `guardApi()`, `Paginated<T>`, `dioProvider` with Auth/Retry/Talker interceptors, Hive boxes + `SecureTokenStorage`
- [x] Router + splash + home shell — go_router table, splash redirect, bottom-nav shell
- [x] Tests — bootstrap/config/error/pagination unit tests green
- [x] Docs — README + docs/ set (this file, ARCHITECTURE, FOLDER_STRUCTURE, CODING_STANDARDS, GETTING_STARTED, FIREBASE_SETUP, API_CONTRACTS)

## Phase 2 — Design System

- [x] Color system: gradients, semantic roles, glass surfaces on dark palette
- [x] Typography scale + bundled fonts (Inter 400–700, InterDisplay 600–800); spacing/radius/elevation/motion tokens
- [x] Glassmorphism component kit: GlassPanel, GlassCard, blur sheets (`lib/core/design/`, `design.dart` barrel)
- [x] Buttons, inputs, chips, dialogs, toasts, snackbars (Material 3 themed)
- [x] Shimmer skeletons + empty/success state widgets; score ring + score pill
- [x] Flavor banner overlay for dev/uat builds (`PoselyApp` builder ribbon)
- [x] Dev-only component gallery screen (`/dev/design-gallery`)
- [x] Theme-mode setting plumbing (`themeModeProvider`, persisted; dark default)
- [x] Widget tests for core components (buttons, chips, fields, dialogs, sheets, toasts, states, scores, skeletons, theme mode)
- [x] Docs — [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) reference (tokens, catalog, feedback patterns, a11y)

## Phase 3 — Authentication

- [x] Auth feature scaffold: entities, models, repository, use cases
- [x] Token model + `SecureTokenStorage` wiring; refresh rotation in `AuthInterceptor` (401 → refresh → replay; sign-out on refresh failure)
- [x] Email/password sign-in, registration, forgot-password screens
- [x] Social sign-in: Google, Apple, Facebook → `/auth/social-login` exchange
- [x] Biometric app lock via `local_auth`
- [x] Auth controller + go_router guards (splash → auth → shell)
- [x] Mock auth datasource for dev flavor
- [x] Unit + widget tests (controller folds, guard redirects, interceptor refresh)

## Phase 4 — Pose Library

- [ ] Pose/category entities, models, repository, use cases
- [ ] Library screen: category tabs, trending, recommended rails
- [ ] Pose grid with infinite scroll (`Paginated<T>`), pose detail screen
- [ ] Filters (category, difficulty, people count, orientation)
- [ ] Collections: save/unsave, `posely_poses` Hive box
- [ ] Cache-aside for library pages (`posely_cache`)
- [ ] Mock dataset in `assets/mock/`
- [ ] Tests: repository cache logic, controller pagination, widget states

## Phase 5 — AI Search

- [ ] Search endpoint wiring (`/poses/search`) + use case
- [ ] Debounced search controller; query state + cancellation
- [ ] Search UI: suggestions, filters, results grid
- [ ] Recent searches persisted in Hive
- [ ] Empty/error/loading states
- [ ] Tests: debounce, cancellation, state folds

## Phase 6 — AI Pose Generator

- [ ] Prompt composer UI (scene, style, people count)
- [ ] Generate job flow: `POST /ai/generate-poses` → poll `GET /ai/jobs/{id}`
- [ ] Job progress UI (lottie), result grid, retry/regenerate
- [ ] Save generated poses to library/collections
- [ ] Free-tier quota + premium gating hooks
- [ ] Tests: job polling controller, failure/timeout paths

## Phase 7 — Upload → Pose Extraction

- [ ] Photo pick/crop flow (`image_picker`, `image`)
- [ ] Multipart upload to `POST /ai/extract-pose` with idempotency key
- [ ] Extraction preview: skeleton overlay on source photo
- [ ] Save extracted pose as reusable template
- [ ] On-device fallback path via ML Kit for offline extraction
- [ ] Tests: upload repository, extraction state machine

## Phase 8 — AI Camera

- [ ] Camera session controller: lifecycle, lens switch, flash, zoom
- [ ] Ghost silhouette overlay renderer (target pose over preview, opacity/scale controls)
- [ ] ML Kit pose stream wiring (throttled frames)
- [ ] Grid, horizon level (`sensors_plus`), wakelock during sessions
- [ ] Capture pipeline: shutter, EXIF, save via `gal`
- [ ] Permission flows (`permission_handler`)
- [ ] Tests: session controller, overlay math

## Phase 9 — Realtime Matching + AI Coach + Auto-Capture

- [ ] Pose matcher isolate: normalized joint angles, similarity score, per-joint deltas
- [ ] Score stream → HUD + silhouette tint feedback
- [ ] AI coach: TTS correction phrases, cooldown/priority logic
- [ ] Auto-capture: threshold hold, countdown, haptics
- [ ] Optional WS scoring channel (`/ai/pose-score`) with reconnect/backoff
- [ ] Performance budget: end-to-end frame latency profiling
- [ ] Tests: matcher math, auto-capture state machine, WS protocol codec

## Phase 10 — Gallery

- [ ] Gallery feature: local index of captures + metadata (pose used, score)
- [ ] Grid/detail viewer, compare-with-template view
- [ ] Share via `share_plus`; delete/organize
- [ ] Backend sync endpoints wiring (`/gallery/photos`)
- [ ] Tests: repository, viewer states

## Phase 11 — Community

- [ ] Feed (`/community/feed`) with `Paginated<T>` infinite scroll
- [ ] Share capture/pose to community
- [ ] Likes, comments, follow/unfollow
- [ ] Report/block + content moderation hooks
- [ ] Tests: feed controller, optimistic like/comment updates

## Phase 12 — Premium

- [ ] Product catalog (`/premium/products`) + `in_app_purchase` integration
- [ ] Paywall screen (glass design), feature-gate widgets
- [ ] Receipt validation (`/premium/subscribe`), restore (`/premium/restore`)
- [ ] Entitlement provider + route/feature gating (AI generator quota, WS coach)
- [ ] Tests: purchase state machine, entitlement gating

## Phase 13 — Optimization

- [ ] Hive cache hardening: TTL, eviction, versioned migrations
- [ ] Offline mutation queue + connectivity-aware refresh
- [ ] Image pipeline tuning (`cached_network_image` sizing, memory caps)
- [ ] Startup time, frame-drop, and isolate profiling; jank fixes
- [ ] High-refresh display mode (`flutter_displaymode`)
- [ ] App size audit (deferred components / asset trimming)

## Phase 14 — Testing

- [ ] Unit coverage targets for domain + repositories (mocktail fakes)
- [ ] Widget tests for all primary screens/states
- [ ] `integration_test` flows: auth, browse, generate, camera session (mocked), purchase
- [ ] Golden tests for design-system components
- [ ] Coverage reporting wired into CI

## Phase 15 — Release

- [ ] CI/CD: GitHub Actions (analyze, test, build per flavor)
- [ ] Fastlane lanes: Android AAB + iOS IPA per flavor
- [ ] Firebase App Distribution for dev/uat builds
- [ ] `flutterfire configure` per flavor; flip `enableFirebase`; Crashlytics/Analytics/FCM live (see [FIREBASE_SETUP.md](FIREBASE_SETUP.md))
- [ ] Store metadata, screenshots, privacy declarations
- [ ] Versioning + CI build-number bumping; release checklist
