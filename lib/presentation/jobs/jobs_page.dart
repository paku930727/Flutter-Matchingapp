import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/default/default_page.dart';
import 'package:sukimachi/presentation/jobs/jobs_model.dart';
import 'package:sukimachi/presentation/widgets/job_card.dart';
import 'package:sukimachi/presentation/widgets/show_dialog.dart';

class JobsPage extends ConsumerWidget {
  const JobsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobsProvider);

    List<Widget> jobsCardList() {
      return state.jobs!
          .map((job) => SizedBox(
                width: kThreeDivideWidth,
                child: JobsPageCard(
                  job: job,
                ),
              ))
          .toList();
    }

    Widget jobsWidget() {
      if (state.jobs == null) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state.jobs!.isEmpty) {
        return const Center(child: Text("条件に合う依頼が見つかりませんでした。"));
      }
      return Wrap(
        children: jobsCardList(),
      );
    }

    Widget categoryList() {
      final chipList = state.categories
          .map((category) => Padding(
                padding: const EdgeInsets.all(2.0),
                child: ChoiceChip(
                  labelPadding: const EdgeInsets.all(2.0),
                  label: Text(
                    category.name,
                  ),
                  selected: state.selectedCategories.contains(category),
                  backgroundColor: kGreyColor,
                  selectedColor: kPrimaryColor,
                  onSelected: (selected) async {
                    try {
                      await state.onSelected(selected, category);
                    } catch (e) {
                      showTextDialog(context, title: e.toString());
                    }
                  },
                ),
              ))
          .toList();
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          children: chipList,
        ),
      );
    }

    return DefaultPage(
      bodyWidget: Column(
        children: [
          categoryList(),
          jobsWidget(),
        ],
      ),
      pageName: "jobs",
    );
  }
}
