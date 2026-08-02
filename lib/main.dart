/// Default entrypoint, so a plain `flutter run` (and IDE launch buttons with
/// no target configured) boots the dev flavor.
///
/// Real flavor entrypoints live next to this file:
/// - `lib/main_dev.dart` — `flutter run --flavor dev -t lib/main_dev.dart`
/// - `lib/main_uat.dart` — `flutter run --flavor uat -t lib/main_uat.dart`
/// - `lib/main_prod.dart` — `flutter run --flavor prod -t lib/main_prod.dart`
library;

import 'package:posely_ai/main_dev.dart' as main_dev;

/// Delegates to the dev flavor entrypoint.
void main() => main_dev.main();
