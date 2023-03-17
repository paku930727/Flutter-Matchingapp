import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/contact.dart';
import 'package:sukimachi/repository/contact_repository.dart';

class ContactRepositoryMock implements ContactRepository {
  final fakeFirebaseFirestore = FakeFirebaseFirestore();

  @override
  Future<void> sendContact(
      {required String? uid,
      required String email,
      required String contactDetail}) async {
    final userRef = (uid != null)
        ? fakeFirebaseFirestore.collection(kUsers).doc(uid)
        : null;
    final contactRef = fakeFirebaseFirestore.collection(kContact).doc();

    final contact = Contact(
        userRef: userRef,
        email: email,
        contactDetail: contactDetail,
        createdAt: Timestamp.now());

    contactRef.set(contact.toMap());
  }
}
