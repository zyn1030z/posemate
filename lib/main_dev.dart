import 'package:posely_ai/bootstrap.dart';
import 'package:posely_ai/core/config/flavor.dart';

/// Entrypoint for the development flavor.
///
/// Run with: `flutter run --flavor dev -t lib/main_dev.dart`
Future<void> main() => bootstrap(flavor: Flavor.dev);
