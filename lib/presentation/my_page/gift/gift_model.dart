import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/gift.dart';
import 'package:sukimachi/domain/gift_request.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/repository/gift_repository.dart';
import 'package:sukimachi/repository/user_repository.dart';
import '../../../domain/user.dart';

final giftProvider = ChangeNotifierProvider((ref) => GiftModel(
    ref.watch(giftRequestRepositoryProvider),
    ref.watch(userRepositoryProvider),
    ref.watch(authRepositoryProvider))
  ..init());

class GiftModel extends ChangeNotifier {
  GiftModel(
      this.giftRequestRepository, this.userRepository, this.authRepository);

  final GiftRequestRepository giftRequestRepository;
  final UserRepository userRepository;
  final AuthRepository authRepository;
  List<GiftRequest>? giftRequests;
  User? currentUser;
  int currentUserPoint = 0;

  Future<void> init() async {
    currentUser = await userRepository.fetchCurrentUserCache();
    await fetchCurrentUserPoint();
    await fetchGiftRequests();
    notifyListeners();
  }

  /// ギフト一覧
  final List<Gift> amazonGift = [
    const Gift(kGiftPointAmazon1000, kGiftTypeAmazon1000, kGiftTitleAmazon1000,
        kGiftDetailAmazon1000), //33.3%
    const Gift(kGiftPointAmazon3000, kGiftTypeAmazon3000, kGiftTitleAmazon3000,
        kGiftDetailAmazon3000), //16.6%
    const Gift(kGiftPointAmazon5000, kGiftTypeAmazon5000, kGiftTitleAmazon5000,
        kGiftDetailAmazon5000), //13.8%
  ];

  Future<void> fetchCurrentUserPoint() async {
    final secretProfile = await userRepository.fetchSecretProfile();
    if (secretProfile == null) {
      currentUserPoint = 0;
      return;
    }
    currentUserPoint = secretProfile.point;
  }

  Future<void> requestGift(Gift gift) async {
    if (currentUser == null) {
      throw "ユーザが見つかりません。";
    }
    if (gift.point > currentUserPoint) {
      throw "ポイントが足りません。";
    }
    final email = authRepository.getEmail();
    await giftRequestRepository.requestGift(
        userRef: currentUser!.userRef, gift: gift, email: email);
    await fetchGiftRequests();
    notifyListeners();
  }

  Future<void> fetchGiftRequests() async {
    if (currentUser == null) {
      throw "ユーザが見つかりません。";
    }
    giftRequests =
        await giftRequestRepository.fetchGiftRequests(currentUser!.userRef);
  }
}
