import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/repository/auth_repository.dart';
import 'package:sukimachi/repository/category_repository.dart';
import 'package:sukimachi/repository/contact_repository.dart';
import 'package:sukimachi/repository/gift_repository.dart';
import 'package:sukimachi/repository/job_repository.dart';
import 'package:sukimachi/repository/user_repository.dart';

import 'repository/auth_repository_mock.dart';
import 'repository/category_repository_mock.dart';
import 'repository/contact_repository_mock.dart';
import 'repository/gift_request_repository_mock.dart';
import 'repository/job_repository_mock.dart';
import 'repository/user_repository_mock.dart';

ProviderContainer overrideRepository() {
  return ProviderContainer(overrides: [
    authRepositoryProvider
        .overrideWithProvider(Provider((ref) => AuthRepositoryMock())),
    userRepositoryProvider.overrideWithProvider(Provider(
        (ref) => UserRepositoryMock(ref.read(authRepositoryProvider)))),
    jobRepositoryProvider
        .overrideWithProvider(Provider((ref) => JobRepositoryMock())),
    categoryRepositoryProvider
        .overrideWithProvider(Provider((ref) => CategoryRepositoryMock())),
    giftRequestRepositoryProvider
        .overrideWithProvider(Provider((ref) => GiftRequestRepositoryMock())),
    contactRepositoryProvider
        .overrideWithProvider(Provider((ref) => ContactRepositoryMock()))
  ]);
}
