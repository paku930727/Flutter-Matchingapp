import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sukimachi/log/logger.dart';

class Application {
  Application(
      {required this.applicationRef,
      required this.jobRef,
      required this.clientRef,
      required this.applicantRef,
      required this.jobTitle,
      required this.jobPrice,
      required this.clientName,
      required this.applicantName,
      required this.status,
      required this.createdAt,
      required this.updatedAt});

  final DocumentReference applicationRef;
  final DocumentReference jobRef;
  final DocumentReference clientRef;
  final DocumentReference applicantRef;
  final String jobTitle;
  final int jobPrice;
  final String clientName;
  String? clientImageUrl;
  final String applicantName;
  String? applicantImageUrl;
  final String status; // NONE,ACCEPTED,
  final Timestamp createdAt;
  final Timestamp updatedAt;

  factory Application.fromJson(Map data) {
    return Application(
        applicationRef: data['applicationRef'],
        jobRef: data['jobRef'],
        clientRef: data['clientRef'],
        applicantRef: data['applicantRef'],
        jobTitle: data['jobTitle'],
        jobPrice: data['jobPrice'],
        clientName: data['clientName'],
        applicantName: data['applicantName'],
        status: data['status'],
        createdAt: data['createdAt'],
        updatedAt: data['updatedAt']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'applicationRef': applicationRef,
      'jobRef': jobRef,
      'clientRef': clientRef,
      'applicantRef': applicantRef,
      'jobTitle': jobTitle,
      'jobPrice': jobPrice,
      'clientName': clientName,
      'applicantName': applicantName,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// ClientImage画像のURLを取得するメソッド
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

  /// ApplicantImage画像のURLを取得するメソッド
  Future<void> setApplicantImageUrl() async {
    try {
      String applicantImagePath = getApplicantImagePath();
      final storageRef =
          FirebaseStorage.instance.ref().child(applicantImagePath);
      String imageUrl = await storageRef.getDownloadURL();
      applicantImageUrl = imageUrl;
      logger.config(applicantImageUrl);
    } on Exception catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      applicantImageUrl = null;
    }
  }

  /// uidからfirebaseのcloudStorageのパスを生成する。
  String getApplicantImagePath() {
    final storagePath =
        "users/${applicantRef.id}/profileImg/${applicantRef.id}_profile.jpeg";
    return storagePath;
  }
}
