import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/job.dart';
import 'dummy_category.dart';
import 'dummy_constants.dart';

final fakeFirebaseFirestore = FakeFirebaseFirestore();

List<Job> dummyJobList = [
  Job(
    jobRef: miyajiSukimachiJobRef,
    jobTitle: miyajiSukimachiJobTitle,
    jobDetail: 'スキ街というなの副業マッチングサービスを作りたいです。',
    jobPrice: 10000,
    jobStatus: kJobStatusPublic,
    clientRef: miyajiUserRef,
    clientName: miyajiUserName,
    applicationDeadline: Timestamp.fromDate(DateTime.now()),
    deliveryDeadline: Timestamp.fromDate(DateTime.now()),
    createdAt: Timestamp.fromDate(DateTime.now()),
    updatedAt: Timestamp.fromDate(DateTime.now()),
    jobCategory: dummyCategory[0].name,
  ),
  Job(
    jobRef: miyajiTwitterJobRef,
    jobTitle: miyajiTwitterJobTitle,
    jobDetail: 'twitter用にイラスト描いて欲しいです',
    jobPrice: 5000,
    jobStatus: kJobStatusPublic,
    clientRef: miyajiUserRef,
    clientName: miyajiUserName,
    jobCategory: dummyCategory[0].name,
    applicationDeadline: Timestamp.fromDate(DateTime.now()),
    deliveryDeadline: Timestamp.fromDate(DateTime.now()),
    createdAt: Timestamp.fromDate(DateTime.now()),
    updatedAt: Timestamp.fromDate(DateTime.now()),
  ),
  Job(
      jobRef: testUserJobRef,
      jobTitle: testUserJobTitle,
      jobDetail: 'テストユーザの依頼のテストです。',
      jobPrice: 200000,
      jobStatus: kJobStatusClosed,
      clientRef: testUserRef,
      clientName: testUserName,
      jobCategory: dummyCategory[0].name,
      applicationDeadline: Timestamp.fromDate(DateTime.now()),
      deliveryDeadline: Timestamp.fromDate(DateTime.now()),
      createdAt: Timestamp.fromDate(DateTime.now()),
      updatedAt: Timestamp.fromDate(DateTime.now())),
  Job(
      jobRef: testUserJobRef2,
      jobTitle: testUserJobTitle2,
      jobDetail: '未公開の依頼です',
      jobPrice: 200000,
      jobStatus: kJobStatusPrivate,
      clientRef: testUserRef,
      clientName: testUserName,
      jobCategory: dummyCategory[0].name,
      applicationDeadline: Timestamp.fromDate(DateTime.now()),
      deliveryDeadline: Timestamp.fromDate(DateTime.now()),
      createdAt: Timestamp.fromDate(DateTime.now()),
      updatedAt: Timestamp.fromDate(DateTime.now())),
];
