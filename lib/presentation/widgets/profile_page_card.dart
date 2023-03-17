import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/secret_profile.dart';
import 'package:sukimachi/presentation/widgets/circle_image.dart';
import 'package:sukimachi/presentation/widgets/sns_list.dart';
import 'package:sukimachi/presentation/widgets/useful_card.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../domain/user.dart';

class ProfilePageCard extends StatelessWidget {
  const ProfilePageCard(
      {Key? key,
      required this.user,
      this.secretProfile,
      required this.screenType})
      : super(key: key);
  final User user;
  final SecretProfile? secretProfile;
  final ScreenType screenType;
  @override
  Widget build(BuildContext context) {
    // Desktopサイズの画面の時のCard
    Widget getDesktopCard() {
      return UsefulCard(
        title: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              height: 100,
              width: 100,
              child: CircleImage(
                assetPath: kIconImagePath,
                url: user.userImageUrl,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                user.userName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("性別: " + user.sexToString()),
                Text("発注件数:" + (user.orderedJobsCount).toString()),
                Text("受注件数:" + (user.acceptedJobsCount).toString()),
                if (secretProfile != null)
                  Text("ポイント: ${secretProfile!.point} pt")
              ],
            ),
          ],
        ),
        center: const SizedBox(
          height: 10,
        ),
        contents: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                user.hasIntroduceForClient()
                    ? Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("発注者への自己紹介",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Linkify(
                                onOpen: (link) async {
                                  await launchUrlString(link.url);
                                },
                                text: user.introduceForClient!),
                          ],
                        ),
                      )
                    : const SizedBox(),
                user.hasIntroduceForContractor()
                    ? Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "依頼者への自己紹介",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Linkify(
                                onOpen: (link) async {
                                  await launchUrlString(link.url);
                                },
                                text: user.introduceForContractor!),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SnsListWidget(snsUrlList: user.snsUrlList)
          ],
        ),
      );
    }

    // Desktopサイズ以外の画面の時のCard
    Widget getOtherCard() {
      return UsefulCard(
        title: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  height: 100,
                  width: 100,
                  child: CircleImage(
                    assetPath: kIconImagePath,
                    url: user.userImageUrl,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  user.userName,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("性別: " + user.sexToString()),
                  Text("発注件数:" + (user.orderedJobsCount).toString()),
                  Text("受注件数:" + (user.acceptedJobsCount).toString()),
                  if (secretProfile != null)
                    Text("ポイント: ${secretProfile!.point} pt")
                ],
              ),
            ),
          ],
        ),
        center: const SizedBox(
          height: 10,
        ),
        contents: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              user.hasIntroduceForClient()
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("発注者への自己紹介",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Linkify(
                            onOpen: (link) async {
                              await launchUrlString(link.url);
                            },
                            text: user.introduceForClient!),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    )
                  : const SizedBox(),
              user.hasIntroduceForContractor()
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "依頼者への自己紹介",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Linkify(
                            onOpen: (link) async {
                              await launchUrlString(link.url);
                            },
                            text: user.introduceForContractor!),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      );
    }

    return (ScreenType.desktop == screenType)
        ? getDesktopCard()
        : getOtherCard();
  }
}
