import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/presentation/contact/contact_model.dart';
import 'package:sukimachi/presentation/default/default_page.dart';

import '../../constants.dart';
import '../../validator/validators.dart';
import '../widgets/show_dialog.dart';
import 'contact_result.dart';

class ContactPage extends ConsumerWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactState = ref.watch(contactProvider);
    final _formKey = GlobalKey<FormState>();
    Widget contact() {
      return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            const Text(
              "お問い合わせ",
              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "スキ街について何かございましたらこちらよりお問い合わせください",
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 30),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "メールアドレス",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                )),
            TextFormField(
                controller: contactState.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: mailValidator(),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                textInputAction: TextInputAction.next),
            const SizedBox(height: 20),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "お問い合わせ内容の詳細",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                )),
            TextFormField(
              controller: contactState.contactDetailController,
              keyboardType: TextInputType.multiline,
              validator: contactDetailValidator(),
              maxLines: null,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              height: 40,
              child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() == true) {
                      final result = await contactState.sendContact();
                      switch (result) {
                        case ContactResult.success:
                          const noNeedLoginCheck = true;
                          context.go(kContactSuccessPath, noNeedLoginCheck);
                          break;
                        case ContactResult.firebaseError:
                          showTextDialog(context, title: "送信に失敗しました");
                          break;
                        case ContactResult.unknownError:
                          showTextDialog(context, title: "予期せぬエラーが発生しました");
                          break;
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor),
                  child: const Text("送信", style: TextStyle(fontSize: 16.0))),
            )
          ]),
        ),
      );
    }

    return DefaultPage(
      bodyWidget: contact(),
      pageName: "contact",
    );
  }
}
