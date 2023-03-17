import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/category.dart';

final categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) => CategoryRepository.instance);

class CategoryRepository {
  CategoryRepository._();

  static final instance = CategoryRepository._();
  final _firestore = FirebaseFirestore.instance;

  Future<Category> fetchCategory(String id) async {
    final snapshot = await _firestore.collection('categories').doc(id).get();
    final data = snapshot.data()!;
    final job = Category.fromJson(data);
    return job;
  }

  Future<List<Category>> fetchCategoryList() async {
    final snapshot =
        await _firestore.collection('categories').orderBy('number').get();
    final jobList =
        snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList();
    return jobList;
  }
}
