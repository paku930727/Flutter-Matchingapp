import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sukimachi/extension/ko_router.dart';

import 'package:sukimachi/presentation/login_dialog/login_dialog.dart';
import 'package:sukimachi/presentation/home/components/menu.dart';
import 'package:sukimachi/presentation/widgets/responsive.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';

class Header extends ConsumerWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authRepositoryProvider);
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          Builder(
              builder: (context) => IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.menu))),
        InkWell(
          onTap: () {
            context.go(
                kHomePagePath, ref.watch(authRepositoryProvider).isSignIn);
          },
          child: const Text(
            "スキ街",
            style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.w900,
                color: kSecondaryColor),
          ),
        ),
        const Spacer(),
        //menu
        if (Responsive.isDesktop(context))
          const HeaderWebMenu(
            isHeader: true,
          ),
        const Spacer(),
        !authState.isSignIn
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                ),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) => const LoginDialog());
                },
                child: const Text(
                  'Log in',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              )
            : GestureDetector(
                onTap: () {
                  final url = Uri.parse(twitterUrl);
                  launchUrl(url);
                },
                child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset(kTwitterIconImagePath)),
              ),
      ],
    );
  }
}

class SocialIcon extends StatelessWidget {
  const SocialIcon({
    Key? key,
    required this.icon,
  }) : super(key: key);
  final String icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 35,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
          )),
      child: SvgPicture.asset(icon),
    );
  }
}
