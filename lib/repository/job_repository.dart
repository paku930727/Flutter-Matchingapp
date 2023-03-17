import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/application.dart';
import 'package:sukimachi/domain/job_comment.dart';
import 'package:sukimachi/domain/user.dart';
import 'package:sukimachi/log/logger.dart';
import '../domain/job.dart';

final jobRepositoryProvider =
    Provider<JobRepository>((ref) => JobRepository.instance);

class JobRepository {
  JobRepository._();

  static final instance = JobRepository._();
  final _firestore = FirebaseFirestore.instance;

  Future<Job?> fetchJob(String id) async {
    final snapshot = await _firestore.collection(kJobs).doc(id).get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    final job = Job.fromJson(data);
    await job.setClientImageUrl();
    return job;
  }

  // StatusがPublicで募集期限が切れていない依頼一覧を取得
  Future<List<Job>> fetchPublicJobList() async {
    final snapshot = await _firestore
        .collection(kJobs)
        .where(kJobStatus, isEqualTo: kJobStatusPublic)
        .where('applicationDeadline', isGreaterThan: DateTime.now())
        .get();
    final jobList =
        snapshot.docs.map((doc) => Job.fromJson(doc.data())).toList();
    // 取得した全てのJobにclientImageUrlをセットするため
    for (Job job in jobList) {
      await job.setClientImageUrl();
    }
    return jobList;
  }

  // カテゴリは1以上10以下である必要がある
  // StatusがPublicで募集期限が切れていない依頼一覧を取得
  Future<List<Job>> fetchCategoryJobsList(List<String> categories) async {
    final snapshot = await _firestore
        .collection('jobs')
        .where('jobCategory', whereIn: categories)
        .where(kJobStatus, isEqualTo: kJobStatusPublic)
        .where('applicationDeadline', isGreaterThan: DateTime.now())
        .get();
    final jobList =
        snapshot.docs.map((doc) => Job.fromJson(doc.data())).toList();
    // 取得した全てのJobにclientImageUrlをセットするため
    for (Job job in jobList) {
      await job.setClientImageUrl();
    }
    return jobList;
  }

  Future<List<JobComment>> fetchFirstJobCommentList(
      String jobId, int loadLimit) async {
    final snapshot = await _firestore
        .collection('jobs')
        .doc(jobId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit)
        .get();
    final commentList =
        snapshot.docs.map((doc) => JobComment.fromJson(doc.data())).toList();
    // commentListの全ImageUrlを取得するため
    for (JobComment comment in commentList) {
      await comment.setCommenterImageUrl();
    }
    return commentList;
  }

  Future<List<JobComment>> fetchMoreJobCommentList(
    String jobId,
  ) async {
    final snapshot = await _firestore
        .collection('jobs')
        .doc(jobId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();
    final commentList =
        snapshot.docs.map((doc) => JobComment.fromJson(doc.data())).toList();
    // commentListの全ImageUrlを取得するため
    for (JobComment comment in commentList) {
      await comment.setCommenterImageUrl();
    }
    return commentList;
  }

  Future sendComment(
      {required String jobId,
      required String comment,
      required commenterRef,
      required String commenterName,
      String? commenterImageUrl}) async {
    DocumentReference commentDoc =
        _firestore.collection('jobs').doc(jobId).collection('comments').doc();
    commentDoc.set({
      'commentRef': commentDoc,
      'comment': comment,
      'commenterRef': commenterRef,
      'commenterName': commenterName,
      //'commenterImageUrl': commenterImageUrl,
      'createdAt': DateTime.now()
    });
  }

  /// 依頼作成を行う
  Future<void> createJob({
    required String userId,
    required String jobTitle,
    required String jobDetail,
    required int jobPrice,
    required String jobStatus,
    required DateTime applicationDeadline,
    required DateTime deliveryDeadline,
    required String clientName,
    required DocumentReference clientRef,
    required String jobCategory,
  }) async {
    try {
      // batchの初期化は、関数のスコープ内で行わなければcommitでエラーが発生するため。
      final _batch = FirebaseFirestore.instance.batch();
      // jobsコレクションの参照先
      final jobRef = _firestore.collection(kJobs).doc();
      final jobId = jobRef.id;
      // usersコレクションのサブコレクションであるclientJobsの参照先
      final clientJobRef = _firestore
          .collection(kUsers)
          .doc(userId)
          .collection(kClientJobs)
          .doc(jobId);

      Job job = Job(
        jobRef: jobRef,
        jobTitle: jobTitle,
        jobDetail: jobDetail,
        jobPrice: jobPrice,
        jobStatus: jobStatus,
        applicationDeadline: Timestamp.fromDate(applicationDeadline),
        deliveryDeadline: Timestamp.fromDate(deliveryDeadline),
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        jobCategory: jobCategory,
        clientName: clientName,
        clientRef: clientRef,
      );

      // jobsコレクションへ登録
      _batch.set(jobRef, job.toMap());
      // usersコレクションのサブコレクションであるclientJobsへの登録
      _batch.set(clientJobRef, job.toMap());
      _batch.commit();
    } catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      rethrow;
    }
  }

