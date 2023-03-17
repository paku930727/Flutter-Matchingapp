import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/presentation/default/default_page.dart';
import 'package:sukimachi/presentation/home/components/banner_section.dart';
import 'package:sukimachi/presentation/home/home_page_model.dart';
import 'package:sukimachi/presentation/widgets/responsive.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../constants.dart';
import '../widgets/job_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    Widget jobsCardList() {
      if (state.officialJobs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return Wrap(
        children: state.officialJobs
            .map((job) => SizedBox(
                  width: kThreeDivideWidth,
                  child: JobsPageCard(
                    job: job,
                  ),
                ))
            .toList(),
      );
    }

    Widget getPreReleaseManual({required VoidCallback onPressed}) {
      return Responsive(
        desktop: Padding(
          padding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: onPressed,
            child: const Card(
              color: Colors.grey,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "プレリリースについて",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
              ),
            ),
          ),
        ),
        tablet: Padding(
          padding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: onPressed,
            child: const Card(
              color: Colors.grey,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "プレリリースについて",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
              ),
            ),
          ),
        ),
        mobile: Padding(
          padding: const EdgeInsets.all(24),
          child: FloatingActionButton(
              backgroundColor: kGreyColor,
              onPressed: onPressed,
              child: const Icon(
                Icons.sticky_note_2_outlined,
              )),
        ),
      );
    }

    return Stack(
      children: [
        DefaultPage(
          pageName: "home",
          headerWidget: Responsive.isDesktop(context)
              ? const BannerSection()
              : const MobBanner(),
          bodyWidget: Column(
            children: [
              const Text(
                "公式からの依頼",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              jobsCardList(),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Align(
              alignment: const Alignment(1, 1),
              child: getPreReleaseManual(onPressed: () async {
                await launchUrlString(preReleaseSlideUrl);
              })),
        ),
      ],
    );
  }
}
