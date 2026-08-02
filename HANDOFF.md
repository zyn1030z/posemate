# Posely AI — Project Handoff & Build Plan

> **Purpose of this document.** This is a complete, self-contained handoff for continuing
> development of Posely AI on a different machine or with a different AI coding system.
> Read sections 1–5 before writing any code. Section 6 is the immediate next action.
>
> **Status date:** 2026-08-02 · **Phases 1–3 complete, Phase 4 ~85% complete** ·
> `flutter analyze` = 0 issues · `flutter test` = **231 passing, 1 failing** (see §6.1)

---

## 1. Product summary

**Posely AI** — an AI-powered pose assistant. Users browse/search/generate professional
photography pose templates, upload a photo to extract its pose as a transparent overlay,
then open the camera where a translucent "ghost" silhouette guides them into position while
on-device AI scores the pose in realtime, coaches them with voice/text, and auto-captures
when the match is good enough.

- **Package name:** `posely_ai` · **Android appId:** `com.posely.app` (+`.dev`, `.uat`)
- **Design language:** dark-first premium glassmorphism. Emerald `#10B981` primary,
  `#22C55E` accent, slate `#0F172A` background, `#111827` surface. Inter / InterDisplay type.
- **Target:** production release to App Store + Google Play.

---

## 2. Environment setup (READ FIRST — non-obvious)

### 2.1 Flutter SDK

Flutter **3.44.8** / Dart **3.12.2** is installed at `/home/kasm-user/flutter` and is
**not on PATH**. Invoke by absolute path:

```bash
/home/kasm-user/flutter/bin/flutter <cmd>
/home/kasm-user/flutter/bin/dart <cmd>
```

### 2.2 ⚠️ Proxy bypass is mandatory for every network command

The machine exports `http_proxy`/`https_proxy=http://127.0.0.1:3128` (Squid). That proxy
**blocks pub.dev, GitHub, and storage.googleapis.com with HTTP 403**. Direct connections work
fine. The shell profile re-exports these vars on every new shell, so you must strip them
**per command**:

```bash
env -u http_proxy -u https_proxy /home/kasm-user/flutter/bin/flutter pub get
env -u http_proxy -u https_proxy /home/kasm-user/flutter/bin/flutter analyze
env -u http_proxy -u https_proxy /home/kasm-user/flutter/bin/flutter test
env -u http_proxy -u https_proxy /home/kasm-user/flutter/bin/dart run build_runner build --delete-conflicting-outputs
```

Commands that touch only local files (analyze, test) work either way, but using the prefix
uniformly is simplest. **`pub get` will fail confusingly without it.**

### 2.3 Verification gate (run at the end of every phase — all three must pass)

```bash
env -u http_proxy -u https_proxy /home/kasm-user/flutter/bin/dart run build_runner build --delete-conflicting-outputs
env -u http_proxy -u https_proxy /home/kasm-user/flutter/bin/flutter analyze     # must print "No issues found!"
env -u http_proxy -u https_proxy /home/kasm-user/flutter/bin/flutter test        # must print "All tests passed!"
```

The analyzer is configured strictly (`strict-casts`, `strict-inference`, `strict-raw-types`
plus ~45 curated lints). **Zero analyzer issues is the standard — not zero errors.**

### 2.4 Running the app

```bash
flutter run --flavor dev  -t lib/main_dev.dart    # mock data, debug banner
flutter run --flavor uat  -t lib/main_uat.dart
flutter run --flavor prod -t lib/main_prod.dart
```

No device/emulator was available during Phases 1–4, so **the app has never been run on a real
device or emulator.** All verification so far is analyzer + widget/unit tests. Expect first-run
issues (asset loading, permissions, Gradle sync) and budget time for it.

---

## 3. ⚠️ Dependency pins that look wrong but are load-bearing

