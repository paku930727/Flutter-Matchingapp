import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/application.dart';
import 'package:sukimachi/presentation/home/error_message/error_message_controller.dart';
import 'package:sukimachi/presentation/job_detail/job_detail_model.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/repository/job_repository.dart';
import 'package:sukimachi/repository/user_repository.dart';

final myPageJobDetailProvider = ChangeNotifierProvider.autoDispose.family(
    (ref, String id) => MyPageJobDetailModel(
        id,
        ref.watch(jobRepositoryProvider),
        ref.watch(userRepositoryProvider),
        ref.watch(authRepositoryProvider),
        ref.read(errorMessageProvider))
      ..init());

class MyPageJobDetailModel extends JobDetailModel {
  MyPageJobDetailModel(
      id, jobRepository, userRepository, authRepository, errorMessageController)
      : super(id, jobRepository, userRepository, authRepository,
            errorMessageController);

  List<Application>? applications;

  @override
  Future init() async {
    await super.init();
    await _fetchApplications();
    notifyListeners();
  }

  Future<void> _fetchApplications() async {
    if (job == null) {
      applications = [];
      return;
    }
    applications = await jobRepository.fetchJobApplications(job!.jobRef);
  }

  Future<void> acceptApplication(Application application) async {
    await jobRepository.acceptApplication(application);
    await _fetchApplications();
    notifyListeners();
  }

  Future<void> rejectApplication(Application application) async {
    await jobRepository.rejectApplication(application);
    await _fetchApplications();
    notifyListeners();
  }

  Future<void> completeApplication(Application application) async {
    await jobRepository.completeApplication(application);
    await _fetchApplications();
    // todo: ポイント付与の処理が必要
    notifyListeners();
  }

  Future<void> changeJobStatus() async {
    if (job == null) {
      throw "依頼が見つかりません。";
    }
    if (job!.jobStatus == kJobStatusClosed) {
      throw "依頼の公開が終了しています。";
    }
    if (currentUser!.userRef.id != job!.clientRef.id) {
      throw "他のユーザーの依頼です。";
    }
    final jobStatus = () {
      switch (job!.jobStatus) {
        case kJobStatusPublic:
          return kJobStatusClosed;
        case kJobStatusPrivate:
          return kJobStatusPublic;
        default:
          throw "依頼のステータスが不明です。";
      }
    }();
    await jobRepository.updateJob(
      userId: job!.clientRef.id,
      jobId: job!.jobRef.id,
      jobTitle: job!.jobTitle,
      jobDetail: job!.jobDetail,
      jobPrice: job!.jobPrice,
      jobStatus: jobStatus,
      jobCategory: job!.jobCategory,
      currentUser: currentUser!,
      applicationDeadline: job!.applicationDeadline.toDate(),
      deliveryDeadline: job!.deliveryDeadline.toDate(),
      createdAt: job!.createdAt.toDate(),
      clientName: job!.clientName,
      clientRef: job!.clientRef,
    );
    await init();
  }
}
