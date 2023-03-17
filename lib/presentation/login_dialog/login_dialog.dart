import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/presentation/login_dialog/login_model.dart';
import 'package:sukimachi/presentation/widgets/show_dialog.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginDialog extends ConsumerWidget {
  const LoginDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    return AlertDialog(
      title: const Text("スキ街"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SignInButton(
            Buttons.Google,
            onPressed: () async {
              try {
                await state.signInWithGoogle();
                context.go(kMyPageHomePath,
                    ref.watch(authRepositoryProvider).isSignIn);
              } on PlatformException catch (e) {
                if (e.code == "popup_blocked_by_browser") {
                  await showTextDialog(context,
                      title: "ポップアップブロックによってエラーが発生しました。\nもう一度お試しください。");
                } else {
                  await showTextDialog(context, title: '予期せぬエラーが発生しました。');
                }
              } catch (e) {
                await showTextDialog(context, title: '予期せぬエラーが発生しました。');
              }
            },
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: () async {
                await launchUrlString(preReleaseSlideUrl);
              },
              child: const Text("プレリリースについて")),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("cancel"),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }
}
