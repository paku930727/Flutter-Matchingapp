import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/default/default_page.dart';
import 'package:sukimachi/presentation/widgets/application_cards.dart';
import 'package:sukimachi/presentation/widgets/job_card.dart';
import 'package:sukimachi/presentation/widgets/responsive.dart';

// Todo レスポンシブ対応
class MyPageJobDetailPage extends ConsumerWidget {
  const MyPageJobDetailPage(this.id, {Key? key}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget bodyWidget(ScreenType screenType) {
      return Column(
        children: [
          JobCard(id, isMyPage: true, screenType: screenType),
          const Text('応募一覧',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ApplicationCards(id)
        ],
      );
    }

    Widget desktopWidget() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
          Expanded(flex: 4, child: bodyWidget(ScreenType.desktop)),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          )
        ],
      );
    }

    Widget tabletWidget() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
          Expanded(flex: 4, child: bodyWidget(ScreenType.tablet)),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          )
        ],
      );
    }

    Widget mobileWidget() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: bodyWidget(ScreenType.mobile)),
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
