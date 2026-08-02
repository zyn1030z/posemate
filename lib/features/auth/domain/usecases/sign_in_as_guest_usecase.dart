import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';

/// Starts a local guest session.
class SignInAsGuestUseCase {
  /// Creates the use case over the repository.
  const SignInAsGuestUseCase(this._repository);

  final AuthRepository _repository;

  /// Marks the device as a guest session and returns the guest identity.
  Future<AuthUser> call() => _repository.signInAsGuest();
}

/// Provides the guest sign-in use case.
final signInAsGuestUseCaseProvider = Provider<SignInAsGuestUseCase>(
  (ref) => SignInAsGuestUseCase(ref.watch(authRepositoryProvider)),
);
