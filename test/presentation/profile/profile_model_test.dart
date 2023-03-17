import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/domain/user.dart';
import 'package:sukimachi/presentation/profile/profile_model.dart';
import 'package:sukimachi/repository/user_repository.dart';

import '../../container.dart';
import '../../dummy/dummy_secret_profils.dart';
import '../../repository/user_repository_mock.dart';
import '../../dummy/dummy_user.dart';

void main() {
  late ProviderContainer _container;
  late UserRepositoryMock _userRepositoryMock;

  setUp(() {
    _container = overrideRepository();
    _userRepositoryMock =
        _container.read(userRepositoryProvider) as UserRepositoryMock;
  });

  test("fetchUser", () async {
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    final dummyUser = dummyUserList[0];
    final state = _container.read(profileProvider(dummyUser.userRef.id));
    await state.init();
    expect(state.user, isA<User>());
  });
}
