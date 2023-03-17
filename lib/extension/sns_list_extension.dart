import 'package:sukimachi/constants.dart';

//SNSのEnumをStringに変換する拡張関数
extension StringTypeExtension on SnsList {
  static final snsListStrings = {
    SnsList.twitter: 'Twitter',
    //SnsList.facebook: 'Facebook',
    SnsList.instagram: 'Instagram',
    //SnsList.github: 'Github',
    SnsList.other: 'その他',
  };

  ///SNSのEnumをStringに変換
  String get toSnsString => snsListStrings[this]!;
}

//StringからSNSのEnumに変換する拡張関数
extension SnsListTypeExtension on String {
  SnsList toEnumSnsList() {
    return SnsList.values.firstWhere((e) => e.name == toLowerCase(),
        orElse: () => SnsList.other);
  }
}