`pubspec.yaml` contains several floors that are *deliberately* below the newest published
version. They resolve a real analyzer-version conflict graph. **Do not "upgrade to latest"
without re-running the solver and reading the failure.**

| Package | Pin | Why |
|---|---|---|
| `flutter_riverpod` | `^3.3.2` | 3.4.x forces `riverpod_generator` ≥4.0.6 → analyzer ^13, which conflicts with `freezed` |
| `freezed` | `^3.0.0` (resolves **3.2.6-dev.1**) | only line compatible with analyzer 12 in this graph |
| `build_runner` | `^2.4.0` (resolves 2.15.1) | 2.15.2+ needs `meta ^1.18.3`; Flutter 3.44 pins `meta 1.18.0` |
| `hive_ce_generator` | `^1.8.0` | 1.11.3+ needs analyzer ^14, capped by `retrofit_generator` |
| `vector_math` | `^2.2.0` | pinned by `flutter_test` from the SDK |
| `riverpod_lint` / `custom_lint` | **absent** | `custom_lint` pins analyzer ^8; incompatible with `riverpod_generator` 4.x. Re-add both when `custom_lint` supports analyzer ≥9, and re-enable the `plugins: - custom_lint` block in `analysis_options.yaml` |

Resolved key versions: `go_router 17.3.0`, `dio 5.11.0`, `retrofit 4.9.2`,
`hive_ce 2.19.3`, `camera 0.12.0+2`, `google_mlkit_pose_detection 0.15.0`,
`google_sign_in 7.2.0`, `firebase_core 4.12.1`, `in_app_purchase 3.3.0`, `analyzer 12.1.0`.

---

## 4. Architecture & conventions (any new code MUST follow these)

### 4.1 Structure — Clean Architecture, feature-first

```
lib/
  core/            config, theme, design, router, shell, error, network, storage, services, shared
  features/<name>/
    data/          datasources/  models/  repositories/   (+ services/ where a SDK needs isolating)
    domain/        entities/     repositories/  usecases/
    presentation/  controllers/  screens/  widgets/
```

Features: `auth`, `home`, `pose`, `splash`, `settings` (built) · `camera`, `ai`, `gallery`,
`profile`, `community`, `premium` (skeleton dirs exist, empty).

**Import rules:** package imports only (`package:posely_ai/...`), never relative.
A feature must not reach into another feature's internals — cross-feature access goes through
a barrel (see `lib/features/pose/pose.dart`, which `home` consumes). `core` never imports `features`.

### 4.2 Layer contract (the error pipeline)

```
datasource  throws AppException / DioException
   ↓
repository  wraps in guardApi() → returns ApiResult<T>  (ApiSuccess | ApiFailure)
   ↓
controller  folds ApiResult → AsyncValue state, or returns AppException? for one-shot actions
   ↓
UI          renders loading / data / error; shows exception.userMessage to humans
```

- `AppException` is a **sealed** hierarchy in `lib/core/error/app_exception.dart` with
  `AppException.fromDio()` and a human-facing `userMessage` on every subtype.
- `ApiResult<T>` + `guardApi()` in `lib/core/network/api_result.dart`.
- `Paginated<T>` freezed envelope in `lib/core/network/paginated.dart`
  (`items`, `page`, `page_size`, `total_items`, `has_more`).

### 4.3 State management — Riverpod 3.3, **manual providers only**

No Riverpod codegen anywhere (`riverpod_generator` is present only as a transitive
constraint). Write providers by hand:

```dart
final xProvider = Provider<X>((ref) => ...);
final yControllerProvider = AsyncNotifierProvider<YController, YState>(YController.new);
```

**Riverpod 3 API changes that bit us — remember these:**
- `AsyncValue.valueOrNull` **no longer exists** → use `.value`.
- `Override` is **no longer exported** from `flutter_riverpod` → write
  `overrides: [ ... ]` without the `<Override>` type argument.
