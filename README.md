# Posely AI

**AI-powered pose assistant.** Browse, search, and generate professional pose templates — then recreate them through an AI camera with a ghost silhouette overlay, realtime pose matching, a spoken AI coach, and hands-free auto-capture.

`Flutter 3.44.8` · `Dart 3.12.2` · `Material 3` · `Riverpod 3` · `Clean Architecture` · `dev / uat / prod flavors` · `Proprietary`

---

## Features

### Pose Library & AI
- **Pose library** — curated templates with categories, trending, and personalized recommendations.
- **AI search** — full-text and semantic pose search with filters.
- **AI pose generator** — describe a scene or vibe; an async generation job returns new pose templates.
- **Photo → pose extraction** — upload any reference photo and extract its pose skeleton as a reusable overlay.

### Camera & Coaching
- **AI camera** — live preview with a ghost silhouette overlay of the target pose, grid and level assists.
- **Realtime pose matching** — on-device ML Kit pose detection (33 landmarks) scored against the target in a background isolate, with an optional WebSocket backend scoring channel.
- **AI coach** — spoken, per-joint corrections via text-to-speech while you pose.
- **Auto-capture** — the shutter fires automatically once your match score holds above threshold.

### Social & Monetization
- **Gallery** — captured shots organized locally, saved to the device via `gal`, shareable via `share_plus`.
- **Community** — feed of shared poses with likes, comments, and follows.
- **Premium** — subscriptions through `in_app_purchase` with server-side receipt validation and entitlement gating.

## Screenshots

| Home | Pose Library | AI Camera | Realtime Coach |
| :--: | :----------: | :-------: | :------------: |
| _coming soon_ | _coming soon_ | _coming soon_ | _coming soon_ |

## Quick start

**Requirements:** Flutter **3.44.8** (Dart **3.12.2**), Android SDK and/or Xcode. See [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md) for full setup.

```bash
# 1. Dependencies
flutter pub get

# 2. Code generation (freezed, json_serializable, riverpod, retrofit, hive)
dart run build_runner build --delete-conflicting-outputs

# 3. Run a flavor
flutter run --flavor dev  -t lib/main_dev.dart    # mock data, Firebase off
flutter run --flavor uat  -t lib/main_uat.dart    # staging backend
flutter run --flavor prod -t lib/main_prod.dart   # production backend
```

A plain `flutter run` boots the **dev** flavor (see `lib/main.dart`). Dev runs with `useMockData: true`, so no backend is required to develop. Firebase is disabled in all flavors until `flutterfire configure` is run per flavor — see [docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md).

## Project structure

```
lib/
├── main_dev.dart / main_uat.dart / main_prod.dart   # flavor entrypoints → bootstrap()
├── bootstrap.dart      # startup: config, logging, storage, Firebase, ProviderScope
├── app.dart            # PoselyApp — MaterialApp.router + theme
├── core/               # config, theme, router, error, network, storage, services, shared
└── features/           # auth, home, pose, camera, ai, gallery, profile,
                        # community, premium, settings, splash
                        # each: data / domain / presentation
```

Clean Architecture, feature-first. Details in [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md).

## Documentation

| Document | Contents |
| --- | --- |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Layers, state management, error handling, realtime pipeline, diagrams |
| [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) | Annotated tree, naming conventions, import rules |
| [docs/DEVELOPMENT_PLAN.md](docs/DEVELOPMENT_PLAN.md) | 15-phase roadmap and running checklist |
| [docs/CODING_STANDARDS.md](docs/CODING_STANDARDS.md) | Lints, patterns, commit convention, PR checklist |
| [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md) | Environment setup, flavors, codegen, troubleshooting |
| [docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md) | Per-flavor Firebase configuration |
| [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) | REST/WebSocket backend contract (contract-first) |

## License

Proprietary — all rights reserved (placeholder).
