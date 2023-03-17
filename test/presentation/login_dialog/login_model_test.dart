import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/presentation/login_dialog/login_model.dart';
import 'package:sukimachi/repository/auth_repository.dart';

import '../../container.dart';
import '../../repository/auth_repository_mock.dart';

void main() {
  late ProviderContainer _container;
  late AuthRepositoryMock _authRepositoryMock;

  setUp(() {
    _container = overrideRepository();
    _authRepositoryMock =
        _container.read(authRepositoryProvider) as AuthRepositoryMock;
  });

  test("GoogleSignInのテスト", () async {
    final state = _container.read(loginProvider);
    expect(_authRepositoryMock.isSignIn, false);
    await state.signInWithGoogle();
    expect(_authRepositoryMock.isSignIn, true);
  });
}