  /// Jobを更新するメソッド
  Future<void> updateJob(
      {required String userId,
      required String jobId,
      required String jobTitle,
      required String jobDetail,
      required int jobPrice,
      required String jobStatus,
      required User currentUser,
      required DateTime applicationDeadline,
      required DateTime deliveryDeadline,
      required DateTime createdAt,
      required String clientName,
      required DocumentReference clientRef,
      required String jobCategory,
      String? clientImagePath}) async {
    try {
      // batchの初期化は、関数のスコープ内で行わなければcommitでエラーが発生するため。
      final _batch = FirebaseFirestore.instance.batch();
      // jobsコレクションの参照先
      final jobRef = _firestore.collection(kJobs).doc(jobId);
      // usersコレクションのサブコレクションであるclientJobsの参照先
      final clientJobRef = _firestore
          .collection(kUsers)
          .doc(userId)
          .collection(kClientJobs)
          .doc(jobId);
      Job job = Job(
        jobRef: jobRef,
        jobTitle: jobTitle,
        jobDetail: jobDetail,
        jobPrice: jobPrice,
        jobStatus: jobStatus,
        applicationDeadline: Timestamp.fromDate(applicationDeadline),
        deliveryDeadline: Timestamp.fromDate(deliveryDeadline),
        createdAt: Timestamp.fromDate(createdAt),
        updatedAt: Timestamp.now(),
        jobCategory: jobCategory,
        clientName: clientName,
        clientRef: clientRef,
      );

      _batch.update(jobRef, job.toMap());
      _batch.update(clientJobRef, job.toMap());
      _batch.commit();
    } catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      rethrow;
    }
  }

  // 依頼応募者のUser配下にapplicationを作成
  Future<void> applyJob(
      {required String jobId,
      required DocumentReference jobRef,
      required DocumentReference clientRef,
      required DocumentReference applicantRef,
      required String jobTitle,
      required int jobPrice,
      required String clientName,
      required String applicantName,
      String? applicantImagePath}) async {
    final applicationDoc = applicantRef.collection(kApplications).doc(jobId);
    final application = Application(
      applicationRef: applicationDoc,
      jobRef: jobRef,
      clientRef: clientRef,
      applicantRef: applicantRef,
      jobTitle: jobTitle,
      jobPrice: jobPrice,
      clientName: clientName,
      applicantName: applicantName,
      status: kApplicationStatusInReview,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
    await applicationDoc.set(application.toMap());
  }

  Future<Application?> getCurrentUserApplicationFromJob({
    required DocumentReference currentUserRef,
    required String jobId,
  }) async {
    final snapshot =
        await currentUserRef.collection(kApplications).doc(jobId).get();
    if (snapshot.exists) {
      return Application.fromJson(snapshot.data()!);
    }
    return null;
  }

  Future<void> cancelApplication({
    required DocumentReference currentUserRef,
    required String jobId,
  }) async {
    await currentUserRef.collection(kApplications).doc(jobId).delete();
  }

  Future<List<Application>> fetchJobApplications(
      DocumentReference jobRef) async {
    final snapshot = await jobRef.collection('applications').get();
    final applicationList =
        snapshot.docs.map((doc) => Application.fromJson(doc.data())).toList();
    return applicationList;
  }

  Future<void> acceptApplication(Application application) async {
    // ここではJob配下のApplicationを操作する。(FunctionsでUser配下の操作をする)
    application.jobRef
        .collection(kApplications)
        .doc(application.applicationRef.id)
        .update({"status": kApplicationStatusAccepted});
  }

  Future<void> rejectApplication(Application application) async {
    // ここではJob配下のApplicationを操作する。(FunctionsでUser配下の操作をする)
    application.jobRef
        .collection(kApplications)
        .doc(application.applicationRef.id)
        .update({"status": kApplicationStatusRejected});
  }

  Future<void> completeApplication(Application application) async {
    // ここではJob配下のApplicationを操作する。(FunctionsでUser配下の操作をする)
    application.jobRef
        .collection(kApplications)
        .doc(application.applicationRef.id)
        .update({"status": kApplicationStatusDone});
  }
}
