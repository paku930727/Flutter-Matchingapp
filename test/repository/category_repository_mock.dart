import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sukimachi/domain/category.dart';
import 'package:sukimachi/repository/category_repository.dart';

class CategoryRepositoryMock implements CategoryRepository {
  final _fakeFirebaseFirestore = FakeFirebaseFirestore();

  void set(List<Category> list) {
    for (var element in list) {
      _fakeFirebaseFirestore.collection('categories').doc().set({
        'name': element.name,
        'number': element.number,
      });
    }
  }

  @override
  Future<Category> fetchCategory(String id) {
    // TODO: implement fetchCategory
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> fetchCategoryList() async {
    final snapshot = await _fakeFirebaseFirestore
        .collection('categories')
        .orderBy('number')
        .get();
    final jobList =
        snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList();
    return jobList;
  }
}
