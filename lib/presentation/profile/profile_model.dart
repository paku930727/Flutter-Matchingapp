import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/repository/user_repository.dart';

import '../../domain/user.dart';

final profileProvider = ChangeNotifierProvider.autoDispose.family(
    (ref, String id) =>
        ProfileModel(id, ref.watch(userRepositoryProvider))..init());

class ProfileModel extends ChangeNotifier {
  ProfileModel(this.id, this._userRepository);
  final String id;
  final UserRepository _userRepository;
  User? user;

  Future<void> init() async {
    await fetchUser(id);
  }

  Future<void> fetchUser(String id) async {
    user = await _userRepository.fetchUser(id);
    notifyListeners();
  }
}
