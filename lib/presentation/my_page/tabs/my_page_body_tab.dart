import 'package:flutter/material.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/presentation/my_page/tabs/tab_item.dart';
import 'package:sukimachi/presentation/my_page/tabs/my_page_tabs_component.dart';

/// MyPageの表示情報を切り替えるタブ
///
/// 依頼情報や受注情報のみに切り替えるために使用する。
class MyPageBodyTab extends StatefulWidget {
  const MyPageBodyTab({Key? key, required this.currentTab, required this.index})
      : super(key: key);
  final TabItem currentTab;
  final int index;

  @override
  _MyPageBodyTabState createState() => _MyPageBodyTabState();
}

class _MyPageBodyTabState extends State<MyPageBodyTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: MyPageTabs.data.length,
      vsync: this,
      initialIndex: widget.index,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MyPageBodyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey.withOpacity(0.6),
          isScrollable: true,
          onTap: (int index) {
            _onTap(context, index);
          },
          tabs: [for (TabItem t in MyPageTabs.data) t.tab],
        ),
        // tabのボディ
        IndexedStack(
          alignment: Alignment.center,
          index: widget.index,
          children: [
            for (final t in MyPageTabs.data)
              Visibility(
                  child: t.view,
                  visible: widget.index ==
                      MyPageTabs.data
                          .indexWhere((tab) => tab.tabId == t.tabId)),
          ],
        )
      ],
    );
  }

  void _onTap(BuildContext context, int index) {
    context.go('/myPage/${MyPageTabs.data[index].tabId}', true);
  }
}
