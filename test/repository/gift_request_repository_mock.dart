import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/gift.dart';
import 'package:sukimachi/domain/gift_request.dart';
import 'package:sukimachi/repository/gift_repository.dart';

class GiftRequestRepositoryMock implements GiftRequestRepository {
  @override
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
    giftRequestDocument.set(giftRequest.toJson());
  }

  @override
  Future<List<GiftRequest>> fetchGiftRequests(
      DocumentReference<Object?> userRef) async {
    final snapshot = await userRef.collection(kGiftRequest).get();
    return snapshot.docs.map((doc) => GiftRequest.fromMap(doc.data())).toList();
  }
}
