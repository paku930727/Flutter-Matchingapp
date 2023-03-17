import 'package:form_field_validator/form_field_validator.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/validator/compare_application_delivery_date.dart';
import 'package:sukimachi/validator/date_format_validator.dart';
import 'package:sukimachi/validator/instagram_user_name_validator.dart';
import 'package:sukimachi/validator/price_valiadtor.dart';
import 'package:sukimachi/validator/sns_address_character_validator.dart';
import 'package:sukimachi/validator/twitter_url_validator.dart';
import 'package:sukimachi/validator/twitter_user_name_validator.dart';

import 'instagram_url_validator.dart';

/// スキ街で利用するValidatorを集めたファイル
/// Validatorの再利用性を考慮して、ViewModelではなく、グローバル変数として扱えるファイルへ定義
/// Validatorが増えてきたら、格納場所を考慮する必要あり。

/// プロフィール名の文字数制限
const int profileNameLength = 20;

/// profile_settingの名前入力時のValidator
final profileNameValidator = MultiValidator([
  RequiredValidator(errorText: "名前を入力してください"),
  MaxLengthValidator(profileNameLength,
      errorText: "名前は$profileNameLength文字以内で入力してください")
]);

/// profile_settingのsnsAddress入力時のValidator
MultiValidator snsAddressValidator(dynamic snsList) {
  switch (snsList) {
    case null:
      return MultiValidator([MaxLengthValidator(0, errorText: "SNSを選択してください")]);
    case SnsList.twitter:
      return MultiValidator([
        RequiredValidator(errorText: "TwitterアカウントのURLを入力してください"),
        SnsAddressCharacterValidator(errorText: "SNSのURLに無効な文字が含まれています"),
        TwitterUrlValidator(
            errorText: "Twitterの正しいURLを入力してください(https://twitter.com/ユーザー名)"),
        TwitterUserNameValidator(
            errorText: "正しいユーザー名を入力してください(https://twitter.com/ユーザー名)")
      ]);
    case SnsList.instagram:
      return MultiValidator([
        RequiredValidator(errorText: "InstagramアカウントのURLを入力してください"),
        SnsAddressCharacterValidator(errorText: "SNSのURLに無効な文字が含まれています"),
        InstagramUrlValidator(
            errorText:
                "Instagramの正しいURLを入力してください(https://www.instagram.com/ユーザー名)"),
        InstagramUserNameValidator(
            errorText: "正しいユーザー名を入力してください(https://www.instagram.com/ユーザー名)")
      ]);
    case SnsList.other:
      return MultiValidator([
        RequiredValidator(errorText: "SNSアカウントのURLを入力してください"),
        SnsAddressCharacterValidator(errorText: "SNSのURLに無効な文字が含まれています"),
      ]);
    default:
      return MultiValidator([]);
  }
}

const int jobTitleLength = 20;

/// 依頼タイトルのValidator
MultiValidator jobTitleValidator() {
  return MultiValidator([
    RequiredValidator(errorText: "依頼タイトルを入力してください"),
    MaxLengthValidator(jobTitleLength,
        errorText: "依頼タイトルは、$jobTitleLength文字以内で入力してください")
  ]);
}

/// 依頼金額のValidator
MultiValidator jobPriceValidator() {
  return MultiValidator([
    RequiredValidator(errorText: "依頼金額を入力してください"),
    PriceValidator(errorText: "依頼金額は1000円以上、100円単位で入力してください")
  ]);
}

/// 応募期限のValidator
MultiValidator applicationDeadlineValidator() {
  return MultiValidator([
    RequiredValidator(errorText: "応募期限を入力してください"),
    DateFormatValidator(errorText: "応募期限日が無効なフォーマットで入力されています")
  ]);
}

/// 納品日のValidator
MultiValidator deliveryDeadlineValidator(String applicationDate) {
  return MultiValidator([
    RequiredValidator(errorText: "納品日を入力してください"),
    DateFormatValidator(errorText: "納品日が無効なフォーマットで入力されています"),
    CompareApplicationDeliveryDate(
        errorText: "納品日は応募期限日より後に設定してください", applicationDate: applicationDate)
  ]);
}

/// MailのValidator
MultiValidator mailValidator() {
  return MultiValidator([
    RequiredValidator(errorText: "メールアドレスを入力してください"),
    EmailValidator(errorText: "メールアドレスが無効なフォーマットで入力されています"),
  ]);
}

/// 　Contact詳細のValidator
MultiValidator contactDetailValidator() {
  return MultiValidator([
    RequiredValidator(errorText: "問い合わせ内容を入力してください"),
  ]);
}
