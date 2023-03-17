import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/application.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/presentation/widgets/between_column.dart';
import 'package:sukimachi/presentation/widgets/between_column_child.dart';
import 'package:sukimachi/presentation/widgets/status_chip.dart';
import 'package:sukimachi/presentation/widgets/useful_card.dart';
import 'package:sukimachi/repository/auth_repository.dart';

class ApplicationsPageCard extends ConsumerWidget {
  const ApplicationsPageCard({Key? key, required this.application, this.onTap})
      : super(key: key);
  final Application application;
  final Function? onTap;

  Widget getStatusChip() {
    switch (application.status) {
      case kApplicationStatusInReview:
        return const StatusChip(
            backgroundColor: kPrimaryColor,
            text: kApplicationStatusInReviewView);
      case kApplicationStatusRejected:
        return const StatusChip(
            backgroundColor: kGreyColor, text: kApplicationStatusRejectedView);
      case kApplicationStatusAccepted:
        return const StatusChip(
            backgroundColor: kSecondaryColor,
            text: kApplicationStatusAcceptedView);
      case kApplicationStatusDone:
        return const StatusChip(
            backgroundColor: kGreyColor, text: kApplicationStatusDoneView);
      default:
        return const StatusChip(backgroundColor: kGreyColor, text: '不明');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return UsefulCard(
      title: Column(
        children: [
          Row(
            children: [
              getStatusChip(),
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
              application.clientName,
              style: const TextStyle(fontSize: 18),
            )),
      ]),
      contents: Column(
        children: [
          const Divider(),
          Text(application.jobTitle,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      onTap: () {
        if (onTap == null) {
          context.go("/jobs/job_detail/" + application.jobRef.id,
              ref.watch(authRepositoryProvider).isSignIn);
        } else {
          onTap!();
        }
      },
    );
  }
}
