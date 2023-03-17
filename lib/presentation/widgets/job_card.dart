import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sukimachi/constants.dart';
import 'package:sukimachi/extension/date_extension.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/presentation/job_detail/job_detail_model.dart';
import 'package:sukimachi/presentation/my_page/my_page_job_detail/my_page_job_detail_model.dart';
import 'package:sukimachi/presentation/widgets/circle_image.dart';
import 'package:sukimachi/presentation/widgets/show_dialog.dart';
import 'package:sukimachi/presentation/widgets/status_chip.dart';
import 'package:sukimachi/presentation/widgets/useful_card.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../domain/job.dart';
import 'between_column.dart';
import 'between_column_child.dart';

class JobStatusChip extends StatelessWidget {
  const JobStatusChip({Key? key, required this.status}) : super(key: key);
  final String status;

  String getStatusText() {
    switch (status) {
      case kJobStatusPrivate:
        return kJobStatusPrivateView;
      case kJobStatusPublic:
        return kJobStatusPublicView;
      case kJobStatusClosed:
        return kJobStatusClosedView;
      default:
        return kJobStatusUnknownView;
    }
  }

  Color getStatusColor() {
    switch (status) {
      case kJobStatusPrivate:
        return kPrimaryColor;
      case kJobStatusPublic:
        return kSecondaryColor;
      case kJobStatusClosed:
        return kGreyColor;
      default:
        return kGreyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusChip(backgroundColor: getStatusColor(), text: getStatusText());
  }
}

class JobCard extends ConsumerWidget {
  const JobCard(this.id,
      {Key? key, required this.isMyPage, required this.screenType})
      : super(key: key);
  final String id;
  final ScreenType screenType;
  final bool isMyPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final JobDetailModel state = isMyPage
        ? ref.watch(myPageJobDetailProvider(id))
        : ref.watch(jobDetailProvider(id));
    final isSignIn = ref.watch(authRepositoryProvider).isSignIn;

    /// デスクトップ用のCenterBody
    Widget? desktopCenterBody() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            height: 100,
            width: 100,
            child: InkWell(
                onTap: () {
                  context.go("/profile/${state.job!.clientRef.id}", isSignIn);
                },
                child: CircleImage(
                    url: state.job!.clientImageUrl, assetPath: kIconImagePath)),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              state.job!.clientName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("受注報酬:" + state.job!.jobPrice.toString() + "pt"),
              Text("応募締め切り:" +
                  state.job!.applicationDeadline.toFormatYMDString()),
              Text("納品締め切り:" + state.job!.deliveryDeadline.toFormatYMDString()),
            ],
          ),
        ],
      );
    }

    /// タブレット/モバイル用のCenterBody
    Widget? tabletCenterBody() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                height: 100,
                width: 100,
                child: InkWell(
                    onTap: () {
                      context.go(
                          "/profile/${state.job!.clientRef.id}", isSignIn);
                    },
                    child: CircleImage(
                        url: state.job!.clientImageUrl,
                        assetPath: kIconImagePath)),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  state.job!.clientName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text("受注報酬:" + state.job!.jobPrice.toString() + "pt"),
          Text("応募締め切り:" + state.job!.applicationDeadline.toFormatYMDString()),
          Text("納品締め切り:" + state.job!.deliveryDeadline.toFormatYMDString()),
        ],
      );
    }

    /// レスポンシブ用のBodyウィジェット
    Widget body(ScreenType screenType) {
      return UsefulCard(
        title: Row(
          children: [
            JobStatusChip(status: state.job!.jobStatus),
            const SizedBox(
              width: 8,
            ),
            Text(state.job!.jobTitle,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        center: (ScreenType.desktop == screenType)
            ? desktopCenterBody()
            : tabletCenterBody(),
        contents: SizedBox(
          width: double.infinity,
          child: BetweenColumn(
            children: [
              const BetweenColumnChild(child: Divider()),
              const BetweenColumnChild(
                child: Text("依頼詳細",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              BetweenColumnChild(
                  child: Linkify(
                      onOpen: (link) async {
                        await launchUrlString(link.url);
                      },
                      text: state.job!.jobDetail)),
              isMyPage
                  ? BetweenColumnChild(
                      isStart: false,
                      child:
                          ChangeJobStatusButton(state as MyPageJobDetailModel))
                  : const BetweenColumnChild(child: SizedBox()),
              const BetweenColumnChild(
                  child: SizedBox(
                height: 10,
              )),
              isMyPage
                  ? BetweenColumnChild(
                      isStart: false, child: ToOpenPageButton(id, isSignIn))
                  : BetweenColumnChild(
                      isStart: false,
                      child: state.applied ? CancelButton(id) : ApplyButton(id))
            ],
          ),
        ),
      );
    }

    if (state.job == null) {
      return const UsefulCard(
          center: SizedBox(
              width: double.infinity,
              height: 200,
              child: Center(child: CircularProgressIndicator())));
    }
    return body(screenType);
  }
}

// MyPageJobDetailPageの場合表示
// 依頼のステータスをPRIVATE→PUBLIC→CLOSEDの順に変化させる。CLOSEDの場合は非表示
class ChangeJobStatusButton extends StatelessWidget {
  const ChangeJobStatusButton(this.state, {Key? key}) : super(key: key);
  final MyPageJobDetailModel state;

  @override
  Widget build(BuildContext context) {
    final buttonText =
        state.job!.jobStatus == kJobStatusPrivate ? '公開する' : '募集を終了する';
    if (state.job!.jobStatus == kJobStatusClosed) {
      return const SizedBox();
    }

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kSecondaryColor,
        ),
        onPressed: () {
          showConfirmDialog(
            context: context,
            title: state.job!.jobTitle,
            message: state.job!.clientName,
            okText: buttonText,
            function: () {
              try {
                state.changeJobStatus();
              } on String catch (message) {
                showTextDialog(context, title: message);
              } on Exception catch (e) {
                showTextDialog(context, title: e.toString());
              }
            },
          );
        },
        child: Text(
          state.job!.jobStatus == kJobStatusPrivate ? '公開する' : '募集を終了する',
          style: const TextStyle(
              color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
        ));
  }
}

// MyPageJobDetailPageの場合表示
// 公開されてるJobDetailPageに遷移する
class ToOpenPageButton extends ConsumerWidget {
  const ToOpenPageButton(this.id, this.isSignIn, {Key? key}) : super(key: key);
  final String id;
  final bool isSignIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kSecondaryColor,
        ),
        onPressed: () {
          context.go('/jobs/job_detail/' + id, isSignIn);
        },
        child: const Text(
          '公開ページを開く',
          style: TextStyle(
              color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
        ));
  }
}

