# Folder Structure

Clean Architecture, feature-first. `core/` holds cross-cutting machinery; every feature under `features/` is a self-contained vertical slice with `data / domain / presentation` layers. See [ARCHITECTURE.md](ARCHITECTURE.md) for the rules behind this layout.

## Annotated tree

```
lib/
├── main.dart                       # Default entrypoint → delegates to dev flavor
├── main_dev.dart                   # flutter run --flavor dev  -t lib/main_dev.dart
├── main_uat.dart                   # flutter run --flavor uat  -t lib/main_uat.dart
├── main_prod.dart                  # flutter run --flavor prod -t lib/main_prod.dart
├── bootstrap.dart                  # Shared startup: AppConfig, Talker, system chrome,
│                                   # Hive init, Firebase, error handlers, ProviderScope
├── app.dart                        # PoselyApp — MaterialApp.router + PoselyTheme
│
├── core/                           # Cross-cutting. Features depend on core, never vice versa.
│   ├── config/
│   │   ├── app_config.dart         # AppConfig + appConfigProvider (overridden in bootstrap)
│   │   ├── flavor.dart             # Flavor enum: dev / uat / prod
│   │   ├── env.dart                # Per-flavor base URLs (REST + WebSocket, /v1)
│   │   └── constants/              # api_endpoints, storage_keys, asset_paths, app_constants
│   ├── theme/                      # Design tokens: colors, typography, spacing, radii,
│   │                               # PoselyTheme (Material 3, dark-first glassmorphism)
│   ├── design/                     # Design-system component kit (Phase 2) — import via
│   │   ├── design.dart             # the barrel; see docs/DESIGN_SYSTEM.md
│   │   ├── glass/                  # GlassPanel, GlassCard frosted surfaces
│   │   ├── buttons/                # PoselyButton (variants/sizes), PoselyIconButton
│   │   ├── chips/                  # PoselyChip selectable filter chip
│   │   ├── inputs/                 # PoselyTextField branded input
│   │   ├── sheets/                 # showPoselyBottomSheet modal sheet
│   │   ├── dialogs/                # showPoselyDialog / showPoselyConfirmDialog
│   │   ├── feedback/               # PoselyToast, PoselySnackbar
│   │   ├── states/                 # EmptyState, SuccessState placeholders
│   │   ├── skeleton/               # ShimmerBox, PoseCardSkeleton, SkeletonGrid
│   │   ├── score/                  # ScoreRing, ScorePill (0..1 AI scores)
│   │   └── common/                 # SectionHeader and shared layout pieces
│   ├── router/                     # appRouterProvider, route names/paths, shell + guards
│   ├── error/                      # Sealed AppException hierarchy, ApiResult<T>, guardApi()
│   ├── network/                    # dioProvider, AuthInterceptor, RetryInterceptor,
│   │                               # TalkerDioLogger wiring, Paginated<T> envelope
│   ├── storage/                    # LocalStorage (Hive boxes: posely_settings /
│   │                               # posely_cache / posely_poses), SecureTokenStorage
│   ├── services/                   # firebase/ (FirebaseBootstrapper), logger/ (Talker),
│   │                               # platform services (permissions, device info, …)
│   └── shared/                     # Cross-feature widgets, extensions, utils, mixins
│
└── features/                       # One directory per feature — the vertical slices
    ├── splash/                     # Boot/redirect screen
    ├── auth/                       # Sign-in/up, social auth, tokens        (Phase 3)
    ├── home/                       # Shell + home dashboard
    ├── pose/                       # Pose library — FULLY EXPANDED BELOW    (Phase 4)
    ├── ai/                         # AI search, generator, pose extraction  (Phases 5–7)
    ├── camera/                     # AI camera, ghost overlay, realtime     (Phases 8–9)
    ├── gallery/                    # Captured photos                        (Phase 10)
    ├── community/                  # Feed, likes, comments, follows         (Phase 11)
    ├── premium/                    # Paywall, subscriptions, entitlements   (Phase 12)
    ├── profile/                    # User profile
    └── settings/                   # Preferences, about, legal; hosts the dev-only
                                    # design gallery screen (route /dev/design-gallery):
                                    # presentation/screens/design_gallery_screen.dart
```

