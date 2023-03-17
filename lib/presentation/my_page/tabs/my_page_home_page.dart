import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/presentation/job_create_dialog/job_create_dialog.dart';
import 'package:sukimachi/presentation/my_page/my_page_model.dart';
import 'package:sukimachi/presentation/profile_setting_dialog/profile_setting_dialog.dart';
import 'package:sukimachi/presentation/profile_setting_dialog/profile_setting_model.dart';
import 'package:sukimachi/presentation/widgets/responsive.dart';
import 'package:sukimachi/presentation/widgets/show_dialog.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import '../../widgets/profile_page_card.dart';
import 'package:universal_html/html.dart' as html;

/// MyPageのHome画面を表示する。
///
/// プロフィール画面と依頼一覧と受注一覧を全て表示する。
class MyPageHome extends ConsumerWidget {
  const MyPageHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// myPageの状態を監視
    final myPageState = ref.watch(myPageProvider);
    final profileSettingState = ref.watch(profileSettingProvider);
    final isSignIn = ref.watch(authRepositoryProvider).isSignIn;

    Widget profileCard() {
      if (myPageState.currentUser == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return InkWell(
        child: Responsive(
          desktop: ProfilePageCard(
            user: myPageState.currentUser!,
            secretProfile: myPageState.secretProfile,
            screenType: ScreenType.desktop,
          ),
          tablet: ProfilePageCard(
            user: myPageState.currentUser!,
            secretProfile: myPageState.secretProfile,
            screenType: ScreenType.tablet,
          ),
          mobile: ProfilePageCard(
            user: myPageState.currentUser!,
            secretProfile: myPageState.secretProfile,
            screenType: ScreenType.mobile,
          ),
        ),
        onTap: () async {
          // プロフィール編集中に閉じたら値が変更されるため。
          await profileSettingState.checkRegisteredUserInfo();
          await showDialog(
            context: context,
            builder: (context) => const ProfileSettingDialog(),
          );
        },
      );
    }

    /// MyPageのUI
    if (myPageState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      if (!myPageState.hasUser) {
        return Column(
          children: [
            const Text('ユーザー情報を登録する必要があります。'),
            TextButton(
              child: const Text('ここからユーザー登録が可能です。'),
              onPressed: () async {
                // ユーザー情報登録・編集
                // プロフィール編集中に閉じたら値が変更されるため。
                // 登録時に、ダイアログを閉じても値を残す仕様にするのであれば、呼ばない。
                //await profileSettingState.checkResisteredUserInfo();
                showDialog(
                  context: context,
                  builder: (context) => const ProfileSettingDialog(),
                );
              },
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            profileCard(),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              height: 55,
              color: kSecondaryColor,
              onPressed: () async {
                await profileSettingState.checkRegisteredUserInfo();
                if (myPageState.hasUser) {
                  showDialog(
                    context: context,
                    builder: (context) => const JobCreateDialog(),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => const ProfileSettingDialog(),
                  );
                }
              },
              child: const Text(
                '依頼を作成する',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              height: 55,
              color: kSecondaryColor,
              onPressed: () {
                context.go(kGiftPagePath, isSignIn);
              },
              child: const Text(
                'ギフト一覧を見る',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              height: 55,
              color: kGreyColor,
              onPressed: () async {
                await showConfirmDialog(
                  context: context,
                  title: "退会申請",
                  message: '''
退会の申請をしますか？
退会するとアカウントは削除され現在のアカウントにログインすることはできなくなります。

退会の条件
・公開中の依頼がないこと
・審査中、契約中の応募がないこと
・審査中、契約中の応募がある依頼がないこと
''',
                  okText: '申請をする。',
                  function: () async {
                    try {
                      await myPageState.deleteAccount(
                          showTextDialog: (String title) async {
                        await showTextDialog(context, title: title);
                      });
                      html.window.location.reload();
                    } catch (e) {
                      await showTextDialog(context, title: e.toString());
                    }
                  },
                );
              },
              child: const Text(
                '退会する',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      }
    }
  }
}
