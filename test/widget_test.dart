import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posely_ai/app.dart';
import 'package:posely_ai/core/config/app_config.dart';
import 'package:posely_ai/core/config/constants/app_constants.dart';
import 'package:posely_ai/core/config/flavor.dart';
import 'package:posely_ai/core/services/logger/app_logger.dart';
import 'package:posely_ai/core/shared/widgets/posely_logo.dart';
import 'package:posely_ai/core/storage/local_storage.dart';
import 'package:posely_ai/features/splash/presentation/screens/splash_screen.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  testWidgets('app boots into the branded splash screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.forFlavor(Flavor.dev)),
          localStorageProvider.overrideWithValue(InMemoryLocalStorage()),
          talkerProvider.overrideWithValue(TalkerFlutter.init()),
        ],
        child: const PoselyApp(),
      ),
    );

    // Advance partway through the entrance animation — the splash holds
    // for minSplashDuration, so it must still be on screen here.
    // Intentionally NOT pumpAndSettle: the splash animates and navigates.
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(PoselyLogo), findsWidgets);

    // Flush the splash hold timer and the resulting navigation so no
    // timers are left pending when the test tears down.
    await tester.pump(AppConstants.minSplashDuration);
    await tester.pump(const Duration(seconds: 1));
  });
}
