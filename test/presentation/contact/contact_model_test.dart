import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/presentation/contact/contact_model.dart';
import 'package:sukimachi/presentation/contact/contact_result.dart';
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

  test("認証済ユーザーの問い合わせ保存テスト", () async {
    await _authRepositoryMock.authenticate();

    final state = _container.read(contactProvider);
    expect(await state.sendContact(), ContactResult.success);
  });

  test("未認証ユーザーの問い合わせ保存テスト", () async {
    final state = _container.read(contactProvider);
    expect(await state.sendContact(), ContactResult.success);
  });
}
