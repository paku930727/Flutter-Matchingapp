import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/extension/date_extension.dart';
import 'package:sukimachi/presentation/default/default_page.dart';
import 'package:sukimachi/presentation/widgets/responsive.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../widgets/show_dialog.dart';
import 'package:sukimachi/presentation/widgets/circle_image.dart';
import '../widgets/job_card.dart';
import 'job_detail_model.dart';

//Todo レスポンシブ対応
class JobDetailPage extends ConsumerWidget {
  const JobDetailPage(this.id, {Key? key}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobDetailProvider(id));

    Future sendComment() async {
      await state.sendComment(showTextDialog: (String title) async {
        await showTextDialog(context, title: title);
      }, showUserInfoNotRegisteredDialog: (bool isSignIn) async {
        await showUserInfoNotRegisteredDialog(context, isSignIn);
      }, onNotLogin: () async {
        await showLoginDialog(context);
      });
    }

    List<Widget> commentCardList() {
      if (state.jobCommentList == null) {
        return [
          const SizedBox(
              width: double.infinity,
              child: Center(child: CircularProgressIndicator()))
        ];
      } else if (state.jobCommentList!.isEmpty) {
        return [
          const SizedBox(
              width: double.infinity,
              child: Center(child: Text("まだコメントがありません"))),
        ];
      }
      //最初はLoadLimit - 1だけ表示
      //もっと見るを押したら全て表示
      final int displayLength = state.canFetchMoreComment
          ? (kCommentLoadLimit - 1)
          : state.jobCommentList!.length;
      return state.jobCommentList!
          .take(displayLength)
          .map((comment) => Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          height: 30,
                          width: 30,
                          child: InkWell(
                              onTap: () {
                                context.go(
                                    "/profile/${state.job!.clientRef.id}",
                                    ref.watch(authRepositoryProvider).isSignIn);
                              },
                              child: CircleImage(
                                url: comment.commenterImageUrl,
                                assetPath: kIconImagePath,
                              )),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(comment.commenterName,
                            style: TextStyle(
                                color: comment.commenterRef == state.job!.jobRef
                                    ? kSecondaryColor
                                    : Colors.black)),
                      ],
                    ),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          child: Linkify(
                              onOpen: (link) async {
                                await launchUrlString(link.url);
                              },
                              text: comment.comment)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        comment.createdAt.toFormatYMDHmString(),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),
              ))
          .toList();
    }

    Widget commentBoard() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "コメント",
            style: TextStyle(fontSize: 20),
          ),
          Container(
            padding: const EdgeInsets.all(kPadding),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: commentCardList(),
                ),
                state.canFetchMoreComment
                    ? Align(
                        alignment: Alignment.center,
                        child: InkWell(
                            onTap: () {
                              state.fetchMoreJobComment();
                            },
                            child: const Text("もっと見る")))
                    : const SizedBox()
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                  ),
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) async {
                      // control or command + Enter で送信
                      if ((event.isMetaPressed || event.isControlPressed) &&
                          event.isKeyPressed(LogicalKeyboardKey.enter)) {
                        await sendComment();
                      }
                    },
                    child: TextField(
                      controller: state.commentController,
                      decoration: const InputDecoration(
                        labelText: "コメントを書く",
                      ),
                      maxLines: 10,
                      minLines: 1,
                    ),
                  )),
              Positioned(
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: InkWell(
                        onTap: () async {
                          await sendComment();
                        },
                        child: const Icon(Icons.send)),
                  )),
            ],
          )
        ],
      );
    }

    /// デスクトップ用の画面
    Widget desktopWidget() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: JobCard(
                id,
                isMyPage: false,
                screenType: ScreenType.desktop,
              )),
          Expanded(
            flex: 1,
            child: commentBoard(),
          )
        ],
      );
    }

    /// タブレット用の画面
    Widget tabletWidget() {
      return Column(
        children: [
          JobCard(id, isMyPage: false, screenType: ScreenType.tablet),
          commentBoard(),
        ],
      );
    }

    /// スマートフォン用の画面
    Widget mobileWidget() {
      return Column(
        children: [
          JobCard(id, isMyPage: false, screenType: ScreenType.mobile),
          commentBoard(),
        ],
      );
    }

    return DefaultPage(
      bodyWidget: Responsive(
        desktop: desktopWidget(),
        tablet: tabletWidget(),
        mobile: mobileWidget(),
      ),
      pageName: kJobDetailPageName,
    );
  }
}
