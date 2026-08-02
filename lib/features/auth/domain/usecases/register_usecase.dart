import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';

/// Creates a new account and signs the user in.
class RegisterUseCase {
  /// Creates the use case over the repository.
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  /// Executes the registration and returns the new authenticated user.
  Future<ApiResult<AuthUser>> call({
    required String displayName,
    required String email,
    required String password,
  }) => _repository.register(
    displayName: displayName,
    email: email,
    password: password,
  );
}

/// Provides the registration use case.
final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);
