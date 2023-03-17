import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/job.dart';
import 'package:sukimachi/repository/job_repository.dart';

final homeProvider = ChangeNotifierProvider.autoDispose(
    (ref) => HomeModel(ref.read(jobRepositoryProvider))..init());

class HomeModel extends ChangeNotifier {
  HomeModel(this.jobRepository);

  final JobRepository jobRepository;

  List<Job> officialJobs = [];

  Future init() async {
    await fetchOfficialJobList();
    notifyListeners();
  }

  Future fetchOfficialJobList() async {
    for (var id in officialJobIds) {
      final newJob = await jobRepository.fetchJob(id);
      if (newJob != null) {
        officialJobs.add(newJob);
      }
    }
  }
}