- **Providers auto-retry failed builds** with exponential backoff by default. For any provider
  whose failure should surface as an error state (all user-facing feature controllers), opt out:
  ```dart
  Duration? _noRetry(int retryCount, Object error) => null;
  final fooProvider = AsyncNotifierProvider<Foo, Bar>(Foo.new, retry: _noRetry);
  ```
  Failing to do this leaves pending timers and makes error-state tests hang (see §6.1).

Three root providers are declared as throwing stubs and **overridden in `bootstrap()`**:
`appConfigProvider`, `localStorageProvider`, `talkerProvider`.

### 4.4 Code style (enforced by the analyzer)

Single quotes · trailing commas everywhere · declared return types · `prefer_final_locals` ·
`omit_local_variable_types` (write `final x =`, not `final Type x =`) · const constructors
wherever possible · newline at EOF · `///` doc comments on every public member ·
never use `[brackets]` in doc comments unless they resolve to a real identifier
(`comment_references` is on) · `unawaited()` for fire-and-forget futures ·
`Color.withValues(alpha:)` not `withOpacity` · `WidgetState*` not `MaterialState*` ·
private named initializing formals (`required this._x`) are supported in Dart 3.12 and preferred.

### 4.5 Codegen

`freezed` 3 syntax requires the `abstract` keyword:

```dart
@freezed
abstract class Pose with _$Pose {
  const factory Pose({required String id, @Default(<String>[]) List<String> tags}) = _Pose;
  factory Pose.fromJson(Map<String, dynamic> json) => _$PoseFromJson(json);
}
```

`build.yaml` sets `field_rename: snake` globally — **the wire format is snake_case and
conversion is automatic**; never add `@JsonKey` just for casing.

### 4.6 Flutter 3.44 specifics encountered

- `CupertinoPageTransitionsBuilder` now lives in the **cupertino** library — import
  `package:flutter/cupertino.dart` in theme files that use it.
- Use `CardThemeData`, `DialogThemeData`, `TabBarThemeData` for the corresponding
  `ThemeData` parameters.
- `DioExceptionType` has a `transformTimeout` member — exhaustive switches must handle it.
- Null-aware map/collection elements are available: `'key': ?maybeNull`.

---

## 5. What is BUILT (Phases 1–4)

122 hand-written Dart files in `lib/` + 35 test files. Full docs live in `docs/`
(`ARCHITECTURE.md`, `API_CONTRACTS.md`, `DESIGN_SYSTEM.md`, `FOLDER_STRUCTURE.md`,
`CODING_STANDARDS.md`, `GETTING_STARTED.md`, `FIREBASE_SETUP.md`, `DEVELOPMENT_PLAN.md`).

### Phase 1 — Architecture & core ✅

- **Flavors:** `Flavor` enum, `Env` endpoints, `AppConfig.forFlavor()`, entrypoints
  `lib/main_{dev,uat,prod}.dart` → `bootstrap(flavor:)`. Android `productFlavors` with
  appId suffixes and per-flavor app names; iOS Info.plist permission strings + portrait lock.
  `dev` flavor sets `useMockData: true`.
- **Networking:** `dioProvider` with `AuthInterceptor` → `RetryInterceptor` → `TalkerDioLogger`.
  Retry covers idempotent GETs only, 2 attempts, exponential backoff + jitter.
- **Storage:** `LocalStorage` interface + `HiveLocalStorage` (boxes `posely_settings`,
  `posely_cache`, `posely_poses`) + `InMemoryLocalStorage` (tests) + `SecureTokenStorage`.
- **Services:** Talker logging, connectivity, haptics, guarded Firebase bootstrap
  (**Firebase is OFF** — `enableFirebase: false` until `flutterfire configure` is run; see
  `docs/FIREBASE_SETUP.md`).
- **Router:** go_router with `RoutePaths`/`RouteNames` for all planned screens.
- **Screens:** animated splash (custom-painted aperture logo), themed route-error screen.

