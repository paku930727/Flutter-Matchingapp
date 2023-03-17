import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sukimachi/domain/user.dart';

import 'dummy_constants.dart';

List<User> dummyUserList = [
  User(
    userRef: miyajiUserRef,
    userName: miyajiUserName,
    sex: 0,
    orderedJobsCount: 0,
    acceptedJobsCount: 0,
    introduceForClient: '初めまして',
    introduceForContractor: 'お元気ですか？',
    updatedAt: Timestamp.fromDate(DateTime.now()),
    createdAt: Timestamp.fromDate(DateTime.now()),
    isDeleted: false,
  ),
  User(
    userRef: testUserRef,
    userName: testUserName,
    sex: 1,
    orderedJobsCount: 100,
    acceptedJobsCount: 25,
    updatedAt: Timestamp.fromDate(DateTime.now()),
    createdAt: Timestamp.fromDate(DateTime.now()),
    isDeleted: false,
  ),
  User(
    userRef: fullUserRef,
    userName: fullUserName,
    sex: 0,
    orderedJobsCount: 0,
    acceptedJobsCount: 0,
    introduceForClient: '初めまして',
    introduceForContractor: 'お元気ですか？',
    updatedAt: Timestamp.fromDate(DateTime.now()),
    createdAt: Timestamp.fromDate(DateTime.now()),
    snsUrlList: {"twitter": "https://twitter.com/suki_machi"},
    isDeleted: false,
  ),
];
