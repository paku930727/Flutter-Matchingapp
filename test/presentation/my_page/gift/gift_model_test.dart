import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/gift.dart';
import 'package:sukimachi/presentation/my_page/gift/gift_model.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/repository/user_repository.dart';

import '../../../container.dart';
import '../../../dummy/dummy_constants.dart';
import '../../../dummy/dummy_secret_profils.dart';
import '../../../dummy/dummy_user.dart';
import '../../../repository/auth_repository_mock.dart';
import '../../../repository/user_repository_mock.dart';

void main() {
  late ProviderContainer _container;
  late UserRepositoryMock _userRepositoryMock;
  late AuthRepositoryMock _authRepositoryMock;

  /// ギフト一覧
  final List<Gift> amazonGift = [
    const Gift(kGiftPointAmazon1000, kGiftTypeAmazon1000, kGiftTitleAmazon1000,
        kGiftDetailAmazon1000), //33.3%
    const Gift(kGiftPointAmazon3000, kGiftTypeAmazon3000, kGiftTitleAmazon3000,
        kGiftDetailAmazon3000), //16.6%
    const Gift(kGiftPointAmazon5000, kGiftTypeAmazon5000, kGiftTitleAmazon5000,
        kGiftDetailAmazon5000), //13.8%
  ];

  setUp(() {
    _container = overrideRepository();
    _userRepositoryMock =
        _container.read(userRepositoryProvider) as UserRepositoryMock;
    _authRepositoryMock =
        _container.read(authRepositoryProvider) as AuthRepositoryMock;
  });

  test("GiftRequestのテスト(SecretProfileがnull)", () async {
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _authRepositoryMock.authenticate();

    final state = _container.read(giftProvider);
    await state.init();
    expect(() async => await state.requestGift(amazonGift[0]),
        throwsA(isA<String>()));
  });

  test("GiftRequestのテスト(成功)", () async {
    _userRepositoryMock.set(dummyUserList, dummySecretProfile);
    await _authRepositoryMock.authenticate();
    fakeFirebaseFirestore
        .collection(kUsers)
        .doc(miyajiUserRef.id)
        .collection(kSecretProfile)
        .doc()
        .set({
      'point': dummySecretProfile[0].point,
      'secretProfileRef': dummySecretProfile[0].secretProfileRef
    });

    final state = _container.read(giftProvider);
    await state.init();
    for (var i = 0; i < 2; i++) {
      await state.requestGift(amazonGift[i]);
    }
    expect(() async => await state.requestGift(amazonGift[2]),
        throwsA(isA<String>()));
    expect(state.giftRequests!.length, 2);
  });
}
