import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';

/// Requests a password-reset email.
class RequestPasswordResetUseCase {
  /// Creates the use case over the repository.
  const RequestPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  /// Requests the reset email for the given address.
  Future<ApiResult<void>> call({required String email}) =>
      _repository.requestPasswordReset(email: email);
}

/// Provides the password-reset use case.
final requestPasswordResetUseCaseProvider =
    Provider<RequestPasswordResetUseCase>(
      (ref) => RequestPasswordResetUseCase(ref.watch(authRepositoryProvider)),
    );
