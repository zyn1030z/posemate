# Firebase Setup

> **Current state: Firebase is OFF in the repository.** `AppConfig.enableFirebase` is `false` for all flavors, and `FirebaseBootstrapper.init` skips initialization entirely (logging `Firebase disabled ... skipping init`). The app runs fully without Firebase. This document is the runbook for turning it on, per flavor — scheduled for Phase 15, but it can be done earlier per environment.

## Overview

Each flavor gets its **own Firebase project** so dev noise never pollutes production analytics/crash data:

| Flavor | Firebase project (suggested) | Android applicationId | iOS bundle id |
| --- | --- | --- | --- |
| dev | `posely-ai-dev` | `<base_id>.dev` | `<base_bundle>.dev` |
| uat | `posely-ai-uat` | `<base_id>.uat` | `<base_bundle>.uat` |
| prod | `posely-ai` | `<base_id>` | `<base_bundle>` |

The Android applicationId suffixes (`.dev`, `.uat`) are already configured via product flavors; iOS uses one scheme per flavor.

## 1. Install tooling

```bash
dart pub global activate flutterfire_cli
# and the Firebase CLI: https://firebase.google.com/docs/cli
firebase login
```

## 2. Configure per flavor

Run `flutterfire configure` once **per flavor**, writing a flavor-specific options file:

```bash
flutterfire configure \
  --project=posely-ai-dev \
  --out=lib/firebase_options_dev.dart \
  --android-package-name=<base_id>.dev \
  --ios-bundle-id=<base_bundle>.dev

flutterfire configure \
  --project=posely-ai-uat \
  --out=lib/firebase_options_uat.dart \
  --android-package-name=<base_id>.uat \
  --ios-bundle-id=<base_bundle>.uat

flutterfire configure \
  --project=posely-ai \
  --out=lib/firebase_options_prod.dart \
  --android-package-name=<base_id> \
  --ios-bundle-id=<base_bundle>
```

This generates `lib/firebase_options_{dev,uat,prod}.dart` and downloads platform config files.

## 3. Place platform config files

**Android** — one `google-services.json` per flavor source set (the Google Services Gradle plugin picks the right one by flavor):

```
android/app/src/dev/google-services.json
android/app/src/uat/google-services.json
android/app/src/prod/google-services.json
```

**iOS** — one `GoogleService-Info.plist` per scheme, e.g.:

```
ios/Runner/Firebase/dev/GoogleService-Info.plist
ios/Runner/Firebase/uat/GoogleService-Info.plist
ios/Runner/Firebase/prod/GoogleService-Info.plist
```

with an Xcode build phase that copies the active flavor's plist into the app bundle for the selected scheme (standard multi-scheme Firebase setup).

## 4. Wire options into the app

`FirebaseBootstrapper.init` (`lib/core/services/firebase/firebase_bootstrapper.dart`) currently calls `Firebase.initializeApp()` without options. When the options files exist, pass the flavor's options (e.g. select `DefaultFirebaseOptions.currentPlatform` from the matching `firebase_options_<flavor>.dart` based on `config.flavor`).

## 5. Flip the switch

`enableFirebase` lives in **`lib/core/config/app_config.dart`**, inside `AppConfig.forFlavor` — one boolean per flavor. Flip it to `true` only for flavors whose configuration from steps 2–4 is complete. There is no other switch; `bootstrap()` always calls `FirebaseBootstrapper.init`, which reads this flag.

When enabled, `FirebaseBootstrapper` also **replaces the global error handlers** so fatal Flutter/platform errors go to Crashlytics (mirrored to Talker). Init failures are logged and swallowed — the app never crashes at startup because Firebase is misconfigured.

## 6. Activation checklist (per flavor)

**Crashlytics**
- [ ] Enable Crashlytics in the Firebase console
- [ ] Verify handler takeover: force a test crash, confirm it appears in the console
- [ ] iOS: confirm dSYM upload (Fastlane lane in Phase 15)

**Analytics**
- [ ] Enable Google Analytics on the Firebase project
- [ ] Verify events with DebugView (`--dart-define` / `-FIRDebugEnabled`)
- [ ] Define the initial event taxonomy (screen views, pose_capture, ai_generate, purchase)

**Cloud Messaging (FCM)**
- [ ] iOS: upload the APNs key in Project Settings → Cloud Messaging
- [ ] Request notification permission flow in-app (`firebase_messaging` + `permission_handler`)
- [ ] Token registration with backend; test a campaign to a dev device
- [ ] Android 13+ `POST_NOTIFICATIONS` runtime permission

**Auth (used from Phase 3 for social sign-in)**
- [ ] Enable Google / Apple / Facebook providers in Firebase console
- [ ] Android SHA-1/SHA-256 fingerprints registered per flavor applicationId
- [ ] Apple Sign-In capability + Services ID configured

## Notes

- Do not commit real prod config files if the repo visibility ever changes — treat `google-services.json` / plists per your security policy (CI can inject them; Phase 15).
- `firebase_options_*.dart` files are generated artifacts of `flutterfire configure`; regenerate rather than hand-edit.
- Until this runbook is executed, keep `enableFirebase: false` — everything in the app degrades gracefully (Talker-only error handling, no analytics, no push).