### Phase 2 — Design system ✅

- **Fonts bundled:** Inter 400/500/600/700 + InterDisplay 600/700/800 (+ OFL license).
- **Tokens** (`lib/core/theme/tokens/`): colors (full emerald scale, slate neutrals, semantic,
  glass, `AppColors.forScore(0..1)` at 0.5/0.8 thresholds), typography (incl. `scoreDigits`
  with tabular figures), spacing (4-pt), radius, shadows, durations/curves, gradients
  (`emeraldHero`, `darkVeil`, `glassSheen`, `scoreRing`, `backgroundAurora`), blur sigmas.
  `PoselyColors` `ThemeExtension` carries theme-dependent glass/glow values.
- **`PoselyTheme.dark()` / `.light()`** — full Material 3 component theming.
- **Component kit** (`lib/core/design/`, barrel `design.dart`):
  `GlassPanel`, `GlassCard`, `PoselyButton` (4 variants × 3 sizes, loading, icon, expand),
  `PoselyIconButton`, `PoselyChip`, `PoselyTextField`, `showPoselyBottomSheet`,
  `showPoselyDialog` / `showPoselyConfirmDialog`, `PoselyToast`, `PoselySnackbar`,
  `EmptyState`, `SuccessState`, `ShimmerBox`, `PoseCardSkeleton`, `SkeletonGrid`,
  **`ScoreRing`** (animated sweep-gradient dial — the AI-panel centerpiece), `ScorePill`,
  `SectionHeader`. Plus upgraded `AppErrorView` / `AppLoadingView`.
- **Accessibility baseline:** ≥44px tap targets, semantics labels, reduced-motion respected.
- **Dev storybook** at route `/dev/design-gallery`.
- Persisted `themeModeProvider` (dark default) + dev/UAT flavor ribbon in `PoselyApp`.

### Phase 3 — Authentication ✅

- **Domain:** `AuthUser` (+`AuthUser.guest()`), `SocialProvider`, `AuthRepository`, 7 use cases.
- **Data:** `AuthApiDatasource` + `AuthMockDatasource` (demo account
  **`demo@posely.app` / `posely123`**), `AuthRepositoryImpl` (token + profile + guest-flag
  persistence), `SocialAuthService` isolating Google/Apple/Facebook SDKs
  (cancel → `CancelledException`, misconfiguration → `UnknownException`).
- **Token refresh** in `AuthInterceptor`: single-flight (concurrent 401s share one refresh),
  bare-Dio refresh call (cannot recurse), one-time replay guarded by
  `extra['retriedAfterRefresh']`, failure → clear tokens + `onSessionExpired` callback.
- **`AuthController`** (`AsyncNotifier<AuthUser?>`): session restore, optional biometric gate,
  action methods returning `Future<AppException?>` (null = success) so a failed login never
  poisons session state.
- **Biometric lock** via `local_auth` 3.x (note: it throws `LocalAuthException`, not
  `PlatformException`).
- **Router guards:** `routerRefreshProvider` + redirect table
  (loading → splash only · signed-out → auth routes only · signed-in → away from auth routes).
- **Screens:** onboarding (3 pages, custom-painted visuals), login (social row + guest),
  register (live password-strength meter, server field-error mapping),
  forgot password (anti-enumeration success phase + 30s resend countdown).

### Phase 4 — Pose Library 🔶 ~85%

**Done:**
- **Domain:** `Pose`, `PoseCategory`, `PoseDifficulty`/`PoseGender`, `PoseRepository`, 6 use cases.
- **Data:** `PoseApiDatasource` + `PoseMockDatasource`, `PoseRepositoryImpl`
  (favorites + recently-used persisted in the `posely_poses` Hive box, capped at 12, dedup,
  corrupt-entry tolerant).
- **Mock dataset** `assets/mock/poses.json` — 16 categories, 60 poses, validated by a test
  (unique ids, valid category refs, parseable enums, realistic distributions).
