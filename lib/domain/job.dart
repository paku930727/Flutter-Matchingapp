import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sukimachi/log/logger.dart';

class Job {
  Job({
    required this.jobRef,
    required this.jobTitle,
    required this.jobDetail,
    required this.jobCategory,
    required this.jobPrice,
    required this.jobStatus,
    required this.clientRef,
    required this.clientName,
    required this.applicationDeadline,
    required this.deliveryDeadline,
    required this.createdAt,
    required this.updatedAt,
  });

  DocumentReference jobRef;
  String jobTitle;
  String jobDetail;
  String jobCategory;
  int jobPrice;
  String jobStatus;

  // 依頼者の情報
  DocumentReference clientRef;
  String clientName;
  String? clientImageUrl;

  Timestamp applicationDeadline;
  Timestamp deliveryDeadline;
  Timestamp createdAt;
  Timestamp updatedAt;

  factory Job.fromJson(Map data) {
    return Job(
      jobRef: data['jobRef'],
      jobTitle: data['jobTitle'],
      jobDetail: data['jobDetail'],
      jobCategory: data['jobCategory'],
      jobPrice: data['jobPrice'],
      jobStatus: data['jobStatus'],
      clientRef: data['clientRef'],
      clientName: data['clientName'],
      applicationDeadline: data['applicationDeadline'],
      deliveryDeadline: data['deliveryDeadline'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  //Map型に変換する。
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "jobRef": jobRef,
      "jobTitle": jobTitle,
      "jobDetail": jobDetail,
      "jobCategory": jobCategory,
      "jobPrice": jobPrice,
      "jobStatus": jobStatus,
      "clientRef": clientRef,
      "clientName": clientName,
      "applicationDeadline": applicationDeadline,
      "deliveryDeadline": deliveryDeadline,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  /// Image画像のURLを取得するメソッド
  Future<void> setClientImageUrl() async {
    try {
      String clientImagePath = getClientImagePath();
      final storageRef = FirebaseStorage.instance.ref().child(clientImagePath);
      String imageUrl = await storageRef.getDownloadURL();
      clientImageUrl = imageUrl;
      logger.config(clientImageUrl);
    } on Exception catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      clientImageUrl = null;
    }
  }

  /// uidからfirebaseのcloudStorageのパスを生成する。
  String getClientImagePath() {
    final storagePath =
        "users/${clientRef.id}/profileImg/${clientRef.id}_profile.jpeg";
    return storagePath;
  }
}
