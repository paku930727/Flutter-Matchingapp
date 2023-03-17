import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/application.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/presentation/my_page/my_page_job_detail/my_page_job_detail_model.dart';
import 'package:sukimachi/presentation/widgets/circle_image.dart';
import 'package:sukimachi/presentation/widgets/show_dialog.dart';
import 'package:sukimachi/presentation/widgets/status_chip.dart';
import 'package:sukimachi/presentation/widgets/useful_card.dart';
import 'package:sukimachi/repository/auth_repository.dart';

class ApplicationCards extends ConsumerWidget {
  const ApplicationCards(this.id, {Key? key}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myPageJobDetailProvider(id));
    final isSignIn = ref.watch(authRepositoryProvider).isSignIn;

    Widget getApplicationButton(Application application) {
      switch (application.status) {
        case kApplicationStatusInReview:
          return Row(
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreyColor,
                  ),
                  onPressed: () {
                    showConfirmDialog(
                      context: context,
                      title: application.applicantName,
                      message: application.applicantName + 'の応募をお断りしますか？',
                      okText: '依頼をお断りする。',
                      function: () async {
                        try {
                          await state.rejectApplication(application);
                        } catch (e) {
                          await showTextDialog(context, title: e.toString());
                        }
                      },
                    );
                  },
                  child: const Text(
                    '依頼をお断りする',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  )),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                  ),
                  onPressed: () {
                    showConfirmDialog(
                      context: context,
                      title: application.applicantName,
                      message: application.applicantName + 'に依頼をお願いしますか？',
                      okText: '依頼をお願いする。',
                      function: () async {
                        try {
                          await state.acceptApplication(application);
                        } catch (e) {
                          await showTextDialog(context, title: e.toString());
                        }
                      },
                    );
                  },
                  child: const Text(
                    '依頼をお願いする',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  )),
            ],
          );
        case kApplicationStatusAccepted:
          return Row(
            children: [
              Visibility(
                visible: false,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                  ),
                  onPressed: () {},
                  child: const Text(
                    'チャット',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                  ),
                  onPressed: () {
                    showConfirmDialog(
                      context: context,
                      title: "依頼が完了しましたか?",
                      message:
                          '依頼の完了をタップすると${application.applicantName}にスキ街ポイントが付与されます。',
                      okText: '依頼の完了',
                      cancelText: 'まだ完了してない',
                      function: () async {
                        try {
                          await state.completeApplication(application);
                        } catch (e) {
                          await showTextDialog(context, title: e.toString());
                        }
                      },
                    );
                  },
                  child: const Text(
                    '依頼の完了',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  )),
            ],
          );
        case kApplicationStatusDone:
          return const StatusChip(
            text: "　完了　",
            backgroundColor: kPrimaryColor,
          );
        default:
          return const StatusChip(
            text: "断り済み",
            backgroundColor: kGreyColor,
          );
      }
    }

    Widget getCard(Application application) {
      return UsefulCard(
        contents: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      height: 50,
                      width: 50,
                      child: InkWell(
                        onTap: () {
                          context.go(
                              "/profile/${state.job!.clientRef.id}", isSignIn);
                        },
                        child: CircleImage(
                            url: application.applicantImageUrl,
                            assetPath: kIconImagePath),
                      ),
                    ),
                    Text(application.applicantName),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    getApplicationButton(application),
                  ],
                ),
              ],
            )),
      );
    }

    if (state.applications == null) {
      return const SizedBox(
          width: double.infinity,
          child: Center(child: CircularProgressIndicator()));
    } else {
      return state.applications!.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "現在この依頼に応募しているメンバーはいません",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )
          : Column(
              children: state.applications!
                  .map((application) => getCard(application))
                  .toList());
    }
  }
}
