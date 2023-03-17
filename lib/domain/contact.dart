import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  Contact(
      {required this.userRef,
      required this.email,
      required this.contactDetail,
      required this.createdAt});

  final DocumentReference? userRef;
  final String email;
  final String contactDetail;
  final Timestamp createdAt;

  Map<String, dynamic> toMap() {
    return {
      "userRef": userRef,
      "email": email,
      "contactDetail": contactDetail,
      "createdAt": createdAt
    };
  }
}
