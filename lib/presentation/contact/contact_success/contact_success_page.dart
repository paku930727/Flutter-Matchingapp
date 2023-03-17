import 'package:flutter/material.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/presentation/default/default_page.dart';

import '../../../constants.dart';

class ContactSuccessPage extends StatefulWidget {
  const ContactSuccessPage({Key? key}) : super(key: key);

  @override
  State<ContactSuccessPage> createState() => _ContactSuccessPageState();
}

class _ContactSuccessPageState extends State<ContactSuccessPage> {
  @override
  Widget build(BuildContext context) {
    Widget contactSuccess() {
      return Column(children: [
        const SizedBox(height: 16),
        const Text(
          "お問い合わせありがとうございます",
          style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "メッセージが送信されました",
          style: TextStyle(fontSize: 16.0),
        ),
        const Text(
          "後日担当者から連絡させていただきますのでいましばらくお待ちください",
          style: TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 60),
        SizedBox(
          width: 300,
          height: 40,
          child: ElevatedButton(
              onPressed: () {
                const noNeedLoginCheck = true;
                context.go(kMyPageHomePath, noNeedLoginCheck);
              },
              style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
              child: const Text("トップページに戻る", style: TextStyle(fontSize: 16.0))),
        )
      ]);
    }

    return DefaultPage(
        bodyWidget: contactSuccess(), pageName: "contact_success");
  }
}
