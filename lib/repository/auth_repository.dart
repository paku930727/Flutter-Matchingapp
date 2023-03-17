import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

class AuthRepository {
  AuthRepository();
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.email',
    ],
  );

  /// ログイン中Firebaseユーザを返す
  User? get firebaseUser => _auth.currentUser;

  /// ログイン中かどうかを返す
  bool get isSignIn => _auth.currentUser != null;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  String getEmail() {
    if (_auth.currentUser == null) {
      throw "ログインが必要です。";
    }
    if (_auth.currentUser!.email == null) {
      throw "メールアドレスが取得できませんでした。";
    }
    return _auth.currentUser!.email!;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
