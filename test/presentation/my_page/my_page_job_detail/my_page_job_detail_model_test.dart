import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/application.dart';
import 'package:sukimachi/domain/job.dart';
import 'package:sukimachi/presentation/my_page/my_page_job_detail/my_page_job_detail_model.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/repository/job_repository.dart';
import 'package:sukimachi/repository/user_repository.dart';

import '../../../container.dart';
import '../../../dummy/dummy_applications.dart';
import '../../../dummy/dummy_comment.dart';
import '../../../dummy/dummy_constants.dart';
import '../../../dummy/dummy_jobs.dart';
import '../../../dummy/dummy_secret_profils.dart';
import '../../../dummy/dummy_user.dart';
import '../../../repository/auth_repository_mock.dart';
import '../../../repository/job_repository_mock.dart';
import '../../../repository/user_repository_mock.dart';

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
    await _authRepositoryMock.authenticate();
    final dummyJob = dummyJobList[2];
    final state = _container.read(myPageJobDetailProvider(dummyJob.jobRef.id));
    await state.init();
    expect(state.job, isA<Job>());
    expect(state.applications, isA<List<Application>>());
  });

  test("応募承諾のテスト", () async {
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    for (var dummyJob in dummyJobList) {
      final state =
          _container.read(myPageJobDetailProvider(dummyJob.jobRef.id));
      await state.init();
      for (var application in state.applications!) {
        state.acceptApplication(application);
      }
      await state.init();
      for (var application in state.applications!) {
        expect(application.status, kApplicationStatusAccepted);
      }
    }
  });

  test("応募断りのテスト", () async {
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    for (var dummyJob in dummyJobList) {
      final state =
          _container.read(myPageJobDetailProvider(dummyJob.jobRef.id));
      await state.init();
      for (var application in state.applications!) {
        state.rejectApplication(application);
      }
      await state.init();
      for (var application in state.applications!) {
        expect(application.status, kApplicationStatusRejected);
      }
    }
  });

  test("依頼完了のテスト", () async {
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _authRepositoryMock.authenticate();
    for (var dummyJob in dummyJobList) {
      final state =
          _container.read(myPageJobDetailProvider(dummyJob.jobRef.id));
      await state.init();
      for (var application in state.applications!) {
        state.completeApplication(application);
      }
      await state.init();
      for (var application in state.applications!) {
        expect(application.status, kApplicationStatusDone);
      }
    }
  });

  test("ステータス変更のテスト(未公開→公開)", () async {
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    await _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _authRepositoryMock.authenticate(userId: testUserRef.id);
    final state =
        _container.read(myPageJobDetailProvider(dummyJobList[3].jobRef.id));
    await state.init();
    expect(state.job!.jobStatus, kJobStatusPrivate);
    await state.changeJobStatus();
    expect(state.job!.jobStatus, kJobStatusPublic);
  });

  test("ステータス変更のテスト(公開→募集終了)", () async {
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);

    await _authRepositoryMock.authenticate();
    final state =
        _container.read(myPageJobDetailProvider(dummyJobList[0].jobRef.id));
    await state.init();
    expect(state.job!.jobStatus, kJobStatusPublic);
    await state.changeJobStatus();
    await state.init();
    expect(state.job!.jobStatus, kJobStatusClosed);
  });

  test("ステータス変更のテスト(非公開→公開→募集終了→)", () async {
    await _jobRepositoryMock.set(
        dummyJobList, dummyCommentList, dummyApplications);
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _authRepositoryMock.authenticate(userId: testUserRef.id);
    final state =
        _container.read(myPageJobDetailProvider(dummyJobList[3].jobRef.id));
    await state.init();
    state.changeJobStatus();
    await state.init();
    state.changeJobStatus();
    await state.init();
    expect(() async => await state.changeJobStatus(), throwsA(isA<String>()));
  });
}
