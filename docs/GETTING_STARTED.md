# Getting Started

## Prerequisites

| Tool | Version | Notes |
| --- | --- | --- |
| Flutter SDK | **3.44.8** | Dart **3.12.2** bundled; project constraint `sdk: ^3.12.0` |
| Android | SDK 35+, JDK 17 | Android Studio or command-line tools |
| iOS (macOS only) | Xcode 16+, CocoaPods | Required for device/simulator builds |
| Git | any recent | |

Verify with `flutter doctor` — all sections for your target platforms should be green.

## Install the SDK

```bash
# Recommended: pin the exact channel/version
git clone https://github.com/flutter/flutter.git -b stable
flutter --version   # expect Flutter 3.44.8 / Dart 3.12.2
```

If your team uses a version manager (e.g. FVM/mise), pin `3.44.8` there instead — the important part is that everyone builds with the same SDK.

## IDE setup

- **VS Code:** install *Flutter* + *Dart* extensions. Add launch configurations per flavor (`program: lib/main_dev.dart`, `args: ["--flavor", "dev"]`, and likewise for uat/prod).
- **Android Studio / IntelliJ:** install the Flutter plugin; create Run Configurations with *Dart entrypoint* = `lib/main_dev.dart` and *Additional run args* = `--flavor dev` (repeat per flavor).
- Enable *format on save*; the repo relies on `require_trailing_commas` so the formatter produces stable diffs.

## First build

```bash
cd posemate
flutter pub get

# Generate freezed / json_serializable / riverpod / retrofit / hive code
dart run build_runner build --delete-conflicting-outputs

flutter run --flavor dev -t lib/main_dev.dart
```

During active development, keep codegen running in watch mode:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Running flavors

| Flavor | Command | Backend | Mock data | Firebase |
| --- | --- | --- | --- | --- |
| dev | `flutter run --flavor dev -t lib/main_dev.dart` | `https://api.dev.posely.app/v1` | **on** | off |
| uat | `flutter run --flavor uat -t lib/main_uat.dart` | `https://api.uat.posely.app/v1` | off | off |
| prod | `flutter run --flavor prod -t lib/main_prod.dart` | `https://api.posely.app/v1` | off | off (Phase 15) |

- A plain `flutter run` (or an IDE launch with no target) boots the **dev** flavor via `lib/main.dart`.
- Android: product flavors `dev`/`uat`/`prod` with applicationId suffixes `.dev`/`.uat`; all three install side-by-side.
- iOS: matching schemes/configurations are documented for Xcode — select the scheme that pairs with your `-t` entrypoint.
- Flavor selection is code-driven: each entrypoint calls `bootstrap(flavor: ...)`, which builds `AppConfig.forFlavor` (base URLs, `useMockData`, `enableFirebase`) and overrides the core providers.

## Mock-data mode

The dev flavor runs with `AppConfig.useMockData = true`: repositories are wired to mock datasources backed by JSON in `assets/mock/`, so the full app is developable with **no backend and no Firebase**. UAT/prod hit the real API (contract in [API_CONTRACTS.md](API_CONTRACTS.md); backend is developed separately, contract-first). To force real API calls in dev, temporarily flip `useMockData` in `lib/core/config/app_config.dart` — do not commit that change.

## Everyday commands

```bash
flutter analyze                                        # must be zero issues
dart run build_runner build --delete-conflicting-outputs
flutter test                                           # must be green
flutter build apk --flavor dev -t lib/main_dev.dart    # flavored artifact
```

## Troubleshooting

**Analyzer / codegen version conflicts.** The dependency graph is deliberately pinned: `custom_lint`/`riverpod_lint` are absent (custom_lint pins analyzer ^8; riverpod_generator 4 needs ^13), and `freezed` resolves to `3.2.6-dev.1` via the lockfile to satisfy analyzer 12. Do **not** run `flutter pub upgrade --major-versions` casually; if `pub get` reports a solver conflict after editing `pubspec.yaml`, restore the lockfile (`git checkout pubspec.lock`) and read the pin comments in `pubspec.yaml` first.

**Stale generated code.** Symptoms: "part file not found", missing `_$X` symbols, or mismatched freezed unions. Fix:

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Corporate proxy / pub mirror.** Set `PUB_HOSTED_URL` and `FLUTTER_STORAGE_BASE_URL` to your mirror, and standard `HTTP(S)_PROXY`/`NO_PROXY` variables before running `flutter pub get`. Gradle may additionally need proxy settings in `~/.gradle/gradle.properties`; CocoaPods respects the shell proxy variables.

**"Firebase disabled" log at startup.** Expected — Firebase ships OFF in every flavor until `flutterfire configure` is run per flavor ([FIREBASE_SETUP.md](FIREBASE_SETUP.md)).

**Flavor mismatch errors on Android** (`applicationId` not found / wrong app installed). Always pass `--flavor` and `-t` together; mixing `--flavor dev` with `main_prod.dart` builds a valid but misconfigured app on purpose — don't.