- **App shell** (`lib/core/shell/app_shell.dart`): floating glass bottom bar via
  `StatefulShellRoute.indexedStack` — Home / Poses / **center gradient camera button** /
  Gallery / Profile. Camera and pose-detail are full-screen routes pushed over the bar.
  `ComingSoonScreen` placeholders for not-yet-built tabs.
- **Library UI:** `PoseCard` (+ reusable `PosePreviewImage`), infinite-scroll grid,
  category chips, difficulty/gender bottom-sheet filters, pull-to-refresh, stale-response
  guard on filter changes, optimistic favorites; `PoseDetailScreen` with stats and
  "Use this pose" → camera.
- **Home:** `HomeFeedController` (partial-failure tolerant), time-aware greeting, search
  affordance (stub), category quick row, "Recently used / Trending / Picked for you" rails,
  camera promo banner.

**Not done — carry into the next session:** see §6.

---

## 6. IMMEDIATE NEXT ACTIONS (finish Phase 4)

### 6.1 🔴 Fix the 1 failing test (start here)

**Test:** `test/features/pose/presentation/pose_library_controller_test.dart` →
`"build surfaces a first-page failure as error state"`
**Symptom:** `expectLater(container.read(poseLibraryControllerProvider.future), throwsA(isA<ServerException>()))`
never completes → `TimeoutException after 30s`.
**Root cause:** Riverpod 3.3 auto-retries failed provider builds (§4.3), so the future stays pending.
**Fix:** add the `retry: _noRetry` opt-out to the pose providers, exactly as
`lib/features/home/presentation/controllers/home_feed_controller.dart` (~line 100) already does:

```dart
/// Never auto-retry: the UI offers pull-to-refresh and an explicit retry action.
Duration? _noRetry(int retryCount, Object error) => null;
```

Apply to `poseLibraryControllerProvider`, and review `favoritePoseIdsProvider`,
`poseCategoriesProvider`, and `poseDetailProvider` for the same treatment.

### 6.2 Remaining Phase 4 scope

- [ ] **Cache-aside for library pages** in the `posely_cache` Hive box (page 1 per filter combo,
      TTL, serve-stale-then-refresh). Currently every load hits the datasource.
- [ ] **Collections** (named user groups: create / rename / delete / add / remove pose).
      Only a flat favorites set exists today.
- [ ] **Filter parity with the product spec:** add *people count* and *orientation*
      (`bodyDirection`) filters — currently only category / difficulty / gender.
- [ ] **Unify storage keys.** `PoseRepositoryImpl` uses private literals `'favorites.ids'` /
      `'recent.poses'` while `StorageKeys.favoritePoseIds` / `StorageKeys.lastUsedPoseIds`
      sit unused. Pick the `StorageKeys` constants and delete the literals.
      ⚠️ If any dev build has already written data, add a one-time migration.
- [ ] Update `docs/DEVELOPMENT_PLAN.md` Phase 4 checkboxes when each lands.

### 6.3 Recommended verification improvement

Nothing has run on a device yet. Before Phase 8 (camera) it is worth doing one
`flutter run --flavor dev` on a physical Android device to shake out Gradle/asset/permission
issues while the app is still simple.

---

## 7. REMAINING PHASES (5 → 15)

Each phase ends with the §2.3 gate green and its `docs/DEVELOPMENT_PLAN.md` section checked off.
Backend REST/WS contracts are already specified in **`docs/API_CONTRACTS.md`** — implement
against that document; the backend itself is a separate project and the app runs on mock
datasources until it exists.

### Phase 5 — AI Search
- `POST /poses/search` semantic search wiring + use case; reuse `Paginated<T>`.
- Debounced search controller (`Debouncer` exists in `core/shared/utils/`) with in-flight
  cancellation and a stale-response guard (copy the pattern in `PoseLibraryController`).
