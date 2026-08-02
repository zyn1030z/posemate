import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';

/// Signs in with an email/password pair.
class SignInWithEmailUseCase {
  /// Creates the use case over the repository.
  const SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the sign-in and returns the authenticated user.
  Future<ApiResult<AuthUser>> call({
    required String email,
    required String password,
  }) => _repository.signInWithEmail(email: email, password: password);
}

/// Provides the email sign-in use case.
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>(
  (ref) => SignInWithEmailUseCase(ref.watch(authRepositoryProvider)),
);
