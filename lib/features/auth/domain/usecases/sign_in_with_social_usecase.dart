import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posely_ai/core/network/api_result.dart';
import 'package:posely_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:posely_ai/features/auth/domain/entities/auth_user.dart';
import 'package:posely_ai/features/auth/domain/entities/social_provider.dart';
import 'package:posely_ai/features/auth/domain/repositories/auth_repository.dart';

/// Signs in via a social identity provider.
class SignInWithSocialUseCase {
  /// Creates the use case over the repository.
  const SignInWithSocialUseCase(this._repository);

  final AuthRepository _repository;

  /// Runs the provider flow and returns the authenticated user.
  ///
  /// A user-cancelled flow yields an `ApiFailure` carrying a
  /// `CancelledException`, which callers should treat silently.
  Future<ApiResult<AuthUser>> call(SocialProvider provider) =>
      _repository.signInWithSocial(provider);
}

/// Provides the social sign-in use case.
final signInWithSocialUseCaseProvider = Provider<SignInWithSocialUseCase>(
  (ref) => SignInWithSocialUseCase(ref.watch(authRepositoryProvider)),
);