- Search screen: suggestion chips, recent searches persisted in Hive, results grid reusing
  `PoseCard`, empty/error states.
- **Wire the Home search card** — it currently shows a "Phase 5" toast
  (marked `// PHASE-5:` in `home_screen.dart`) and `RoutePaths.search` has no route yet.
- Also honor `CategoryQuickRow`'s `// PHASE-5: deep-link category selection via query param`.
- Tests: debounce timing, cancellation, state folds.

### Phase 6 — AI Pose Generator
- Prompt composer UI (scene / style / people count / mood).
- Job flow: `POST /ai/generate-poses` → poll `GET /ai/jobs/{id}` with backoff; Lottie progress.
- Result grid → save generated poses into the library / collections.
- Free-tier quota counter + premium gating hooks (real gating lands in Phase 12).
- Tests: polling controller, timeout/failure paths.

### Phase 7 — Upload Photo → Pose Extraction
- Pick + crop (`image_picker`, `image`), size guard `AppConstants.maxUploadImageBytes`.
- Multipart `POST /ai/extract-pose` with an `Idempotency-Key` header.
- Preview: skeleton overlay on the source photo; save as a reusable template ("My Poses").
- On-device fallback via ML Kit pose detection + selfie segmentation when offline.
- Tests: upload repository, extraction state machine.

### Phase 8 — AI Camera ⭐ (highest-risk phase)
- Camera session controller: lifecycle (pause/resume on app state), lens switch, flash,
  zoom (0.5/1/2.5 presets like the reference UI), tap-to-focus.
- **Ghost silhouette overlay renderer** — the product's core differentiator. Not a white
  outline: a translucent human silhouette at ~30% opacity with soft glow, plus optional
  skeleton. Gestures: move / scale / rotate / flip / opacity slider / lock / hide.
- Guides: rule-of-thirds grid, golden ratio, center line, horizon level via `sensors_plus`.
- Glass camera UI: floating controls, capture button, recent thumbnail, overlay selector.
- Capture pipeline → save via `gal`; `wakelock_plus` during sessions; `permission_handler` flows.
- Route `RoutePaths.camera` currently renders `ComingSoonScreen` — replace it
  (marked `// PHASE-8:` in `app_router.dart`); `PoseDetailScreen`'s "Use this pose" already
  calls `markUsed()` then pushes it.
- Tests: session controller, overlay transform math.

### Phase 9 — Realtime Matching + AI Coach + Auto-Capture
- Pose matcher in an **isolate**: normalized joint angles, similarity score, per-joint deltas.
- Score stream → AI panel HUD (`ScoreRing` + `ScorePill` already built) + silhouette tint feedback.
- Metrics from the spec: pose match, body balance, arm/leg/shoulder/head/hip angles, camera
  distance, face direction, lighting, composition, overall.
- AI coach: TTS phrases via `flutter_tts` ("raise left arm", "lower chin", "perfect!") with
  cooldown + priority so it doesn't chatter.
- Auto-capture: threshold hold (>95%) + eyes-open/smile/face-visible/body-complete checks,
  3-2-1 countdown, haptics.
- Optional WS channel `/ai/pose-score` (protocol framed in `docs/API_CONTRACTS.md`) with
  reconnect/backoff.
- Budget: end-to-end frame latency profiling; throttle ML Kit input frames.
- Tests: matcher math, auto-capture state machine, WS codec.

### Phase 10 — Gallery
- Local index of captures + metadata (pose used, score achieved).
- Grid + detail viewer, compare-with-template view, share (`share_plus`), delete/organize.
- Sync endpoints `/gallery/photos`; replace the Gallery tab `ComingSoonScreen`.

### Phase 11 — Community
- Feed `/community/feed` with `Paginated<T>` infinite scroll; share pose/capture.
- Likes, comments, follow/unfollow with optimistic updates.
- Report/block + moderation hooks (**required for App Store approval of UGC apps**).

