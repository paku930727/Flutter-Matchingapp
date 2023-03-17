import 'package:flutter/material.dart';
import 'package:sukimachi/presentation/default/default_page.dart';
import 'package:sukimachi/presentation/my_page/tabs/my_page_body_tab.dart';
import 'package:sukimachi/presentation/my_page/tabs/tab_item.dart';

/// マイページ画面
class MyPage extends StatelessWidget {
  const MyPage({Key? key, required this.currentTab, required this.index})
      : super(key: key);
  final TabItem currentTab;
  final int index;

  @override
  Widget build(BuildContext context) {
    return DefaultPage(
      pageName: 'myPage',
      bodyWidget: MyPageBodyTab(
        currentTab: currentTab,
        index: index,
      ),
    );
  }
}
