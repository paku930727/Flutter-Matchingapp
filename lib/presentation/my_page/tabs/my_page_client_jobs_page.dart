import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/job.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/presentation/my_page/my_page_model.dart';
import 'package:sukimachi/presentation/profile_setting_dialog/profile_setting_dialog.dart';
import 'package:sukimachi/presentation/profile_setting_dialog/profile_setting_model.dart';
import 'package:sukimachi/repository/auth_repository.dart';

import '../../widgets/job_card.dart';

/// マイページで依頼一覧を表示する
class MyPageClientJobs extends ConsumerWidget {
  const MyPageClientJobs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// myPageの状態を監視
    final myPageState = ref.watch(myPageProvider);
    final profileSettingState = ref.watch(profileSettingProvider);
    final authState = ref.watch(authRepositoryProvider);

    /// Jobs表示用のカード一覧
    List<Widget> clientJobsCardList(List<Job> jobs) {
      if (jobs.isEmpty) {
        return [const Text('依頼履歴がありません')];
      } else {
        return jobs
            .map((job) => SizedBox(
                  width: kThreeDivideWidth,
                  child: JobsPageCard(
                    job: job,
                    onTap: () async {
                      await profileSettingState.checkRegisteredUserInfo();
                      if (myPageState.hasUser) {
                        context.go('/myPage/jobDetail/${job.jobRef.id}',
                            authState.isSignIn);
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => const ProfileSettingDialog(),
                        );
                      }
                    },
                  ),
                ))
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
          children: clientJobsCardList(myPageState.myClientJobs),
        ),
      );
    }
  }
}
