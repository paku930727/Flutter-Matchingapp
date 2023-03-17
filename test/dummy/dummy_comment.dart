import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sukimachi/domain/job_comment.dart';
import 'package:uuid/uuid.dart';

import 'dummy_constants.dart';

final fakeFirebaseFirestore = FakeFirebaseFirestore();

List<JobComment> dummyCommentList = [
  JobComment(
      commentRef: miyajiSukimachiJobRef
          .collection('comments')
          .doc(const Uuid().toString()),
      comment: 'スキ街頑張ってください！！',
      commenterRef: testUserRef,
      commenterName: testUserName,
      createdAt: Timestamp.fromDate(DateTime.now())),
  JobComment(
      commentRef: miyajiSukimachiJobRef
          .collection('comments')
          .doc(const Uuid().toString()),
      comment: '頑張りまする',
      commenterRef: miyajiUserRef,
      commenterName: miyajiUserName,
      createdAt: Timestamp.fromDate(DateTime.now())),
  JobComment(
      commentRef: miyajiSukimachiJobRef
          .collection('comments')
          .doc(const Uuid().toString()),
      comment: '三つ目のコメント',
      commenterRef: miyajiUserRef,
      commenterName: miyajiUserName,
      createdAt: Timestamp.fromDate(DateTime.now())),
  JobComment(
      commentRef: miyajiSukimachiJobRef
          .collection('comments')
          .doc(const Uuid().toString()),
      comment: '四つ目のコメント',
      commenterRef: miyajiUserRef,
      commenterName: miyajiUserName,
      createdAt: Timestamp.fromDate(DateTime.now())),
  JobComment(
      commentRef: miyajiTwitterJobRef
          .collection('comments')
          .doc(const Uuid().toString()),
      comment: 'スキ街頑張ってください！！',
      commenterRef: testUserRef,
      commenterName: testUserName,
      createdAt: Timestamp.fromDate(DateTime.now()))
];
