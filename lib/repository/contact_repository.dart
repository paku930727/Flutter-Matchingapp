import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/contact.dart';
import 'package:sukimachi/log/logger.dart';

final contactRepositoryProvider =
    Provider<ContactRepository>((ref) => ContactRepository.instance);

class ContactRepository {
  ContactRepository._();

  static final instance = ContactRepository._();
  final _firestore = FirebaseFirestore.instance;

  Future<void> sendContact(
      {required String? uid,
      required String email,
      required String contactDetail}) async {
    try {
      final userRef =
          (uid != null) ? _firestore.collection(kUsers).doc(uid) : null;
      final contactRef = _firestore.collection(kContact).doc();
      final contact = Contact(
          userRef: userRef,
          email: email,
          contactDetail: contactDetail,
          createdAt: Timestamp.now());

      await contactRef.set(contact.toMap());
    } on FirebaseException catch (e) {
      logger.severe(e);
      rethrow;
    } catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      rethrow;
    }
  }
}
