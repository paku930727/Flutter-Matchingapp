import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/extension/date_extension.dart';
import 'package:sukimachi/presentation/default/default_page.dart';
import 'package:sukimachi/presentation/my_page/gift/gift_model.dart';
import 'package:sukimachi/presentation/widgets/useful_card.dart';

import '../../widgets/show_dialog.dart';

class GiftPage extends ConsumerWidget {
  const GiftPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(giftProvider);
    List<Widget> giftCardList() {
      return state.amazonGift
          .map((gift) => InkWell(
                onTap: () async {
                  await showConfirmDialog(
                    context: context,
                    title: gift.title,
                    message:
                        '${gift.title}の申請をしますか？\n${gift.point}ptが使用されます。\n \n 所持ポイント: ${state.currentUserPoint}pt',
                    okText: '申請をする。',
                    function: () async {
                      try {
                        await state.requestGift(gift);
                        await showTextDialog(context, title: '申請しました！');
                      } catch (e) {
                        await showTextDialog(context, title: e.toString());
                      }
                    },
                  );
                },
                child: SizedBox(
                  width: kThreeDivideWidth,
                  child: UsefulCard(
                    title: Text(
                      gift.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    center: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Text(gift.detail)),
                    contents: Align(
                        alignment: Alignment.centerRight,
                        child: Text('${gift.point}pt')),
                  ),
                ),
              ))
          .toList();
    }

    Widget giftRequestCardList() {
      if (state.giftRequests == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (state.giftRequests!.isEmpty) {
        return const Text('まだギフト申請がありません。');
      }
      return Wrap(
        children: state.giftRequests!
            .map((request) => SizedBox(
                  width: kThreeDivideWidth,
                  child: UsefulCard(
                    title: Text(
                      request.getTitleText(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    contents: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${request.point}pt'),
                          Text(request.getStatusText()),
                          Text('${request.createdAt.toFormatYMDString()}申請済み'),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      );
    }

    return DefaultPage(
      bodyWidget: Column(
        children: [
          const Text(
            "ギフト一覧",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            children: giftCardList(),
          ),
          const Text(
            "ギフト申請一覧",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          giftRequestCardList(),
        ],
      ),
      pageName: kGiftPageName,
    );
  }
}
