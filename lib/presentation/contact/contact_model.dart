import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/repository/contact_repository.dart';

import 'contact_result.dart';

final contactProvider = ChangeNotifierProvider.autoDispose((ref) =>
    ContactModel._(
        contactRepository: ref.watch(contactRepositoryProvider),
        authRepository: ref.watch(authRepositoryProvider)));

class ContactModel extends ChangeNotifier {
  ContactModel._(
      {required this.contactRepository, required this.authRepository});

  final ContactRepository contactRepository;
  final AuthRepository authRepository;

  TextEditingController emailController = TextEditingController();
  TextEditingController contactDetailController = TextEditingController();

  Future<ContactResult> sendContact() async {
    try {
      await contactRepository.sendContact(
          uid: authRepository.firebaseUser?.uid,
          email: emailController.text,
          contactDetail: contactDetailController.text);
      return ContactResult.success;
    } on FirebaseException {
      return ContactResult.firebaseError;
    } catch (e) {
      return ContactResult.unknownError;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    contactDetailController.dispose();
    super.dispose();
  }
}