## Canonical feature layout (`features/pose/` as the model)

Every feature follows this exact shape. New features copy it; empty layer folders are omitted until needed.

```
features/pose/
├── data/
│   ├── datasources/
│   │   ├── pose_remote_datasource.dart     # Retrofit API client — throws AppException
│   │   ├── pose_local_datasource.dart      # Hive cache (posely_cache / posely_poses)
│   │   └── pose_mock_datasource.dart       # assets/mock/ JSON — used when useMockData
│   ├── models/
│   │   ├── pose_model.dart                 # freezed DTO, snake_case JSON, toEntity()
│   │   └── pose_category_model.dart
│   └── repositories/
│       └── pose_repository_impl.dart       # Implements domain interface, returns ApiResult
├── domain/
│   ├── entities/
│   │   └── pose_entity.dart                # Pure Dart, no JSON, no Flutter
│   ├── repositories/
│   │   └── pose_repository.dart            # Abstract interface
│   └── usecases/
│       ├── get_poses_usecase.dart          # One class per use case, single call() method
│       └── search_poses_usecase.dart
└── presentation/
    ├── controllers/
    │   └── pose_list_controller.dart       # AsyncNotifier + providers (codegen allowed)
    ├── screens/
    │   ├── pose_library_screen.dart        # One top-level route target per file
    │   └── pose_detail_screen.dart
    └── widgets/
        └── pose_card.dart                  # Feature-private widgets
```

## What belongs where

| Kind of code | Location |
| --- | --- |
| Design tokens, ThemeData | `core/theme/` |
| Design-system components (buttons, glass, chips, …) | `core/design/` — import via the `design.dart` barrel |
| Route table, guards | `core/router/` |
| Dio, interceptors, `Paginated<T>` | `core/network/` |
| `AppException`, `ApiResult`, `guardApi` | `core/error/` |
| Hive boxes, secure token storage | `core/storage/` |
| Widgets used by 2+ features | `core/shared/` (promote — never import across features) |
| API DTOs (JSON) | `features/<f>/data/models/` |
| Business objects (no JSON) | `features/<f>/domain/entities/` |
| Screen state + orchestration | `features/<f>/presentation/controllers/` |
| Anything Flutter-visual for one feature | `features/<f>/presentation/widgets/` |

## Naming conventions

- **Files:** `snake_case.dart`, suffixed by role:
  - `*_screen.dart`, `*_controller.dart`, `*_widget`-free descriptive names for widgets (`pose_card.dart`)
  - `*_repository.dart` (interface) / `*_repository_impl.dart` (implementation)
  - `*_usecase.dart`, `*_datasource.dart`, `*_model.dart` (DTO), `*_entity.dart` (domain)
- **Classes:** `PascalCase` matching the file (`PoseLibraryScreen`, `PoseListController`, `GetPosesUseCase`, `PoseModel`, `PoseEntity`).
- **Providers:** `lowerCamelCase` ending in `Provider` (`appConfigProvider`, `poseRepositoryProvider`, `poseListControllerProvider`).
- **Generated files** (`*.g.dart`, `*.freezed.dart`) are committed and excluded from analysis.

## Import rules

1. **Package imports only** — `import 'package:posely_ai/...';`. Relative imports are banned (`always_use_package_imports` lint).
2. **Features never import other features' internals.** `features/camera/` must not import from `features/pose/`. Code needed by both is promoted to `core/` (usually `core/shared/`) or exposed via a domain contract in core.
3. **Core never imports features.** The dependency arrow is one-way: `features → core`.
4. **Within a feature, respect the layers:** presentation may import domain; data may import domain; domain imports only core error/result types and pure Dart. Presentation must not import `data/` — wiring happens in providers.
5. **Third-party leakage:** Dio/Retrofit types stay in `data/` and `core/network/`; Hive types stay in `data/` and `core/storage/`; Flutter stays out of `domain/`.
