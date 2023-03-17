import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/job.dart';
import 'package:sukimachi/log/logger.dart';
import 'package:sukimachi/presentation/job_detail/job_detail_model.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/repository/job_repository.dart';
import 'package:sukimachi/repository/user_repository.dart';

import '../../container.dart';
import '../../dummy/dummy_applications.dart';
import '../../dummy/dummy_comment.dart';
import '../../dummy/dummy_constants.dart';
import '../../dummy/dummy_jobs.dart';
import '../../dummy/dummy_secret_profils.dart';
import '../../dummy/dummy_user.dart';
import '../../repository/auth_repository_mock.dart';
import '../../repository/job_repository_mock.dart';
import '../../repository/user_repository_mock.dart';

void main() {
  late ProviderContainer _container;
  late JobRepositoryMock _jobRepositoryMock;
  late UserRepositoryMock _userRepositoryMock;
  late AuthRepositoryMock _authRepositoryMock;

  setUp(() {
    _container = overrideRepository();
    _jobRepositoryMock =
        _container.read(jobRepositoryProvider) as JobRepositoryMock;
    _userRepositoryMock =
        _container.read(userRepositoryProvider) as UserRepositoryMock;
    _authRepositoryMock =
        _container.read(authRepositoryProvider) as AuthRepositoryMock;
  });

  test("JobDetailModelの初期化のテスト", () async {
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    _authRepositoryMock.authenticate(userId: dummyJobList[0].clientRef.id);
    final state = _container.read(jobDetailProvider(dummyJobList[0].jobRef.id));
    await state.init();
    expect(state.job, isA<Job>());

    // 取得したコメント数でcanFetchMoreCommentが適切になっているかの確認
    if (state.jobCommentList!.length == kCommentLoadLimit) {
      expect(state.canFetchMoreComment, true);
      state.fetchMoreJobComment();
      expect(state.jobCommentList!.length >= kCommentLoadLimit, true);
    } else {
      expect(state.canFetchMoreComment, false);
      expect(state.jobCommentList!.length < kCommentLoadLimit, true);
    }
  });

  test("宮路ユーザでテストユーザの依頼を開いた場合", () async {
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _authRepositoryMock.authenticate();
    final state = _container.read(jobDetailProvider(testUserJobRef.id));
    await state.init();
    expect(state.applied, true);
  });

  test("宮路ユーザでスキ街制作を開いた場合", () async {
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    final state = _container.read(jobDetailProvider(miyajiSukimachiJobRef.id));
    await state.init();
    expect(state.applied, false);
  });

  // 自分の応募のため失敗する
  test("宮路ユーザでスキ街制作に応募した場合", () async {
    _jobRepositoryMock.set(dummyJobList, dummyCommentList, dummyApplications);
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _authRepositoryMock.authenticate();
    final state = _container.read(jobDetailProvider(miyajiSukimachiJobRef.id));
    await state.init();
    expect(state.applied, false);
    await state.applyJob(showTextDialog: (String title) async {
      logger.severe(title);
    }, showUserInfoNotRegisteredDialog: (bool isSignIn) async {
      logger.severe('ユーザ情報を登録する必要あり。');
    }, onNotLogin: () async {
      logger.severe('ログインする必要あり。');
    });
    await state.init();
    expect(state.applied, false);
  });

  test("未ログイン状態の場合の応募済みかどうか", () async {
    _jobRepositoryMock.set(dummyJobList, dummyCommentList, dummyApplications);
    final state = _container.read(jobDetailProvider(miyajiSukimachiJobRef.id));
    await state.init();
    expect(state.applied, false);
  });

  test("宮路ユーザでテストユーザの依頼の応募を取り消した場合", () async {
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    await _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _authRepositoryMock.authenticate();
    final state = _container.read(jobDetailProvider(testUserJobRef.id));
    await state.init();
    await state.applyJob(showTextDialog: (String title) async {
      logger.severe(title);
    }, showUserInfoNotRegisteredDialog: (bool isSignIn) async {
      logger.severe('ユーザ情報を登録する必要あり。');
    }, onNotLogin: () async {
      logger.severe('ログインする必要あり。');
    });
    expect(state.applied, true);
    await state.cancelApplication((String title) async {
      logger.severe('$titleを出力');
    });
    expect(state.applied, false);
  });

  // ログイン状態におけるコメントのテスト
  test("コメントのテスト", () async {
    _jobRepositoryMock.set(dummyJobList, dummyCommentList, dummyApplications);
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _authRepositoryMock.authenticate();
    for (var dummyJob in dummyJobList) {
      final state = _container.read(jobDetailProvider(dummyJob.jobRef.id));
      await state.init();
      state.commentController.text = 'コメントのテストを行います';
      await state.sendComment(showTextDialog: (String title) async {
        logger.severe('$titleダイアログを表示');
      }, showUserInfoNotRegisteredDialog: (bool isSignIn) async {
        logger.severe('ユーザ情報登録ダイアログを表示');
      }, onNotLogin: () async {
        logger.severe('ログインダイアログを表示');
      });
      expect(state.commentController.text, '');
    }
  });
}