class ApplyButton extends ConsumerWidget {
  const ApplyButton(this.id, {Key? key}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobDetailProvider(id));
    if (state.job == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Visibility(
      visible: state.canApply && state.fromOfficialJob,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kSecondaryColor,
        ),
        onPressed: () async {
          showConfirmDialog(
            context: context,
            title: state.job!.jobTitle,
            message: state.job!.clientName,
            okText: '応募する!',
            function: () async {
              await state.applyJob(showTextDialog: (String title) async {
                await showTextDialog(context, title: title);
              }, showUserInfoNotRegisteredDialog: (bool isSignIn) async {
                await showUserInfoNotRegisteredDialog(context, isSignIn);
              }, onNotLogin: () async {
                await showLoginDialog(context);
              });
            },
          );
        },
        child: const Text(
          '応募する',
          style: TextStyle(
              color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class CancelButton extends ConsumerWidget {
  const CancelButton(this.id, {Key? key}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobDetailProvider(id));
    return Visibility(
      visible: state.canCancel,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kGreyColor,
        ),
        onPressed: () async {
          showConfirmDialog(
            context: context,
            title: state.job!.jobTitle,
            message: state.job!.clientName,
            okText: '応募を取り消す！！',
            cancelText: '取り消さない',
            function: () {
              state.cancelApplication((String title) async {
                await showTextDialog(context, title: title);
              });
            },
          );
        },
        child: const Text(
          '応募を取り消す',
          style: TextStyle(
              color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class JobsPageCard extends ConsumerWidget {
  const JobsPageCard({Key? key, required this.job, this.onTap})
      : super(key: key);
  final Job job;
  final Function? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return UsefulCard(
      title: Column(
        children: [
          Row(
            children: [
              JobStatusChip(status: job.jobStatus),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Image.asset("assets/images/sukimachi_top.jpg"),
        ],
      ),
      center: BetweenColumn(children: [
        BetweenColumnChild(
            isStart: true,
            child: Text(
              job.clientName,
              style: const TextStyle(fontSize: 18),
            )),
        BetweenColumnChild(
          isStart: false,
          child: Text("受注報酬:" + job.jobPrice.toString() + "pt"),
        ),
        BetweenColumnChild(
            isStart: false,
            child: Text(
              "応募締め切り:" + job.applicationDeadline.toFormatYMDString(),
              style: const TextStyle(fontSize: 10),
            )),
        BetweenColumnChild(
            isStart: false,
            child: Text(
              "納品締め切り:" + job.deliveryDeadline.toFormatYMDString(),
              style: const TextStyle(fontSize: 10),
            )),
      ]),
      contents: Column(
        children: [
          const Divider(),
          Text(job.jobTitle,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      onTap: () {
        if (onTap == null) {
          context.go("/jobs/job_detail/" + job.jobRef.id,
              ref.watch(authRepositoryProvider).isSignIn);
        } else {
          onTap!();
        }
      },
    );
  }
}
