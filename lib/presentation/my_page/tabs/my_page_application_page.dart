import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/my_page/my_page_model.dart';
import 'package:sukimachi/presentation/profile_setting_dialog/profile_setting_dialog.dart';
import 'package:sukimachi/presentation/widgets/applications_page_card.dart';

import '../../../domain/application.dart';

/// マイページで依頼一覧を表示する
class MyPageApplicationPage extends ConsumerWidget {
  const MyPageApplicationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// myPageの状態を監視
    final myPageState = ref.watch(myPageProvider);

    /// Jobs表示用のカード一覧
    List<Widget> myApplicationCardsList(List<Application> applications) {
      if (applications.isEmpty) {
        return [const Text('依頼履歴がありません')];
      } else {
        return applications
            .map((application) => SizedBox(
                width: kThreeDivideWidth,
                child: ApplicationsPageCard(
                  application: application,
                )))
            .toList();
      }
    }

    //Todo ユーザー情報がない場合、ユーザー登録をするように促す
    if (!myPageState.hasUser) {
      return Column(
        children: [
          const Text('ユーザー情報を登録する必要があります。'),
          TextButton(
            child: const Text('ここからユーザー登録が可能です。'),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => const ProfileSettingDialog(),
              );
            },
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          children: myApplicationCardsList(myPageState.myApplications),
        ),
      );
    }
  }
}
