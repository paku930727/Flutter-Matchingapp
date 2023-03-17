import 'package:flutter/material.dart';
import 'package:sukimachi/constants.dart';

/// Validatorが動くダイアログである。
///
///ex)
///showDialog(context: context, builder: (context) => CustomTextFieldDialog(
/// title:'Title', content: widget you wanna show dialog, defaultActionText: 'OK'););
class CustomTextFieldDialog extends StatelessWidget {
  const CustomTextFieldDialog({
    Key? key,
    required this.title,
    required this.contentWidget,
    this.cancelActionText,
    this.cancelAction,
    required this.defaultActionText,
    this.action,
    this.onWillPopAction,
  }) : super(key: key);

  /// ダイアログのトップに表示する文字
  final String title;

  /// ダイアログ内に表示するウィジェット
  final Widget contentWidget;

  /// キャンセルボタンのテキスト
  final String? cancelActionText;

  /// キャンセルボタン押下時に動かす関数
  final Function? cancelAction;

  /// アクションボタン押下時の表示文字,例)'OK'
  final String defaultActionText;

  /// アクションボタン押下時に動かす関数
  final Function? action;

  /// ダイアログが消えた際に動かす関数
  final Function? onWillPopAction;

  @override
  Widget build(BuildContext context) {
    const key = GlobalObjectKey<FormState>('FORM_KEY');
    return WillPopScope(
      child: AlertDialog(
        title: Text(title),
        content: Form(
          key: key,
          child: contentWidget,
        ),
        actions: [
          if (cancelActionText != null)
            MaterialButton(
              height: 40,
              color: kSecondaryColor,
              onPressed: () {
                if (cancelAction != null) cancelAction!();
                Navigator.of(context).pop(false);
              },
              child: Text(
                cancelActionText!,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          MaterialButton(
            height: 40,
            color: kSecondaryColor,
            onPressed: () async {
              if (key.currentState!.validate()) {
                if (action != null) await action!();
                Navigator.of(context).pop(false);
              }
            },
            child: Text(
              defaultActionText,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      onWillPop: () async {
        if (onWillPopAction != null) await onWillPopAction!();
        return true;
      },
    );
  }
}