### Phase 12 — Premium
- Catalog `/premium/products` + `in_app_purchase`; glass paywall screen.
- Receipt validation `/premium/subscribe`, restore `/premium/restore`.
- Entitlement provider + feature gating (AI generator quota, WS coach, premium poses —
  `Pose.isPremium` and the crown badge already exist in `PoseCard`).
- Replace the Profile tab `ComingSoonScreen`; build Settings, About, Feedback, Notifications,
  Privacy, Terms screens (`RoutePaths` entries already declared).

### Phase 13 — Optimization
- Hive cache hardening: TTL, eviction, versioned migrations; offline mutation queue.
- Image pipeline tuning (`cached_network_image` memCacheWidth sizing, memory caps).
- Startup, frame-drop, isolate profiling; jank fixes; `flutter_displaymode` for 120Hz.
- App size audit.

### Phase 14 — Testing
- Coverage targets for domain + repositories; widget tests for every primary screen state.
- `integration_test` flows: auth, browse, generate, camera session (mocked), purchase.
- Golden tests for design-system components; coverage reporting in CI.

### Phase 15 — Release
- GitHub Actions: analyze + test + build per flavor.
- Fastlane lanes (Android AAB, iOS IPA); Firebase App Distribution for dev/uat.
- **Enable Firebase**: run `flutterfire configure` per flavor, flip `enableFirebase` to `true`
  in `AppConfig.forFlavor` (marked `// PHASE-15:`), add `google-services.json` per Android
  flavor source set and `GoogleService-Info.plist` per iOS scheme — see `docs/FIREBASE_SETUP.md`.
- Signing: replace the debug signing config in `android/app/build.gradle.kts`
  (marked `// PHASE-15:`) with a real upload keystore via `key.properties`.
- iOS: no `Podfile` exists yet (generated on first macOS build) — it will need
  `platform :ios, '15.5'` for ML Kit + Firebase. Create Xcode schemes for dev/uat/prod.
- Store metadata, screenshots, privacy nutrition labels, App Store review notes
  (camera + photo library usage strings are already in `Info.plist`).

---

## 8. Working method that produced this codebase

Phases 1–4 were built by an orchestrator + **parallel subagents** (3–5 per phase), each given
an explicit, exhaustive API contract for the files it owned plus a strict "write these files
only, run no build commands" rule. The orchestrator then ran codegen → analyze → tests and
fixed the seams. Integration friction was consistently low (2–18 analyzer issues per phase,
mostly lint-level).

If you continue with a multi-agent system, the pattern worth copying:

1. **Write the cross-agent contract explicitly** in every prompt — exact class names,
   constructor signatures, provider names, and which files each agent may touch.
2. **Forbid agents from running build commands**; the orchestrator owns codegen/analyze/test.
3. **Tell agents to verify third-party APIs against `~/.pub-cache` sources** rather than
   recalling them. This caught real signature differences in `google_sign_in` 7.x,
   `local_auth` 3.x, and `connectivity_plus` 7.x.
4. Hand every agent §4 of this document (conventions) verbatim.

---

## 9. Quick reference

| Item | Value |
|---|---|
| Demo login (dev flavor) | `demo@posely.app` / `posely123` |
| Design storybook route | `/dev/design-gallery` |
| Mock dataset | `assets/mock/poses.json` — 16 categories, 60 poses |
| Hive boxes | `posely_settings`, `posely_cache`, `posely_poses` |
| Test tally at handoff | **231 passing, 1 failing** (§6.1) |
| Analyzer at handoff | 0 issues |
| Phase status | 1 ✅ · 2 ✅ · 3 ✅ · 4 🔶 ~85% · 5–15 ⬜ |

**Search the codebase for `PHASE-` markers** — every deliberately deferred piece of work is
tagged with the phase that should implement it (e.g. `// PHASE-8: replaced by the real camera
experience.`).
