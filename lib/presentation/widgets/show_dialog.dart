import 'package:flutter/material.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/presentation/login_dialog/login_dialog.dart';

/// ダイアログ
Future<void> showTextDialog(
  BuildContext context, {
  required String title,
  String? message,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: SelectableText(
          title,
        ),
        content: message != null
            ? SelectableText(
                message,
              )
            : null,
        actions: <Widget>[
          TextButton(
            child: const Text(
              'OK',
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showLoginDialog(BuildContext context) async {
  await showDialog(context: context, builder: (context) => const LoginDialog());
}

Future<void> showUserInfoNotRegisteredDialog(
    BuildContext context, bool isSignIn) async {
  await showConfirmDialog(
      context: context,
      title: 'ユーザ情報を登録する必要があります。',
      okText: '登録する。',
      function: () {
        context.go(kMyPageHomePath, isSignIn);
      });
}

Future<void> showConfirmDialog({
  required BuildContext context,
  required String title,
  String? message,
  required String okText,
  String cancelText = 'やめとく。',
  required Function function,
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: SelectableText(
          title,
        ),
        content: message != null
            ? SelectableText(
                message,
              )
            : null,
        actions: [
          TextButton(
            child: Text(
              cancelText,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              okText,
            ),
            onPressed: () async {
              await function();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
