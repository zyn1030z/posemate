import 'package:posely_ai/bootstrap.dart';
import 'package:posely_ai/core/config/flavor.dart';

/// Entrypoint for the user-acceptance testing flavor.
///
/// Run with: `flutter run --flavor uat -t lib/main_uat.dart`
Future<void> main() => bootstrap(flavor: Flavor.uat);
