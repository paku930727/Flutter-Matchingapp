import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/gift_request.dart';

import '../domain/gift.dart';

final giftRequestRepositoryProvider =
    Provider<GiftRequestRepository>((ref) => GiftRequestRepository.instance);

class GiftRequestRepository {
  GiftRequestRepository._();

  static final instance = GiftRequestRepository._();

  Future<void> requestGift(
      {required DocumentReference userRef,
      required Gift gift,
      required String email}) async {
    final giftRequestDocument = userRef.collection(kGiftRequest).doc();
    final giftRequest = GiftRequest(
        type: gift.type,
        point: gift.point,
        status: kGiftStatusInReview,
        email: email,
        giftRef: giftRequestDocument,
        userRef: userRef,
        createdAt: Timestamp.fromDate(DateTime.now()));
    await giftRequestDocument.set(giftRequest.toJson());
  }

  Future<List<GiftRequest>> fetchGiftRequests(DocumentReference userRef) async {
    final snapshot = await userRef.collection(kGiftRequest).get();
    return snapshot.docs.map((doc) => GiftRequest.fromMap(doc.data())).toList();
  }
}
