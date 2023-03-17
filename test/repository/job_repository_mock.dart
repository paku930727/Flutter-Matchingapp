import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/application.dart';
import 'package:sukimachi/domain/job.dart';
import 'package:sukimachi/domain/job_comment.dart';
import 'package:sukimachi/domain/user.dart';
import 'package:sukimachi/log/logger.dart';
import 'package:sukimachi/repository/job_repository.dart';
import '../dummy/dummy_applications.dart';

class JobRepositoryMock implements JobRepository {
  final _fakeFirebaseFirestore = FakeFirebaseFirestore();

  Future set(List<Job> jobList, List<JobComment> jobCommentList,
      List<Application> applications) async {
    for (var job in jobList) {
      await setJobs(job);
    }
    for (var jobComment in jobCommentList) {
      await jobComment.commentRef.set(jobComment.toMap());
    }
    for (var application in applications) {
      await application.applicationRef.set(application.toMap());
    }
  }

  Future setJobs(Job dummyJob) async {
    await _fakeFirebaseFirestore
        .collection('jobs')
        .doc(dummyJob.jobRef.id)
        .set(dummyJob.toMap());
    await _fakeFirebaseFirestore
        .collection('users')
        .doc(dummyJob.clientRef.id)
        .collection('clientJobs')
        .doc(dummyJob.jobRef.id)
        .set(dummyJob.toMap());
  }

  @override
  Future<Job?> fetchJob(String id) async {
    final snapshot =
        await _fakeFirebaseFirestore.collection('jobs').doc(id).get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    final job = Job.fromJson(data);
    return job;
    // return await Future.value(_jobData[id]);
  }

  @override
  Future<List<Job>> fetchPublicJobList() async {
    final snapshot = await _fakeFirebaseFirestore
        .collection(kJobs)
        .where(kJobStatus, isEqualTo: kJobStatusPublic)
        .where('applicationDeadline', isGreaterThan: DateTime.now())
        .get();
    final jobList =
        snapshot.docs.map((doc) => Job.fromJson(doc.data())).toList();
    return jobList;
  }

  @override
  Future<List<Job>> fetchCategoryJobsList(List<String> categories) async {
    final snapshot = await _fakeFirebaseFirestore
        .collection('jobs')
        .where('jobCategory', whereIn: categories)
        .where(kJobStatus, isEqualTo: kJobStatusPublic)
        .where('applicationDeadline', isGreaterThan: DateTime.now())
        .get();
    final jobList =
        snapshot.docs.map((doc) => Job.fromJson(doc.data())).toList();
    return jobList;
  }

  @override
  Future<List<JobComment>> fetchFirstJobCommentList(
      String jobId, int loadLimit) async {
    final snapshot = await _fakeFirebaseFirestore
        .collection('jobs')
        .doc(jobId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .limit(loadLimit)
        .get();
    final commentList =
        snapshot.docs.map((doc) => JobComment.fromJson(doc.data())).toList();
    return commentList;
  }

  @override
  Future<List<JobComment>> fetchMoreJobCommentList(String jobId) async {
    final snapshot = await _fakeFirebaseFirestore
        .collection('jobs')
        .doc(jobId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();
    final commentList =
        snapshot.docs.map((doc) => JobComment.fromJson(doc.data())).toList();
    return commentList;
  }

  @override
  Future sendComment(
      {required String jobId,
      required String comment,
      required commenterRef,
      required String commenterName,
      String? commenterImageUrl}) async {
    DocumentReference commentDoc = _fakeFirebaseFirestore
        .collection('jobs')
        .doc(jobId)
        .collection('comments')
        .doc();
    commentDoc.set({
      'commentRef': commentDoc,
      'comment': comment,
      'commenterRef': commenterRef,
      'commenterName': commenterName,
      'commenterImageUrl': commenterImageUrl,
      'createdAt': DateTime.now()
    });
  }

  @override
  Future<void> createJob(
      {required String userId,
      required String jobTitle,
      required String jobDetail,
      required int jobPrice,
      required String jobStatus,
      required DateTime applicationDeadline,
      required DateTime deliveryDeadline,
      required String clientName,
      required DocumentReference<Object?> clientRef,
      required String jobCategory,
      String? clientImagePath}) async {
    try {
      // batchの初期化は、関数のスコープ内で行わなければcommitでエラーが発生するため。
      final _batch = _fakeFirebaseFirestore.batch();
      // jobsコレクションの参照先
      final jobRef = _fakeFirebaseFirestore.collection(kJobs).doc();
      final jobId = jobRef.id;
      // usersコレクションのサブコレクションであるclientJobsの参照先
      final clientJobRef = _fakeFirebaseFirestore
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

  @override
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
      required DocumentReference<Object?> clientRef,
      required String jobCategory,
      String? clientImagePath}) async {
    try {
      // batchの初期化は、関数のスコープ内で行わなければcommitでエラーが発生するため。
      final _batch = _fakeFirebaseFirestore.batch();
      // jobsコレクションの参照先
      final jobRef = _fakeFirebaseFirestore.collection(kJobs).doc(jobId);
      // usersコレクションのサブコレクションであるclientJobsの参照先
      final clientJobRef = _fakeFirebaseFirestore
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

  @override
  Future<void> applyJob(
      {required jobId,
      required jobRef,
      required clientRef,
      required applicantRef,
      required jobTitle,
      required jobPrice,
      required clientName,
      clientImagePath,
      required applicantName,
      applicantImagePath}) async {
    final applicationRef = applicantRef.collection('applications').doc(jobId);
    final application = Application(
        applicationRef: applicationRef,
        jobRef: jobRef,
        clientRef: clientRef,
        applicantRef: applicantRef,
        jobTitle: jobTitle,
        jobPrice: jobPrice,
        clientName: clientName,
        applicantName: applicantName,
        status: kApplicationStatusInReview,
        createdAt: Timestamp.fromDate(DateTime.now()),
        updatedAt: Timestamp.fromDate(
          DateTime.now(),
        ));
    dummyApplications.add(application);
    await applicationRef.set(application.toMap());
  }

  @override
  Future<Application?> getCurrentUserApplicationFromJob(
      {required DocumentReference<Object?> currentUserRef,
      required String jobId}) async {
    final snapshot =
        await currentUserRef.collection(kApplications).doc(jobId).get();
    if (snapshot.exists) {
      return Application.fromJson(snapshot.data()!);
    }
    return null;
  }

  @override
  Future<void> cancelApplication(
      {required DocumentReference<Object?> currentUserRef,
      required String jobId}) async {
    await currentUserRef.collection(kApplications).doc(jobId).delete();
  }

  @override
  Future<List<Application>> fetchJobApplications(
      DocumentReference<Object?> jobRef) async {
    final snapshot = await jobRef.collection('applications').get();
    final applicationList =
        snapshot.docs.map((doc) => Application.fromJson(doc.data())).toList();
    return applicationList;
  }

  @override
  Future<void> acceptApplication(Application application) async {
    application.jobRef
        .collection(kApplications)
        .doc(application.applicationRef.id)
        .update({"status": kApplicationStatusAccepted});
  }

  @override
  Future<void> rejectApplication(Application application) async {
    application.jobRef
        .collection(kApplications)
        .doc(application.applicationRef.id)
        .update({"status": kApplicationStatusRejected});
  }

  @override
  Future<void> completeApplication(Application application) async {
    application.jobRef
        .collection(kApplications)
        .doc(application.applicationRef.id)
        .update({"status": kApplicationStatusDone});
  }
}
