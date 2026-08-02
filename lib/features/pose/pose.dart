/// Public surface of the pose feature — browse, favorite, and use
/// professional pose references.
///
/// Exposes the domain entities and repository contract, the repository
/// provider, the presentation controllers, the canonical pose card,
/// and the library and detail screens.
///
/// Cross-feature consumers (home, router, search) import ONLY this
/// barrel; the internal file layout of the feature is free to change
/// behind it.
library;

export 'package:posely_ai/features/pose/data/repositories/pose_repository_impl.dart';
export 'package:posely_ai/features/pose/domain/entities/pose.dart';
export 'package:posely_ai/features/pose/domain/entities/pose_category.dart';
export 'package:posely_ai/features/pose/domain/entities/pose_enums.dart';
export 'package:posely_ai/features/pose/domain/repositories/pose_repository.dart';
export 'package:posely_ai/features/pose/presentation/controllers/favorite_pose_ids_controller.dart';
export 'package:posely_ai/features/pose/presentation/controllers/pose_detail_controller.dart';
export 'package:posely_ai/features/pose/presentation/controllers/pose_library_controller.dart';
export 'package:posely_ai/features/pose/presentation/screens/pose_detail_screen.dart';
export 'package:posely_ai/features/pose/presentation/screens/pose_library_screen.dart';
export 'package:posely_ai/features/pose/presentation/widgets/pose_card.dart';
