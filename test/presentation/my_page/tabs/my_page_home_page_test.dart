import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/log/logger.dart';
import 'package:sukimachi/presentation/my_page/my_page_model.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/repository/job_repository.dart';
import 'package:sukimachi/repository/user_repository.dart';
import '../../../container.dart';
import '../../../dummy/dummy_applications.dart';
import '../../../dummy/dummy_comment.dart';
import '../../../dummy/dummy_jobs.dart';
import '../../../dummy/dummy_secret_profils.dart';
import '../../../dummy/dummy_user.dart';
import '../../../repository/auth_repository_mock.dart';
import '../../../repository/job_repository_mock.dart';
import '../../../repository/user_repository_mock.dart';

void main() {
  late ProviderContainer _container;
  late UserRepositoryMock _userRepositoryMock;
  late JobRepositoryMock _jobRepositoryMock;
  late AuthRepositoryMock _authRepositoryMock;

  setUp(() {
    _container = overrideRepository();
    _userRepositoryMock =
        _container.read(userRepositoryProvider) as UserRepositoryMock;
    _jobRepositoryMock =
        _container.read(jobRepositoryProvider) as JobRepositoryMock;
    _authRepositoryMock =
        _container.read(authRepositoryProvider) as AuthRepositoryMock;
  });

  test("退会のチェックのテスト_正常系(user2)", () async {
    await _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    await _authRepositoryMock.authenticate(userId: dummyUserList[2].userRef.id);
    final state = _container.read(myPageProvider);
    await state.initialize();
    final result = await state.whatPreventToDeleteAccount();

    expect(result, null);
  });
  test("退会のチェックのテスト_異常系(user0)", () async {
    await _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    await _authRepositoryMock.authenticate(userId: dummyUserList[0].userRef.id);
    final state = _container.read(myPageProvider);
    await state.initialize();
    final result = await state.whatPreventToDeleteAccount();

    expect(
        result, "・応募中の依頼・契約中の依頼が存在するため退会できません。\n\n依頼・応募を確認してから改めて退会をお願いします。");
  });

  test("退会のチェックのテスト_異常系(user1)", () async {
    await _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    await _authRepositoryMock.authenticate(userId: dummyUserList[0].userRef.id);
    final state = _container.read(myPageProvider);
    await state.initialize();
    final result = await state.whatPreventToDeleteAccount();

    expect(
        result, "・応募中の依頼・契約中の依頼が存在するため退会できません。\n\n依頼・応募を確認してから改めて退会をお願いします。");
  });

  test("退会のテスト_正常系(user2)", () async {
    await _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    await _authRepositoryMock.authenticate(userId: dummyUserList[2].userRef.id);
    final state = _container.read(myPageProvider);
    await state.initialize();
    await state.deleteAccount(showTextDialog: (String title) async {
      logger.severe(title);
    });

    final deletedUser =
        await _userRepositoryMock.fetchUser(dummyUserList[2].userRef.id);
    expect(deletedUser.isDeleted, true);
    expect(_authRepositoryMock.isSignIn, false);
  });
}
