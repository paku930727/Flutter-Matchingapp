import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:universal_html/html.dart' as html;

import '../../../constants.dart';

const noNeedLoginCheck = true;

class HeaderWebMenu extends ConsumerWidget {
  const HeaderWebMenu({
    required this.isHeader,
    Key? key,
  }) : super(key: key);
  final bool isHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authRepositoryProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeaderMenu(
          press: () {
            context.go(kMyPageHomePath, authState.isSignIn);
          },
          title: "マイページ",
        ),
        const SizedBox(
          width: kPadding,
        ),
        HeaderMenu(
          press: () {
            context.go(kJobsPagePath, authState.isSignIn);
          },
          title: "お仕事一覧",
        ),
        const SizedBox(
          width: kPadding,
        ),
        HeaderMenu(
          press: () {
            context.go(kContactPath, noNeedLoginCheck);
          },
          title: "お問い合わせ",
        ),
        const SizedBox(
          width: kPadding,
        ),
        isHeader
            ? const SizedBox()
            : Row(
                children: [
                  HeaderMenu(
                    press: () async {
                      context.push(
                          "/documents/$kPrivacyPolicyName", noNeedLoginCheck);
                    },
                    title: "プライバシーポリシー",
                  ),
                  const SizedBox(
                    width: kPadding,
                  ),
                ],
              ),
        HeaderMenu(
          press: () async {
            context.push("/documents/$kTermOfServiceUrlName", noNeedLoginCheck);
          },
          title: "利用規約",
        ),
        const SizedBox(
          width: kPadding,
        ),
        authState.isSignIn && isHeader
            ? HeaderMenu(
                press: () async {
                  await authState.signOut();
                  html.window.location.reload();
                },
                title: "サインアウト",
              )
            : const SizedBox()
      ],
    );
  }
}

class MobFooterMenu extends ConsumerWidget {
  const MobFooterMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authRepositoryProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeaderMenu(
          press: () {
            context.go(kMyPageHomePath, authState.isSignIn);
          },
          title: "マイページ",
        ),
        const SizedBox(
          width: kPadding,
        ),
        HeaderMenu(
          press: () {
            context.go(kJobsPagePath, authState.isSignIn);
          },
          title: "お仕事一覧",
        ),
        const SizedBox(
          width: kPadding,
        ),
        HeaderMenu(
          press: () {
            context.go(kContactPath, noNeedLoginCheck);
          },
          title: "お問い合わせ",
        ),
        const SizedBox(
          width: kPadding,
        ),
        HeaderMenu(
          press: () async {
            context.push("/documents/$kPrivacyPolicyName", noNeedLoginCheck);
          },
          title: "プライバシーポリシー",
        ),
        const SizedBox(
          width: kPadding,
        ),
        HeaderMenu(
          press: () async {
            context.push("/documents/$kTermOfServiceUrlName", noNeedLoginCheck);
          },
          title: "利用規約",
        ),
      ],
    );
  }
}

class HeaderMenu extends StatelessWidget {
  const HeaderMenu({
    Key? key,
    required this.title,
    required this.press,
  }) : super(key: key);
  final String title;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}

class MobMenu extends ConsumerWidget {
  const MobMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderMenu(
            press: () {
              context.go(kMyPageHomePath, authState.isSignIn);
            },
            title: "マイページ",
          ),
          const SizedBox(
            height: kPadding,
          ),
          HeaderMenu(
            press: () {
              context.go(kJobsPagePath, authState.isSignIn);
            },
            title: "お仕事一覧",
          ),
          const SizedBox(
            height: kPadding,
          ),
          HeaderMenu(
            press: () {
              context.go(kContactPath, noNeedLoginCheck);
            },
            title: "お問い合わせ",
          ),
          const SizedBox(
            height: kPadding,
          ),
          HeaderMenu(
            press: () async {
              context.push("/documents/$kPrivacyPolicyName", noNeedLoginCheck);
            },
            title: "プライバシーポリシー",
          ),
          const SizedBox(
            height: kPadding,
          ),
          HeaderMenu(
            press: () async {
              context.push(
                  "/documents/$kTermOfServiceUrlName", noNeedLoginCheck);
            },
            title: "利用規約",
          ),
          const SizedBox(
            height: kPadding,
          ),
          authState.isSignIn
              ? HeaderMenu(
                  press: () async {
                    await authState.signOut();
                    html.window.location.reload();
                  },
                  title: "サインアウト",
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
