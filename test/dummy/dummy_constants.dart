// documentId

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final fakeFirebaseFirestore = FakeFirebaseFirestore();

/// ダミーユーザ:宮路
final miyajiUserRef =
    fakeFirebaseFirestore.collection('users').doc(const Uuid().v4());
const miyajiUserName = '宮路洸';

// ダミーjobRef:スキ街制作
final miyajiSukimachiJobRef =
    fakeFirebaseFirestore.collection('jobs').doc("miyajikou");
const miyajiSukimachiJobTitle = 'スキ街制作';

// ダミーjobRef:Twitterイラスト
final miyajiTwitterJobRef =
    fakeFirebaseFirestore.collection('jobs').doc("twitter");
const miyajiTwitterJobTitle = 'twitterのイラスト';

// ダミーユーザ:テスト
final testUserRef =
    fakeFirebaseFirestore.collection('users').doc(const Uuid().v4());
const testUserName = '私は最小限のパラメータを持っている';

final testUserJobRef =
    fakeFirebaseFirestore.collection('jobs').doc(const Uuid().v4());
const testUserJobTitle = 'テストユーザの依頼です';

final testUserJobRef2 =
    fakeFirebaseFirestore.collection('jobs').doc(const Uuid().v4());
const testUserJobTitle2 = 'テストユーザの依頼です2';

// ダミーユーザ:フル
final fullUserRef =
    fakeFirebaseFirestore.collection('users').doc(const Uuid().v4());
const fullUserName = '私は全部のパラメータを持っている';
