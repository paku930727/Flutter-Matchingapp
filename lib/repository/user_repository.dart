import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/application.dart';
import 'package:sukimachi/domain/job.dart';
import 'package:sukimachi/domain/secret_profile.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/exception/user_null_exception.dart';
import 'package:sukimachi/log/logger.dart';
import '../domain/user.dart';

final userRepositoryProvider = Provider<UserRepository>(
    (ref) => UserRepository(ref.watch(authRepositoryProvider)));

class UserRepository {
  UserRepository(this._auth);

  final _firestore = FirebaseFirestore.instance;
  final AuthRepository _auth;

  User? _currentUser; // ログインユーザのキャッシュ

  // userRepositoryでUser情報を保管しておく。
  static User? currentUser;

  /// ログインユーザーのfetch
  Future<User?> fetchCurrentUser() async {
    final id = _auth.firebaseUser?.uid;
    if (id == null) {
      return null;
    }
    final snapshot = await _firestore.collection(kUsers).doc(id).get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    _currentUser = User.fromJson(data);
    _currentUser!.setUserImageUrl();
    return _currentUser;
  }

  /// ログインユーザーのfetch
  /// 一度取得の場合キャッシュを返す。
  Future<User?> fetchCurrentUserCache() async {
    if (_currentUser != null) return _currentUser;
    return fetchCurrentUser();
  }

  /// uidからユーザー情報を取得する。
  Future<User> fetchUser(String id) async {
    try {
      final snapshot = await _firestore.collection(kUsers).doc(id).get();
      final data = snapshot.data();
      if (data == null) {
        // ユーザーデータが登録されていない場合
        throw UserNullException();
      } else {
        final user = User.fromJson(data);
        await user.setUserImageUrl();
        return user;
      }
    } on Exception catch (e) {
      logger.warning(e);
      rethrow;
    }
  }

  Future<List<User>> fetchUserList() async {
    final snapshot = await _firestore.collection(kUsers).get();
    final userList =
        snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    // userListの全ImageUrlを取得するため
    // 取得した全てのJobにclientImageUrlをセットするため
    for (User user in userList) {
      await user.setUserImageUrl();
    }
    return userList;
  }

  /// 指定したユーザーの依頼Jobリストを取得する
  Future<List<Job>> fetchUsersClientJobList({required String uid}) async {
    final snapshot = await _firestore
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

  /// 指定したユーザーの受注Jobリストを取得する
  Future<List<Application>> fetchUsersApplications(
      {required String uid}) async {
    final snapshot = await _firestore
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

  /// ユーザープロフィールを更新する。
  /// 更新が成功した場合trueを返却する。
  Future<bool> updateProfile({
    required User data,
    required DocumentReference userRef,
    Uint8List? profileImgBytes,
  }) async {
    try {
      if (profileImgBytes != null) {
        await uploadImageToStorage(
            profileImgBytes, data.userRef.id, data.userRef.id);
      }
      await userRef.update(data.toMap());
      await fetchCurrentUser();
      return true;
    } on Exception catch (e, st) {
      logger.config(data);
      logger.severe(e);
      logger.severe(st);
      return false;
    }
  }

  /// 新しいユーザーデータを登録する。
  Future<bool> resisterMyProfile({
    required String uid,
    required String userName,
    required int sex,
    String? introduceForClient,
    String? introduceForContractor,
    Map<String, dynamic>? snsUrlList,
    Uint8List? profileImgBytes,
  }) async {
    bool isSuccessful = false;
    try {
      if (profileImgBytes != null) {
        await uploadImageToStorage(profileImgBytes, uid, uid);
      }
      final userRef = _firestore.collection(kUsers).doc(uid);
      final newUser = _newProfileUser(
        userRef: userRef,
        userName: userName,
        sex: sex,
        introduceForClient: introduceForClient,
        introduceForContractor: introduceForContractor,
        snsUrlList: snsUrlList,
      );
      await userRef.set(newUser.toMap());
      fetchCurrentUserCache();
      isSuccessful = true;
    } on Exception catch (e) {
      logger.warning(e);
      rethrow;
    } on Error catch (e) {
      logger.severe(e);
      rethrow;
    }
    return isSuccessful;
  }

  /// 引数の値を入れると、ユーザーオブジェクトを返却する。
  User _newProfileUser({
    required DocumentReference userRef,
    required String userName,
    required int sex,
    String? introduceForClient,
    String? introduceForContractor,
    Map<String, dynamic>? snsUrlList,
  }) {
    return User(
      userRef: userRef,
      userName: userName,
      sex: sex,
      orderedJobsCount: 0,
      acceptedJobsCount: 0,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      introduceForClient: introduceForClient ?? "",
      introduceForContractor: introduceForContractor ?? "",
      snsUrlList: snsUrlList,
      isDeleted: false,
    );
  }

  /// [jobId]と[uid]を用いて、指定した自分のJob情報を取得する。
  Future<Job> fetchMyJobById(
      {required String uid, required String jobId}) async {
    final snapshot = await _firestore
        .collection(kUsers)
        .doc(uid)
        .collection(kClientJobs)
        .doc(jobId)
        .get();
    final data = snapshot.data();

    final clientJob = Job.fromJson(data!);
    return clientJob;
  }

  Future<SecretProfile?> fetchSecretProfile() async {
    if (_currentUser == null) {
      final user = await fetchCurrentUserCache();
      if (user == null) {
        return Future.value(null);
      }
    }
    final snapshot =
        await _currentUser!.userRef.collection(kSecretProfile).get();
    if (snapshot.docs.isEmpty) {
      return Future.value(null);
    }
    // secretProfileは一つしか存在しないので最初のものを返せば良い
    return SecretProfile.fromMap(snapshot.docs.first.data());
  }

  // 自分が応募している応募の中でInReviewかAcceptedの応募が存在するかどうか
  Future<bool> isExistsMyApplicationInReviewOrAccepted(User user) async {
    final snapshot = await user.userRef
        .collection(kApplications)
        .where('status', whereIn: [
      kApplicationStatusInReview,
      kApplicationStatusAccepted
    ]).get();
    return snapshot.docs.isNotEmpty;
  }

  // 自分の依頼の中でInReviewかAcceptedの応募を持っている依頼が存在するかどうか
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

  Future<bool> isExistsMyPublicJobs(User user) async {
    final snapshot = await user.userRef
        .collection(kClientJobs)
        .where('jobStatus', isEqualTo: kJobStatusPublic)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> deleteAccount(User user) async {
    final data = user.toMap();
    data["isDeleted"] = true;
    await user.userRef.update(data);
  }

  /// firebaseのStorageにプロフィール画像をアップロードし、storageのPathを返却する。
  /// 現在のstoragePathは,users/userId/profileImg/${uid}_profile.jpeg
  Future<String> uploadImageToStorage(
      Uint8List bytes, String storageId, String uid) async {
    final storagePath = "users/$storageId/profileImg/${uid}_profile.jpeg";
    try {
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      //プロフィール画像のフォルダパスは、uid/uid_profile.jpegで保存される
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      //byteデータをstorageにアップロードしているので、どんな画像形式を選んでもjpegとして保存される。
      await storageRef.putData(bytes, metadata);
    } on Exception catch (e, st) {
      logger.severe(e);
      logger.severe(st);
    }
    //return await (await uploadTask).ref.getDownloadURL();
    return storagePath;
  }
}
