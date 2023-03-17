import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/domain/category.dart';
import 'package:sukimachi/domain/job.dart';
import 'package:sukimachi/presentation/jobs/jobs_model.dart';
import 'package:sukimachi/repository/job_repository.dart';
import '../../container.dart';
import '../../dummy/dummy_applications.dart';
import '../../dummy/dummy_category.dart';
import '../../dummy/dummy_comment.dart';
import '../../dummy/dummy_jobs.dart';
import '../../repository/job_repository_mock.dart';

void main() {
  late ProviderContainer _container;
  late JobRepositoryMock _jobRepositoryMock;

  setUp(() {
    _container = overrideRepository();
    _jobRepositoryMock =
        _container.read(jobRepositoryProvider) as JobRepositoryMock;
  });

  test("JobsModelの初期化のテスト", () async {
    _jobRepositoryMock.set(dummyJobList, dummyCommentList, dummyApplications);
    final state = _container.read(jobsProvider);
    await state.init();
    expect(state.jobs, isA<List<Job?>>());
    expect(state.categories, isA<List<Category>>());
    expect(state.selectedCategories.length, 0);
  });

  test("カテゴリの選択のテスト", () async {
    _jobRepositoryMock.set(dummyJobList, dummyCommentList, dummyApplications);
    final state = _container.read(jobsProvider);
    await state.init();
    expect(state.selectedCategories.length, 0);
    state.onSelected(true, dummyCategory[0]);
    expect(state.selectedCategories.length, 1);
  });

  test("11番目のカテゴリを選択した場合のテスト", () async {
    _jobRepositoryMock.set(dummyJobList, dummyCommentList, dummyApplications);
    final state = _container.read(jobsProvider);
    await state.init();
    expect(state.selectedCategories.length, 0);
    for (var i = 0; i < 10; i++) {
      state.onSelected(true, dummyCategory[i]);
    }
    expect(state.selectedCategories.length, 10);
    expect(() => state.onSelected(true, dummyCategory[10]),
        throwsA(const TypeMatcher<String>()));
    expect(state.selectedCategories.length, 10);
  });

  test("選択していたカテゴリの選択を解除した場合のテスト", () async {
    _jobRepositoryMock.set(dummyJobList, dummyCommentList, dummyApplications);
    final state = _container.read(jobsProvider);
    await state.init();
    expect(state.selectedCategories.length, 0);
    for (var i = 0; i < 10; i++) {
      state.onSelected(true, dummyCategory[i]);
    }
    expect(state.selectedCategories.length, 10);
    state.onSelected(false, dummyCategory[5]);
    expect(state.selectedCategories.length, 9);
  });

  test("選択していたカテゴリが空になった場合のテスト", () async {
    _jobRepositoryMock.set(dummyJobList, dummyCommentList, dummyApplications);
    final state = _container.read(jobsProvider);
    await state.init();
    expect(state.selectedCategories.length, 0);
    state.onSelected(true, dummyCategory[0]);
    expect(state.selectedCategories.length, 1);
    state.onSelected(false, dummyCategory[0]);
    expect(state.selectedCategories.length, 0);
  });
}
