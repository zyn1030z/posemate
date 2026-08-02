import 'package:posely_ai/bootstrap.dart';
import 'package:posely_ai/core/config/flavor.dart';

/// Entrypoint for the production flavor.
///
/// Run with: `flutter run --flavor prod -t lib/main_prod.dart`
Future<void> main() => bootstrap(flavor: Flavor.prod);
