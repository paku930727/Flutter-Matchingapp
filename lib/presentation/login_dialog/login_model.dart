import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:sukimachi/repository/auth_repository.dart';

final loginProvider = ChangeNotifierProvider(
    (ref) => LoginModel(ref.watch(authRepositoryProvider)));

class LoginModel extends ChangeNotifier {
  LoginModel(this.authRepository);

  final AuthRepository authRepository;
  final mailController = TextEditingController();
  final passController = TextEditingController();
  bool isLoading = false;

  Future<void> signInWithGoogle() async {
    await authRepository.signInWithGoogle();
  }
}
