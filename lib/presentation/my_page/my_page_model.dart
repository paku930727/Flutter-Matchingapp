import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/domain/application.dart';
import 'package:sukimachi/domain/secret_profile.dart';
import 'package:sukimachi/domain/user.dart';
import 'package:sukimachi/exception/user_null_exception.dart';
import 'package:sukimachi/log/logger.dart';
import 'package:sukimachi/presentation/home/error_message/error_message_controller.dart';
import 'package:sukimachi/repository/job_repository.dart';
import 'package:sukimachi/repository/user_repository.dart';
import '../../domain/job.dart';
import '../../repository/auth_repository.dart';

final myPageProvider =
    ChangeNotifierProvider.autoDispose((ref) => MyPageModel._(
          userRepository: ref.watch(userRepositoryProvider),
          jobRepository: ref.watch(jobRepositoryProvider),
          authRepository: ref.watch(authRepositoryProvider),
          errorMessageController: ref.read(errorMessageProvider),
        ));

/// MyPageのViewModel
class MyPageModel extends ChangeNotifier {
  MyPageModel._(
      {required this.userRepository,
      required this.jobRepository,
      required this.authRepository,
      required this.errorMessageController}) {
    initialize();
  }

  /// UserRepository,DIで挿入
  final UserRepository userRepository;

  /// JobsRepository,DIで挿入
  final JobRepository jobRepository;

  final AuthRepository authRepository;

  final ErrorMessageController errorMessageController;

  /// 自分のプロフィール情報,fetchMyUser()で初期化
  User? currentUser;

  /// 自分の秘匿プロフィール情報
  SecretProfile? secretProfile;

  /// 依頼一覧,fetchMyClientJobs()で初期化
  List<Job> myClientJobs = [];

  /// 受注一覧,fetchMyApplications()で初期化
  List<Application> myApplications = [];

  /// データ取得中の場合、Trueで画面に読み込み状態のIndicatorを示す
  bool isLoading = true;

  /// Userデータを持っていない場合、False
  bool hasUser = false;

  /// Exception, Errorが発生した場合は、True
  bool hasError = false;

  /// errorMessage
  String errorMessage = '';

  /// 初期化
  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    await fetchMyUser();
    await fetchMyClientJobs();
    await fetchMyApplications();
    await fetchMySecretProfile();
    isLoading = false;
    notifyListeners();
  }

  /// ユーザー情報を取得する。
  Future<void> fetchMyUser() async {
    try {
      currentUser = await userRepository.fetchCurrentUserCache();
      if (currentUser != null) {
        hasUser = true;
      }
    } on UserNullException catch (e, st) {
      logger.info(e);
      logger.info(st);
      errorMessageController.addMessage(e.toString());
      notifyListeners();
    } catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      errorMessageController.addMessage(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMySecretProfile() async {
    try {
      secretProfile = await userRepository.fetchSecretProfile();
      notifyListeners();
    } catch (e, st) {
      // secretProfileは登録されていなくても問題ないので握りつぶしても良い
      logger.severe(e);
      logger.severe(st);
    }
  }

  /// 自分の依頼一覧を取得する。
  Future<void> fetchMyClientJobs() async {
    try {
      String uid = authRepository.firebaseUser!.uid;
      myClientJobs = await userRepository.fetchUsersClientJobList(uid: uid);
      notifyListeners();
    } catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      errorMessageController.addMessage(e.toString());
    }
  }

  Future<void> fetchMyApplications() async {
    try {
      String uid = authRepository.firebaseUser!.uid;
      myApplications = await userRepository.fetchUsersApplications(uid: uid);
      notifyListeners();
    } catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      errorMessageController.addMessage(e.toString());
    }
  }

  Future deleteAccount(
      {required Future Function(String title) showTextDialog}) async {
    var message = await whatPreventToDeleteAccount();
    if (message != null) {
      await showTextDialog(message);
      return;
    }

    try {
      await userRepository.deleteAccount(
          currentUser!); //currentUserのnullチェックはwhatPreventToDeleteAccountで実施済み
      await showTextDialog("退会申請をしました。\n退会処理が完了するとメールでお知らせいたします。");
      await authRepository.signOut();
    } catch (exception) {
      await showTextDialog("退会できませんでした。\nもう一度お試しください。");
    }
  }

  // 退会できない理由を返す。退会できる場合はnull
  // 自分が応募している依頼でIN_REVIEWかACCEPTEDの応募が存在しない
  // 自分の依頼の中にIN_REVIEWかACCEPTEDの応募がある依頼が存在しない
  // 自分の依頼の中にPUBLICな依頼が存在しない
  Future<String?> whatPreventToDeleteAccount() async {
    if (currentUser == null) {
      return "ユーザ情報が取得できません。";
    }
    final isExistsMyApplicationInReviewOrAccepted = await userRepository
        .isExistsMyApplicationInReviewOrAccepted(currentUser!);
    final isExistsMyJobHasApplicationInReviewOrAccepted = await userRepository
        .isExistsMyJobHasApplicationInReviewOrAccepted(currentUser!);
    final isExistsMyPublicJobs =
        await userRepository.isExistsMyPublicJobs(currentUser!);

    if (isExistsMyApplicationInReviewOrAccepted ||
        isExistsMyJobHasApplicationInReviewOrAccepted ||
        isExistsMyPublicJobs) {
      return _createTextMessage(
          isExistsMyApplicationInReviewOrAccepted:
              isExistsMyApplicationInReviewOrAccepted,
          isExistsMyJobHasApplicationInReviewOrAccepted:
              isExistsMyJobHasApplicationInReviewOrAccepted,
          isExistsMyPublicJobs: isExistsMyPublicJobs);
    }
    return null;
  }

  String _createTextMessage(
      {required bool isExistsMyApplicationInReviewOrAccepted,
      required bool isExistsMyJobHasApplicationInReviewOrAccepted,
      required bool isExistsMyPublicJobs}) {
    String message = "";
    if (isExistsMyApplicationInReviewOrAccepted) {
      message += "・応募中の依頼・契約中の依頼が存在するため退会できません。\n";
    }
    if (isExistsMyJobHasApplicationInReviewOrAccepted) {
      message += "・依頼に対する応募が来ている、もしくは契約中の依頼が存在するため退会できません。\n";
    }
    if (isExistsMyPublicJobs) {
      message += "・公開中の依頼が存在するため退会できません。\n";
    }
    message += "\n依頼・応募を確認してから改めて退会をお願いします。";
    return message;
  }
}
