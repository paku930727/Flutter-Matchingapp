import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/validator/validators.dart';

/// 問い合わせ画面のValidatorテスト
void main() {
  group("メールアドレスのValidatorテスト", () {
    test("[有効]有効なメールアドレス", () {
      String email = "valid@gmail.com";
      bool actual = mailValidator().isValid(email);
      expect(actual, true);
    });
    test("[無効]空文字", () {
      String email = "";
      bool actual = mailValidator().isValid(email);
      expect(actual, false);
    });
    test("[無効]無効なフォーマットのメールアドレス", () {
      String email = "invalid#com";
      bool actual = mailValidator().isValid(email);
      expect(actual, false);
    });
  });

  group("問い合わせ詳細のValidatorテスト", () {
    test("[有効]有効な問い合わせ詳細", () {
      String text = "お手数ですが、ご回答よろしくお願いいたします。";
      bool actual = contactDetailValidator().isValid(text);
      expect(actual, true);
    });
    test("[無効]空文字", () {
      String text = "";
      bool actual = contactDetailValidator().isValid(text);
      expect(actual, false);
    });
  });
}
