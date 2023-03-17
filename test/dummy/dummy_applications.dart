import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/application.dart';

import 'dummy_constants.dart';

// User配下にあるApplication
List<Application> dummyApplications = [
  // ダミー応募: firstApplication
  // 応募者: 宮路
  // 発注者: テスト
  // 依頼: テストユーザの依頼です。
  Application(
    applicationRef:
        miyajiUserRef.collection('applications').doc(testUserJobRef.id),
    jobRef: testUserJobRef,
    clientRef: testUserRef,
    applicantRef: miyajiUserRef,
    jobTitle: testUserJobTitle,
    jobPrice: 200000,
    clientName: testUserName,
    applicantName: miyajiUserName,
    status: kApplicationStatusInReview,
    createdAt: Timestamp.fromDate(DateTime.now()),
    updatedAt: Timestamp.fromDate(DateTime.now()),
  ),
];
