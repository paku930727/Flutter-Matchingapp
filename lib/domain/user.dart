import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sukimachi/log/logger.dart';

class User {
  User({
    required this.userRef,
    required this.userName,
    required this.sex,
    required this.orderedJobsCount,
    required this.acceptedJobsCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.snsUrlList,
    this.introduceForClient,
    this.introduceForContractor,
  });

  final DocumentReference userRef;
  final String userName;
  final int sex;
  final int orderedJobsCount;
  final int acceptedJobsCount;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final bool isDeleted;

  String? userImageUrl;
  Map<String, dynamic>? snsUrlList;
  String? introduceForClient;
  String? introduceForContractor;

  factory User.fromJson(Map data) {
    return User(
      userRef: data["userRef"],
      userName: data["userName"],
      snsUrlList: data["snsUrlList"],
      sex: data["sex"],
      orderedJobsCount: data["orderedJobsCount"],
      acceptedJobsCount: data["acceptedJobsCount"],
      introduceForClient: data['introduceForClient'],
      introduceForContractor: data['introduceForContractor'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      isDeleted: data['isDeleted'],
    );
  }

  //Map型に変換する。
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "userRef": userRef,
      "userName": userName,
      "snsUrlList": snsUrlList,
      "sex": sex,
      "orderedJobsCount": orderedJobsCount,
      "acceptedJobsCount": acceptedJobsCount,
      "introduceForClient": introduceForClient,
      "introduceForContractor": introduceForContractor,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "isDeleted": isDeleted,
    };
  }

  //引数に指定した値に書き換えたuserのオブジェクトをコピーで返却する関数
  User copyWith({
    String? userName,
    int? sex,
    Timestamp? updatedAt,
    Map<String, dynamic>? snsUrlList,
    String? introduceForClient,
    String? introduceForContractor,
    bool? isDeleted,
  }) {
    return User(
      userRef: userRef,
      userName: userName ?? this.userName,
      sex: sex ?? this.sex,
      orderedJobsCount: orderedJobsCount,
      acceptedJobsCount: acceptedJobsCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      snsUrlList: snsUrlList ?? this.snsUrlList,
      introduceForClient: introduceForClient ?? this.introduceForClient,
      introduceForContractor:
          introduceForContractor ?? this.introduceForContractor,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  String sexToString() {
    switch (sex) {
      case 0:
        return "男性";
      case 1:
        return "女性";
      case 9:
        return "その他";
      default:
        return "未登録";
    }
  }

  bool hasIntroduceForClient() {
    return introduceForClient != "";
  }

  bool hasIntroduceForContractor() {
    return introduceForContractor != "";
  }

  /// Image画像のURLを取得するメソッド
  Future<void> setUserImageUrl() async {
    try {
      String userImagePath = getUserImagePath();
      final storageRef = FirebaseStorage.instance.ref().child(userImagePath);
      String imageUrl = await storageRef.getDownloadURL();
      userImageUrl = imageUrl;
      logger.config(userImageUrl);
    } on Exception catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      userImageUrl = null;
    }
  }

  /// uidからfirebaseのcloudStorageのパスを生成する。
  String getUserImagePath() {
    final storagePath =
        "users/${userRef.id}/profileImg/${userRef.id}_profile.jpeg";
    return storagePath;
  }
}
