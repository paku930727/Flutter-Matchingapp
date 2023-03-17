import 'package:flutter/material.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/my_page/tabs/my_page_application_page.dart';
import 'package:sukimachi/presentation/my_page/tabs/tab_item.dart';
import 'package:sukimachi/presentation/my_page/tabs/my_page_client_jobs_page.dart';
import 'package:sukimachi/presentation/my_page/tabs/my_page_home_page.dart';

/// MyPageのタブの項目
class MyPageTabs {
  static final data = [
    // ホーム用のタブ
    const TabItem(
        tabId: kMyPageHomeTabId,
        tab: Tab(
          child: Text(
            'ホーム',
            style: TextStyle(
              fontSize: 17.0,
            ),
          ),
        ),
        view: MyPageHome()),
    // 依頼一覧用のタブ
    const TabItem(
      tabId: kMyPageClientJobsTabId,
      tab: Tab(
        child: Text(
          '依頼一覧',
          style: TextStyle(
            fontSize: 17.0,
          ),
        ),
      ),
      view: MyPageClientJobs(),
    ),
    // 受注一覧用のタブ
    const TabItem(
      tabId: kMyPageApplicationPageTabId,
      tab: Tab(
        child: Text(
          '応募一覧',
          style: TextStyle(
            fontSize: 17.0,
          ),
        ),
      ),
      view: MyPageApplicationPage(),
    ),
  ];
  static TabItem family(String tabId) => data.tabItem(tabId);
}

extension on List<TabItem> {
  TabItem tabItem(String tabId) => singleWhere(
        (t) => t.tabId == tabId,
        orElse: () => throw Exception('unknown family $tabId'),
      );
}
