import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/extension/ko_router.dart';
import 'package:sukimachi/repository/auth_repository.dart';

import '../../../constants.dart';

class BannerSection extends StatelessWidget {
  const BannerSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Opacity(
              opacity: 0.1,
              child: Image.asset("assets/images/sukimachi_top.jpg")),
        ),
        const AboutSection(),
      ],
    );
  }
}

class MobBanner extends StatelessWidget {
  const MobBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AboutSection(),
        const SizedBox(
          height: 30,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            "assets/images/sukimachi_top.jpg",
          ),
        ),
      ],
    );
  }
}

class AboutSection extends ConsumerWidget {
  const AboutSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        // ignore: prefer_const_constructors
        //it will adjust its size according to screeen
        const AutoSizeText(
          "スキ街とは",
          maxLines: 1,
          style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: const [
            Text(
              kTopPageCatchCopy1,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Text(
              kTopPageCatchCopy2,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: const [
            Text(
              kTopPageServiceDetail1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            Text(
              kTopPageServiceDetail2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 600,
          child: MaterialButton(
            minWidth: double.infinity,
            height: 55,
            color: kSecondaryColor,
            onPressed: () {
              context.go(
                  kJobsPagePath, ref.watch(authRepositoryProvider).isSignIn);
            },
            child: const Text(
              "街を覗いてみる",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
