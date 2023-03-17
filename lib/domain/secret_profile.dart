import 'package:cloud_firestore/cloud_firestore.dart';

class SecretProfile {
  SecretProfile({this.point = 0, required this.secretProfileRef});
  final int point;
  final DocumentReference secretProfileRef;

  factory SecretProfile.fromMap(Map<String, dynamic> map) {
    return SecretProfile(
        point: map['point'], secretProfileRef: map['secretProfileRef']);
  }
}
