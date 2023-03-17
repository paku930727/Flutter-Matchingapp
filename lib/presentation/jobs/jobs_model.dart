import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:sukimachi/repository/job_repository.dart';

import '../../domain/category.dart';
import '../../domain/job.dart';
import '../../repository/category_repository.dart';

final jobsProvider = ChangeNotifierProvider.autoDispose((ref) => JobsModel(
    ref.read(jobRepositoryProvider), ref.read(categoryRepositoryProvider))
  ..init());

class JobsModel extends ChangeNotifier {
  JobsModel(this.jobRepository, this.categoryRepository);
  final JobRepository jobRepository;
  final CategoryRepository categoryRepository;
  List<Job>? jobs;
  List<Category> categories = [];
  List<Category> selectedCategories = [];

  Future init() async {
    await fetchJobsList();
    await fetchCategories();
  }

  Future<void> fetchJobsList() async {
    jobs = await jobRepository.fetchPublicJobList();
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    categories = await categoryRepository.fetchCategoryList();
    notifyListeners();
  }

  Future<void> fetchCategoryJobsList() async {
    jobs = await jobRepository.fetchCategoryJobsList(
        selectedCategories.map((category) => category.name).toList());
    notifyListeners();
  }

  // カテゴリChipのonSelected
  Future<void> onSelected(bool selected, Category category) async {
    if (selected) {
      if (selectedCategories.length >= 10) {
        throw "カテゴリはこれ以上選択できません。";
      }
      _addSelectedCategories(category);
    } else {
      _removeSelectedCategories(category);
      if (selectedCategories.isEmpty) {
        await fetchJobsList();
        return;
      }
    }
    await fetchCategoryJobsList();
    notifyListeners();
  }

  void _addSelectedCategories(Category category) {
    selectedCategories.add(category);
  }

  void _removeSelectedCategories(Category category) {
    selectedCategories.removeWhere((element) => element.name == category.name);
  }
}
