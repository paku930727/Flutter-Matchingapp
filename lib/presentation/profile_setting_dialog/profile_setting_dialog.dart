import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/profile_setting_dialog/profile_setting_model.dart';
import 'package:sukimachi/presentation/widgets/circle_profile_img.dart';
import 'package:sukimachi/presentation/widgets/custom_text_field_dialog.dart';
import 'package:sukimachi/presentation/widgets/show_dialog.dart';
import 'package:sukimachi/validator/validators.dart';
import 'package:universal_html/html.dart' as html;

/// プロフィール編集用のダイアログウィジェット
///
/// Viewのページに書くと、notifyListenersによってダイアログ内の画面更新がされないため、
/// ウィジェットを分けて対処した。
class ProfileSettingDialog extends ConsumerWidget {
  const ProfileSettingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileSettingState = ref.watch(profileSettingProvider);

    /// ドロップダウンの表示アイテム
    final dropDownItems = [
      const DropdownMenuItem(
        child: Text('Twitter'),
        value: SnsList.twitter,
      ),
      const DropdownMenuItem(
        child: Text('Instagram'),
        value: SnsList.instagram,
      ),
      const DropdownMenuItem(child: Text('その他'), value: SnsList.other),
    ];
    return CustomTextFieldDialog(
      title: 'プロフィール編集',
      cancelActionText: 'キャンセル',
      cancelAction: () {
        profileSettingState.cancel();
      },
      defaultActionText: 'OK',
      action: () async {
        final resultMessage = await profileSettingState.sendAction();
        await showTextDialog(
          context,
          title: resultMessage,
        );
        html.window.location.reload();
      },
      onWillPopAction: () {
        profileSettingState.resetPickedImg();
      },
      contentWidget: SingleChildScrollView(
        child: SizedBox(
          //Todo 横幅調整
          width: 620,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// プロフィール画像
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleProfileImg(
                        photoUrl: profileSettingState.currentUser?.userImageUrl,
                        pickedImg: profileSettingState.pickedImg,
                        onTapAction: () async {
                          await profileSettingState.onTapProfileUrl();
                        },
                        radius: 160),
                  ],
                ),

                /// 名前のテキストフォーム
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ユーザー名 (変更ができません。)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: profileSettingState.userNameController,
                      keyboardType: TextInputType.multiline,
                      readOnly: profileSettingState.currentUser != null,
                      maxLines: null,
                      textInputAction: TextInputAction.next,
                      validator: profileNameValidator,
                      decoration: const InputDecoration(
                          hintText: 'スキ街 太郎',
                          errorMaxLines: 3,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 性別のセレクト
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('性別'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Radio(
                          activeColor: kSecondaryColor,
                          value: 0,
                          groupValue: profileSettingState.sex,
                          onChanged: (value) {
                            profileSettingState.changeSex(value as int);
                          },
                        ),
                        const Text("男性"),
                        Radio(
                          activeColor: kSecondaryColor,
                          value: 1,
                          groupValue: profileSettingState.sex,
                          onChanged: (value) {
                            profileSettingState.changeSex(value as int);
                          },
                        ),
                        const Text("女性"),
                        Radio(
                          activeColor: kSecondaryColor,
                          value: 9,
                          groupValue: profileSettingState.sex,
                          onChanged: (value) {
                            profileSettingState.changeSex(value as int);
                          },
                        ),
                        const Text("その他"),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),

                /// 受注者への一言
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('受注者への一言'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: profileSettingState.introForClientController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                          hintText: '会話しながら、進めていきたいです',
                          errorMaxLines: 3,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                /// 依頼者への一言
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('依頼者への一言'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller:
                        profileSettingState.introForContractorController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'アプリ開発経験者です',
                        errorMaxLines: 3,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightBlue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        )),
                  ),
                ]),
                const SizedBox(height: 30),

                // SNSリスト編集
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SNSのURL'),
                    const SizedBox(height: 6),
                    for (int index = 0;
                        index < profileSettingState.snsCount;
                        index++)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            DropdownButton(
                              hint: const Text("SNS名"),
                              items: dropDownItems,
                              onChanged: (value) {
                                profileSettingState.changeSnsName(index, value);
                              },
                              value: profileSettingState.snsUrlFormList[index]
                                  [snsName],
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                  controller: profileSettingState
                                      .snsUrlFormList[index][snsAddress],
                                  keyboardType: TextInputType.text,
                                  validator: snsAddressValidator(
                                    profileSettingState.snsUrlFormList[index]
                                        [snsName],
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'SNSのURL',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black26),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.lightBlue),
                                    ),
                                  )),
                            ),
                            IconButton(
                              onPressed: () {
                                profileSettingState.deleteSnsComponent(index);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: IconButton(
                        tooltip: 'SNSの入力欄を追加',
                        onPressed: () {
                          profileSettingState.addSnsUrlListForm();
                        },
                        icon: const Icon(Icons.add),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
