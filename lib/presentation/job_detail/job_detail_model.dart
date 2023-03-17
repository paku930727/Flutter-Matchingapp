import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/job.dart';
import 'package:sukimachi/domain/job_comment.dart';
import 'package:sukimachi/presentation/home/error_message/error_message_controller.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/repository/job_repository.dart';
import 'package:sukimachi/repository/user_repository.dart';
import '../../domain/user.dart';

final jobDetailProvider = ChangeNotifierProvider.autoDispose.family(
    (ref, String id) => JobDetailModel(
        id,
        ref.watch(jobRepositoryProvider),
        ref.watch(userRepositoryProvider),
        ref.watch(authRepositoryProvider),
        ref.read(errorMessageProvider))
      ..init());

class JobDetailModel extends ChangeNotifier {
  JobDetailModel(this.id, this.jobRepository, this.userRepository,
      this.authRepository, this.errorMessageController);

  final String id;
  final JobRepository jobRepository;
  final UserRepository userRepository;
  final AuthRepository authRepository;
  final ErrorMessageController errorMessageController;

  Job? job;
  User? currentUser;
  List<JobComment>? jobCommentList;
  bool canFetchMoreComment = false;
  bool applied = false;
  bool canCancel = false;
  bool canApply = false;
  bool fromOfficialJob = false; // 公式からの依頼かどうか(プレリリース用)
  final TextEditingController commentController = TextEditingController();

  Future init() async {
    await _fetchCurrentUser();
    await _fetchJob(id);
    if (job == null) {
      errorMessageController.addMessage('依頼が見つかりませんでした。');
      return;
    }
    _checkFromOfficial(job!);
    _checkCanApply(job!);
    await _fetchJobComment();
    await _checkApplicationInfo();
    notifyListeners();
  }

  Future<void> _fetchJob(String id) async {
    job = await jobRepository.fetchJob(id);
    // 依頼のステータスが未公開だった場合
    if (job != null && job!.jobStatus == kJobStatusPrivate) {
      // 未ログインまたは他人の依頼だった場合
      if (currentUser == null || currentUser!.userRef != job!.clientRef) {
        errorMessageController.addMessage('未公開の依頼です。');
        job = null;
      }
    }
  }

  void _checkFromOfficial(Job job) async {
    fromOfficialJob = officialJobIds.contains(job.jobRef.id);
  }

  Future<void> _checkCanApply(Job job) async {
    canApply = job.jobStatus == kJobStatusPublic &&
        job.applicationDeadline.toDate().isAfter(DateTime.now());
  }

  Future<void> _fetchJobComment() async {
    jobCommentList =
        await jobRepository.fetchFirstJobCommentList(id, kCommentLoadLimit);
    //コメント数が上限に達している場合はもっと見るが押せる。
    if (jobCommentList!.length == kCommentLoadLimit) {
      canFetchMoreComment = true;
    }
    notifyListeners();
  }

  Future<void> _fetchCurrentUser() async {
    currentUser = await userRepository.fetchCurrentUserCache();
  }

  Future<void> _checkApplicationInfo() async {
    if (currentUser != null) {
      final application = await jobRepository.getCurrentUserApplicationFromJob(
          currentUserRef: currentUser!.userRef, jobId: id);
      if (application == null) {
        applied = false;
        canCancel = false;
      } else {
        applied = true;
        canCancel = application.status == kApplicationStatusInReview;
      }
    } else {
      applied = false;
    }
  }

  Future<void> fetchMoreJobComment() async {
    jobCommentList = await jobRepository.fetchMoreJobCommentList(id);
    canFetchMoreComment = false;
    notifyListeners();
  }

  Future<void> sendComment(
      {required Future Function(String title) showTextDialog,
      required Future Function(bool isSignIn) showUserInfoNotRegisteredDialog,
      required Future Function() onNotLogin}) async {
    if (commentController.text.isEmpty) return; //入力がなければ送信しない
    if (!authRepository.isSignIn) {
      await onNotLogin();
      return;
    }
    if (currentUser == null) {
      await showUserInfoNotRegisteredDialog(authRepository.isSignIn);
      return;
    }
    try {
      await jobRepository.sendComment(
          jobId: id,
          comment: commentController.text,
          commenterRef: currentUser!.userRef,
          commenterName: currentUser!.userName);
      commentController.clear();
      await fetchMoreJobComment();
      notifyListeners();
    } on FirebaseException catch (e) {
      await showTextDialog(e.toString());
    } catch (e) {
      await showTextDialog('予期せぬエラーが発生しました。');
    }
  }

  Future<void> applyJob(
      {required Future Function(String title) showTextDialog,
      required Future Function(bool isSignIn) showUserInfoNotRegisteredDialog,
      required Future Function() onNotLogin}) async {
    if (!authRepository.isSignIn) {
      await onNotLogin();
      return;
    }
    if (currentUser == null) {
      await showUserInfoNotRegisteredDialog(authRepository.isSignIn);
      return;
    }
    if (job == null) {
      await showTextDialog('依頼が存在しません。');
    }
    if (job!.clientRef == currentUser!.userRef) {
      await showTextDialog('ご自身の依頼には応募できません。');
      return;
    }

    try {
      await jobRepository.applyJob(
        jobId: job!.jobRef.id,
        jobRef: job!.jobRef,
        clientRef: job!.clientRef,
        applicantRef: currentUser!.userRef,
        jobTitle: job!.jobTitle,
        jobPrice: job!.jobPrice,
        clientName: job!.clientName,
        applicantName: currentUser!.userName,
        applicantImagePath: currentUser!.userImageUrl,
      );
      applied = true;
      canCancel = true;
      notifyListeners();
      await showTextDialog('応募が完了しました。');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        await showTextDialog(
            'この依頼には応募できません。\n応募締め切りを過ぎているか、依頼の公開が終了している可能性があります。');
        return;
      }
      final message = e.message ?? e.code;
      await showTextDialog(message);
      return;
    } catch (e) {
      await showTextDialog(e.toString());
      return;
    }
  }

  Future<void> cancelApplication(
      Future<void> Function(String title) onFailure) async {
    if (job == null) {
      onFailure('依頼が存在しません');
    }
    if (currentUser == null) {
      onFailure('ログインしてください。');
    }
    try {
      await jobRepository.cancelApplication(
          currentUserRef: currentUser!.userRef, jobId: job!.jobRef.id);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        onFailure('この応募は取り消せません。');
      } else {
        onFailure(e.message ?? e.code);
      }
    } catch (e) {
      onFailure(e.toString());
    }
    applied = false;
    notifyListeners();
  }
}
