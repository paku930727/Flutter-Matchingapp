/// Firestoreのユーザーデータが空の場合の例外処理
class UserNullException implements Exception {
  final String? _message = 'ユーザーの基本情報登録がされていません。';
  String? get message => _message;
  @override
  String toString() => _message!;
}
