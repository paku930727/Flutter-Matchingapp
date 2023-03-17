import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/profile/profile_model.dart';
import 'package:sukimachi/presentation/widgets/profile_page_card.dart';
import 'package:sukimachi/presentation/widgets/responsive.dart';

import '../default/default_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage(this.id, {Key? key}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider(id));

    Widget profileCard() {
      if (state.user == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Responsive(
        desktop: ProfilePageCard(
          user: state.user!,
          screenType: ScreenType.desktop,
        ),
        tablet: ProfilePageCard(
          user: state.user!,
          screenType: ScreenType.tablet,
        ),
        mobile: ProfilePageCard(
          user: state.user!,
          screenType: ScreenType.mobile,
        ),
      );
    }

    return DefaultPage(
      bodyWidget: profileCard(),
      pageName: "profile",
    );
  }
}
