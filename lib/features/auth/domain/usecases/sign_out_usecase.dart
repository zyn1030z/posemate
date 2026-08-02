import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';

/// Ends the current session.
class SignOutUseCase {
  /// Creates the use case over the repository.
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  /// Clears the stored session; best-effort and never throws.
  Future<void> call() => _repository.signOut();
}

/// Provides the sign-out use case.
final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);
