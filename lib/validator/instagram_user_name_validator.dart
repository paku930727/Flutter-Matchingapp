import 'package:form_field_validator/form_field_validator.dart';

/// Instagramのユーザー名規則を制限するValidator
class InstagramUserNameValidator extends TextFieldValidator {
  InstagramUserNameValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(String? value) => isCheckUserName(value!);

  /// Instagramのユーザー名規則をチェック,返却がTrueなら規則に従っている.
  /// 規則：英数字とアンダースコア(_),ピリオド(.)の文字が利用可能
  /// ユーザーネーム先頭にピリオド(.)は利用できない
  bool isCheckUserName(String instagramUrl) {
    final reg = RegExp(r"^https?://www.instagram\.com/(.*)+");
    String? userName = reg.allMatches(instagramUrl).first.group(1);
    // userNameが/で終わっている場合は取り除く
    if (userName!.endsWith("/")) {
      userName = userName.substring(0, userName.length - 1);
    }
    if (_isCheckCharacter(userName)) {
      return true;
    } else {
      return false;
    }
  }

  /// Instagramのユーザー名が英数字とアンダースコア(_)の規則に従っているならTrue
  bool _isCheckCharacter(String? userName) =>
      RegExp(r"^(?!\.)[\w.]+(?<!\.)$").hasMatch(userName!);
}
