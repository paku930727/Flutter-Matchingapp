import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/validator/validators.dart';

/// 依頼作成のユニットテスト

void main() {
  group("依頼タイトルのValidatorテスト", () {
    test("[正常]正常な依頼タイトルの入力", () {
      String jobTitle = "スキ街の依頼です";
      bool expected = true;
      bool actual = jobTitleValidator().isValid(jobTitle);
      expect(actual, expected);
      String? actualSentence = jobTitleValidator().call(jobTitle);
      expect(actualSentence, null);
    });
    test("[準正常]依頼タイトルに空文字を入力", () {
      String jobTitle = "";
      bool expected = false;
      bool actual = jobTitleValidator().isValid(jobTitle);
      expect(actual, expected);
      String? actualSentence = jobTitleValidator().call(jobTitle);
      expect(actualSentence, "依頼タイトルを入力してください");
    });
    test("[準正常]文字数制限を超えた依頼タイトルの入力", () {
      String jobTitle =
          "スキ街の依頼aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
      bool expected = false;
      bool actual = jobTitleValidator().isValid(jobTitle);
      expect(actual, expected);
      String? actualSentence = jobTitleValidator().call(jobTitle);
      expect(actualSentence, "依頼タイトルは、20文字以内で入力してください");
    });
  });
  group("依頼金額のValidatorテスト", () {
    test("[正常]金額が2000円の場合", () {
      expect(jobPriceValidator().isValid("2000"), true);
    });

    test("[正常]金額が1000円の場合", () {
      expect(jobPriceValidator().isValid("1000"), true);
    });

    test("[準正常]金額が800円の場合", () {
      expect(jobPriceValidator().isValid("800"), false);
      expect(jobPriceValidator().call("800"), "依頼金額は1000円以上、100円単位で入力してください");
    });

    test("[準正常]金額が1550円の場合", () {
      expect(jobPriceValidator().isValid("1550"), false);
      expect(jobPriceValidator().call("1550"), "依頼金額は1000円以上、100円単位で入力してください");
    });
    test("[準正常]依頼金額で空文字を入力", () {
      String jobPrice = "";
      bool expected = false;
      bool actual = jobPriceValidator().isValid(jobPrice);
      expect(actual, expected);
      String? actualSentence = jobPriceValidator().call(jobPrice);
      expect(actualSentence, "依頼金額を入力してください");
    });
  });
  group("納品日のValidatorテスト", () {
    test("[正常]正常な日付の入力", () {
      String deliveryDate = "2022/08/22";
      String applicationDate = "2022/08/21";
      bool expected = true;
      bool actual =
          deliveryDeadlineValidator(applicationDate).isValid(deliveryDate);
      expect(actual, expected);
      String? actualSentence =
          deliveryDeadlineValidator(applicationDate).call(deliveryDate);
      expect(actualSentence, null);
    });
    test("[準正常]日付入力のフォーマットが謝っている場合", () {
      String deliveryDate = "2022/08/2";
      String applicationDate = "2022/08/21";
      bool expected = false;
      bool actual =
          deliveryDeadlineValidator(applicationDate).isValid(deliveryDate);
      expect(actual, expected);
      String? actualSentence =
          deliveryDeadlineValidator(applicationDate).call(deliveryDate);
      expect(actualSentence, "納品日が無効なフォーマットで入力されています");
    });
    test("[準正常]納品日より応募期限が後になっている場合", () {
      String deliveryDate = "2022/08/22";
      String applicationDate = "2022/08/23";
      bool expected = false;
      bool actual =
          deliveryDeadlineValidator(applicationDate).isValid(deliveryDate);
      expect(actual, expected);
      String? actualSentence =
          deliveryDeadlineValidator(applicationDate).call(deliveryDate);
      expect(actualSentence, "納品日は応募期限日より後に設定してください");
    });
  });
}
