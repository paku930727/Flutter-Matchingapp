import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/application.dart';
import 'package:sukimachi/domain/job.dart';
import 'package:sukimachi/domain/secret_profile.dart';
import 'package:sukimachi/domain/user.dart';
import 'package:sukimachi/exception/user_null_exception.dart';
import 'package:sukimachi/log/logger.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/repository/user_repository.dart';

import '../dummy/dummy_user.dart';

class UserRepositoryMock implements UserRepository {
  UserRepositoryMock(this._auth);

  final _fakeFirebaseFirestore = FakeFirebaseFirestore();
  final AuthRepository _auth;

  Future set(List<User> list, List<SecretProfile> secretProfile) async {
    for (var user in dummyUserList) {
      await _fakeFirebaseFirestore
          .collection('users')
          .doc(user.userRef.id)
          .set(user.toMap());
    }
  }

  User? _currentUser; // ログインユーザのキャッシュ

  @override
  Future<User?> fetchCurrentUser() async {
    final id = _auth.firebaseUser?.uid;
    if (id == null) {
      return null;
    }
    final snapshot =
        await _fakeFirebaseFirestore.collection('users').doc(id).get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    _currentUser = User.fromJson(data);
    return _currentUser;
  }

  @override
  Future<User?> fetchCurrentUserCache() async {
    if (_currentUser == null) {
      return await fetchCurrentUser();
    }
    return _currentUser;
  }

  @override
  Future<User> fetchUser(String id) async {
    try {
      final snapshot =
          await _fakeFirebaseFirestore.collection(kUsers).doc(id).get();
      final data = snapshot.data();
      if (data == null) {
        // ユーザーデータが登録されていない場合
        throw UserNullException();
      } else {
        final user = User.fromJson(data);
        return user;
      }
    } on Exception catch (e) {
      logger.warning(e);
      rethrow;
    }
  }

  @override
  Future<List<User>> fetchUserList() {
    // TODO: implement fetchUserList
    throw UnimplementedError();
  }

  @override
  Future<bool> resisterMyProfile({
    required String uid,
    required String userName,
    required int sex,
    String? introduceForClient,
    String? introduceForContractor,
    Map<String, dynamic>? snsUrlList,
    Uint8List? profileImgBytes,
  }) {
    // TODO: implement resisterMyProfile
    throw UnimplementedError();
  }

  @override
  Future<List<Application>> fetchUsersApplications(
      {required String uid}) async {
    final snapshot = await _fakeFirebaseFirestore
        .collection(kUsers)
        .doc(uid)
        .collection(kApplications)
        .orderBy('createdAt', descending: false)
        .limit(20)
        .get();

    final applicationList =
        snapshot.docs.map((doc) => Application.fromJson(doc.data())).toList();
    return applicationList;
  }

  @override
  Future<bool> updateProfile(
      {required User data,
      required DocumentReference<Object?> userRef,
      Uint8List? profileImgBytes}) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }

  @override
  Future<Job> fetchMyJobById({required String uid, required String jobId}) {
    // TODO: implement fetchMyJobById
    throw UnimplementedError();
  }

  @override
  Future<List<Job>> fetchUsersClientJobList({required String uid}) async {
    final snapshot = await _fakeFirebaseFirestore
        .collection(kUsers)
        .doc(uid)
        .collection(kClientJobs)
        .orderBy('createdAt', descending: false)
        .limit(20)
        .get();

    final clientJobList =
        snapshot.docs.map((doc) => Job.fromJson(doc.data())).toList();
    return clientJobList;
  }

  @override
  Future<SecretProfile?> fetchSecretProfile() async {
    if (_currentUser == null) {
      await fetchCurrentUserCache();
    }
    final snapshot =
        await _currentUser!.userRef.collection(kSecretProfile).get();
    if (snapshot.docs.isEmpty) {
      return Future.value(null);
    }
    // secretProfileは一つしか存在しないので最初のものを返せば良い
    return SecretProfile.fromMap(snapshot.docs.first.data());
  }

  @override
  Future<bool> isExistsMyApplicationInReviewOrAccepted(User user) async {
    final snapshot = await user.userRef
        .collection(kApplications)
        .where('status', whereIn: [
      kApplicationStatusInReview,
      kApplicationStatusAccepted
    ]).get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<bool> isExistsMyJobHasApplicationInReviewOrAccepted(User user) async {
    final snapshot = await user.userRef.collection(kClientJobs).get();
    // そもそも依頼が存在しない場合はfalse
    if (snapshot.docs.isEmpty) {
      return false;
    }
    final myJobs =
        snapshot.docs.map((doc) => Job.fromJson(doc.data())).toList();
    for (var job in myJobs) {
      final jobSnapshot = await job.jobRef
          .collection(kApplications)
          .where('status', whereIn: [
        kApplicationStatusInReview,
        kApplicationStatusAccepted
      ]).get();
      // 一つでも該当する応募が存在した場合早期returnでtrueを返す
      if (jobSnapshot.docs.isNotEmpty) return true;
    }
    return false;
  }

  @override
  Future<bool> isExistsMyPublicJobs(User user) async {
    final snapshot = await user.userRef
        .collection(kClientJobs)
        .where('jobStatus', isEqualTo: kJobStatusPublic)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<void> deleteAccount(User user) async {
    final data = user.toMap();
    data["isDeleted"] = true;
    await _fakeFirebaseFirestore
        .collection('users')
        .doc(user.userRef.id)
        .update(data);
  }

  @override
  Future<String> uploadImageToStorage(
      Uint8List bytes, String storageId, String uid) async {
    throw UnimplementedError();
  }
}
