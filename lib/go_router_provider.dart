//画面の情報を定義する
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sukimachi/presentation/contact/contact_page.dart';
import 'package:sukimachi/presentation/contact/contact_success/contact_success_page.dart';
import 'package:sukimachi/presentation/home/home_page.dart';
import 'package:sukimachi/presentation/job_detail/job_detail_page.dart';
import 'package:sukimachi/presentation/jobs/jobs_page.dart';
import 'package:sukimachi/presentation/legal_document/legal_document_page.dart';
import 'package:sukimachi/presentation/my_page/gift/gift_page.dart';
import 'package:sukimachi/presentation/my_page/my_page.dart';
import 'package:sukimachi/presentation/my_page/my_page_job_detail/my_page_job_detail_page.dart';
import 'package:sukimachi/presentation/my_page/tabs/my_page_tabs_component.dart';
import 'package:sukimachi/presentation/profile/profile_page.dart';
import 'package:sukimachi/repository/auth_repository.dart';

import 'constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  bool checkNeedLogin(String location) {
    return requiredLoginPages.contains(location) ||
        location.startsWith('/myPage');
  }

  return GoRouter(
    initialLocation: kHomePagePath,
    redirect: (state) {
      if (checkNeedLogin(state.location) &&
          !ref.watch(authRepositoryProvider).isSignIn) return kHomePagePath;
      return null;
    },
    routes: [
      GoRoute(
        name: kHomePageName,
        path: kHomePagePath,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        name: kJobsPageName,
        path: kJobsPagePath,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const JobsPage(),
        ),
      ),
      GoRoute(
        name: kLegalDocumentName,
        path: kLegalDocumentPath,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: LegalDocumentPage(state.params['contentsId']!),
        ),
      ),
      GoRoute(
        name: kProfilePageName,
        path: kProfilePagePath,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: ProfilePage(state.params['id']!),
        ),
      ),
      GoRoute(
        name: kJobDetailPageName,
        path: kJobDetailPagePath,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: JobDetailPage(state.params['id']!),
        ),
      ),

      /// MyPageのタブに表示される情報の切り替えを行うためのGoRouteの設定
      ///
      /// ex.) myPage/homeの場合は、my_page_home.dartのウィジェットが表示される。
      GoRoute(
          name: kMyPageName,
          path: kMyPagePath,
          pageBuilder: (context, state) {
            final myPageId = state.params['myPageId'];
            final currentTab =
                MyPageTabs.data.firstWhere((tab) => tab.tabId == myPageId);
            final index =
                MyPageTabs.data.indexWhere((t) => t.tabId == currentTab.tabId);
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: MyPage(
                currentTab: currentTab,
                index: index,
              ),
            );
          }),
      GoRoute(
          name: kMyPageJobDetailPath,
          path: kMyPageJobDetailPath,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: MyPageJobDetailPage(state.params['id']!),
            );
          }),
      GoRoute(
          name: kGiftPageName,
          path: kGiftPagePath,
          pageBuilder: (context, state) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: const GiftPage(),
            );
          }),
      GoRoute(
        name: kContactName,
        path: kContactPath,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ContactPage(),
        ),
      ),
      GoRoute(
        name: kContactSuccessName,
        path: kContactSuccessPath,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ContactSuccessPage(),
        ),
      ),
    ],
    //遷移ページがないなどのエラーが発生した時に、このページに行く
    errorPageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Text(state.error.toString()),
        ),
      ),
    ),
  );
});
