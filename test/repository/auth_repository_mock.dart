import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:sukimachi/repository/auth_repository.dart';

import '../dummy/dummy_user.dart';

class AuthRepositoryMock implements AuthRepository {
  User? user;

  authenticate({String? userId}) async {
    // Mock sign in with Google
    final googleSignIn = MockGoogleSignIn();
    final signInAccount = await googleSignIn.signIn();
    final googleAuth = await signInAccount?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final mockUser = MockUser(
      isAnonymous: false,
      uid: userId ?? dummyUserList[0].userRef.id,
      email: 'bob@somedomain.com',
      displayName: 'Bob',
    );
    // Sign in
    final auth = MockFirebaseAuth(mockUser: mockUser);
    final result = await auth.signInWithCredential(credential);

    user = result.user;
  }

  @override
  User? get firebaseUser {
    return user;
  }

  @override
  // TODO: implement isSignIn
  bool get isSignIn => user != null;

  @override
  Future<void> signInWithGoogle() async {
    await authenticate();
  }

  @override
  Future<void> signOut() async {
    user = null;
  }

  @override
  String getEmail() {
    if (user == null) throw "ログインが必要です。";
    if (user!.email == null) throw "メールアドレスが取得できません。";
    return user!.email!;
  }
}
