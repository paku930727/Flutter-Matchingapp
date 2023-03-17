import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/validator/validators.dart';

/// プロフィール登録のValidatorテスト
void main() {
  group("プロフィール名のValidatorのテスト", () {
    test("[正常]正常な名前の入力", () {
      String profileName = "Sukimachi3スキmachi3マチ";
      bool expected = true;
      bool actual = profileNameValidator.isValid(profileName);
      expect(actual, expected);
      String? actualSentence = profileNameValidator.call(profileName);
      expect(actualSentence, null);
    });
    test("[準正常]空文字を入力", () {
      String profileName = "";
      bool expected = false;
      bool actual = profileNameValidator.isValid(profileName);
      expect(actual, expected);
      String? expectedSentence = "名前を入力してください";
      String? actualSentence = profileNameValidator.call(profileName);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]文字制限以上を入力", () {
      String profileName = "Sukimachi3スキmachi3マチ3";
      bool expected = false;
      bool actual = profileNameValidator.isValid(profileName);
      expect(actual, expected);
      String? expectedSentence = "名前は20文字以内で入力してください";
      String? actualSentence = profileNameValidator.call(profileName);
      expect(actualSentence, expectedSentence);
    });
  });

  group("snsAddressのValidatorのテスト", () {
    test("[正常]snsが何も選択されていないかつsnsAddressが空の場合", () {
      const snsList = null;
      const snsAddress = "";
      bool expected = true;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, null);
    });
    test("[準正常]snsが何も選択されていないかつsnsAddressが入力されている場合", () {
      const snsList = null;
      const snsAddress = "https://twitter.com/sukimachi";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence = "SNSを選択してください";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[正常]snsがtwitterかつsnsAddressが正しく入力された場合", () {
      const snsList = SnsList.twitter;
      const snsAddress = "https://twitter.com/sukimachi";
      bool expected = true;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, null);
    });
    test("[正常]snsがtwitterかつsnsAddress(/で終了)が正しく入力された場合", () {
      const snsList = SnsList.twitter;
      const snsAddress = "https://twitter.com/sukimachi/";
      bool expected = true;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, null);
    });
    test("[準正常]snsがtwitterかつsnsAddressが空の場合", () {
      const snsList = SnsList.twitter;
      const snsAddress = "";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence = "TwitterアカウントのURLを入力してください";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]snsがtwitterかつsnsAddressの入力に無効な文字が入力されている場合", () {
      const snsList = SnsList.twitter;
      const snsAddress = "https://twitter.com/スキ街";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence = "SNSのURLに無効な文字が含まれています";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]snsがtwitterかつsnsAddressの入力が他のSNSのアドレスになっている場合", () {
      const snsList = SnsList.twitter;
      const snsAddress = "https://witter.com/sukimachi";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence =
          "Twitterの正しいURLを入力してください(https://twitter.com/ユーザー名)";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]snsがtwitterかつsnsAddressの入力でユーザー名が規則に従っていない場合", () {
      //twitterのユーザー名は英数字とアンダースコアの文字が利用可能+長さは15文字以内
      const snsList = SnsList.twitter;
      const snsAddress = "https://twitter.com/sukimachi_333333";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence = "正しいユーザー名を入力してください(https://twitter.com/ユーザー名)";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]snsがtwitterかつsnsAddressの入力でユーザー名が規則に従っていない場合", () {
      //twitterのユーザー名は英数字とアンダースコアの文字が利用可能+長さは15文字以内
      const snsList = SnsList.twitter;
      const snsAddress = "https://twitter.com/sukimachi_.3333";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence = "正しいユーザー名を入力してください(https://twitter.com/ユーザー名)";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]snsがtwitterかつsnsAddressの入力でユーザー名が規則に従っていない場合", () {
      //twitterのユーザー名は英数字とアンダースコアの文字が利用可能+長さは15文字以内
      const snsList = SnsList.twitter;
      const snsAddress = "https://twitter.com/sukimachi_/3333/";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence = "正しいユーザー名を入力してください(https://twitter.com/ユーザー名)";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });

    // Instagramのvalidatorテスト
    test("[正常]snsがinstagramかつsnsAddressが正しく入力された場合", () {
      const snsList = SnsList.instagram;
      const snsAddress = "https://www.instagram.com/sukimachi";
      bool expected = true;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, null);
    });
    test("[正常]snsがinstagramかつsnsAddress(/で終了)が正しく入力された場合", () {
      const snsList = SnsList.instagram;
      const snsAddress = "https://www.instagram.com/sukimachi/";
      bool expected = true;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, null);
    });
    test("[正常]snsがinstagramかつsnsAddress(.が入っている)が正しく入力された場合", () {
      const snsList = SnsList.instagram;
      const snsAddress = "https://www.instagram.com/suki.00machi";
      bool expected = true;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, null);
    });
    test("[準正常]snsがinstagramかつsnsAddressが空の場合", () {
      const snsList = SnsList.instagram;
      const snsAddress = "";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence = "InstagramアカウントのURLを入力してください";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]snsがinstagramかつsnsAddressの入力に無効な文字が入力されている場合", () {
      const snsList = SnsList.instagram;
      const snsAddress = "https://www.instagram.com/スキ街";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence = "SNSのURLに無効な文字が含まれています";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]snsがinstagramかつsnsAddressの入力が他のSNSのアドレスになっている場合", () {
      const snsList = SnsList.instagram;
      const snsAddress = "https://twitter.com/sukimachi";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence =
          "Instagramの正しいURLを入力してください(https://www.instagram.com/ユーザー名)";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]snsがinstagramかつsnsAddressの入力でユーザー名が規則に従っていない場合", () {
      // Instagramのユーザー名は英数字とアンダースコア,ピリオドが利用可能
      // 先頭と末尾にはピリオドが使用不可
      const snsList = SnsList.instagram;
      const snsAddress = "https://www.instagram.com/sukimachi_3333.";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence =
          "正しいユーザー名を入力してください(https://www.instagram.com/ユーザー名)";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]snsがinstagramかつsnsAddressの入力でユーザー名が規則に従っていない場合", () {
      // Instagramのユーザー名は英数字とアンダースコア,ピリオドが利用可能
      // 先頭と末尾にはピリオドが使用不可
      const snsList = SnsList.instagram;
      const snsAddress = "https://www.instagram.com/.sukimachi_3333";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence =
          "正しいユーザー名を入力してください(https://www.instagram.com/ユーザー名)";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
    test("[準正常]snsがinstagramかつsnsAddressの入力でユーザー名が規則に従っていない場合", () {
      // Instagramのユーザー名は英数字とアンダースコア,ピリオドが利用可能
      // 先頭と末尾にはピリオドが使用不可
      const snsList = SnsList.instagram;
      const snsAddress = "https://www.instagram.com/sukimachi.-3333";
      bool expected = false;
      bool actual = snsAddressValidator(snsList).isValid(snsAddress);
      expect(actual, expected);
      String? expectedSentence =
          "正しいユーザー名を入力してください(https://www.instagram.com/ユーザー名)";
      String? actualSentence = snsAddressValidator(snsList).call(snsAddress);
      expect(actualSentence, expectedSentence);
    });
  });
}
