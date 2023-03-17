import 'package:cloud_firestore/cloud_firestore.dart';

class ExampleRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchTestCase(String id) async {
    final snapshot = await _firestore.collection('test').doc(id).get();
    final data = snapshot.data()!;
    return data;
  }
}
