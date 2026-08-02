import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';

/// Restores the persisted session at app start.
class RestoreSessionUseCase {
  /// Creates the use case over the repository.
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  /// Returns the restored user, or null when the device is signed out.
  Future<AuthUser?> call() => _repository.restoreSession();
}

/// Provides the session-restore use case.
final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>(
  (ref) => RestoreSessionUseCase(ref.watch(authRepositoryProvider)),
);
