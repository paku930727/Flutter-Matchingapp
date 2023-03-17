import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sukimachi/log/logger.dart';

class JobComment {
  JobComment(
      {required this.commentRef,
      required this.comment,
      required this.commenterRef,
      required this.commenterName,
      required this.createdAt});

  final DocumentReference commentRef;
  final String comment;
  final DocumentReference commenterRef;
  final String commenterName;
  String? commenterImageUrl;
  final Timestamp createdAt;

  factory JobComment.fromJson(Map data) {
    return JobComment(
        commentRef: data['commentRef'],
        comment: data['comment'],
        commenterRef: data['commenterRef'],
        commenterName: data['commenterName'],
        createdAt: data['createdAt']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "commentRef": commentRef,
      "comment": comment,
      "commenterRef": commenterRef,
      "commenterName": commenterName,
      "createdAt": createdAt,
    };
  }

  /// Image画像のURLを取得するメソッド
  Future<void> setCommenterImageUrl() async {
    try {
      String commenterImagePath = getCommenterImagePath();
      final storageRef =
          FirebaseStorage.instance.ref().child(commenterImagePath);
      String imageUrl = await storageRef.getDownloadURL();
      commenterImageUrl = imageUrl;
      logger.config(commenterImageUrl);
    } on Exception catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      commenterImageUrl = null;
    }
  }

  /// uidからfirebaseのcloudStorageのパスを生成する。
  String getCommenterImagePath() {
    final storagePath =
        "users/${commenterRef.id}/profileImg/${commenterRef.id}_profile.jpeg";
    return storagePath;
  }
}
