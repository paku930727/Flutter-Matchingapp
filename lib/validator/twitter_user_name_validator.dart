import 'package:form_field_validator/form_field_validator.dart';

/// Twitterのユーザー名規則を制限するValidator
class TwitterUserNameValidator extends TextFieldValidator {
  TwitterUserNameValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(String? value) => isCheckUserName(value!);

  /// Twitterのユーザー名規則をチェック,返却がTrueなら規則に従っている.
  /// 規則：英数字とアンダースコアの文字が利用+ユーザー名が15文字以内
  bool isCheckUserName(String twitterUrl) {
    final reg = RegExp(r"^https?://twitter\.com/(.*)+");
    String? userName = reg.allMatches(twitterUrl).first.group(1);
    // userNameが/で終わっている場合は取り除く
    if (userName!.endsWith("/")) {
      userName = userName.substring(0, userName.length - 1);
    }
    if (_isCheckCharacter(userName) && _isCheckLength(userName)) {
      return true;
    } else {
      return false;
    }
  }

  /// Twitterのユーザー名が英数字とアンダースコア(_)の規則に従っているならTrue
  bool _isCheckCharacter(String? userName) =>
      RegExp(r"^[a-zA-Z0-9_]+$").hasMatch(userName!);

  /// Twitterのユーザー名が15文字以内ならTrue
  bool _isCheckLength(String? userName) {
    if (userName!.isNotEmpty && userName.length <= 15) {
      return true;
    } else {
      return false;
    }
  }
}
