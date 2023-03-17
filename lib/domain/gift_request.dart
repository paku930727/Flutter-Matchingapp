import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sukimachi/constants.dart';

class GiftRequest {
  GiftRequest(
      {required this.type,
      required this.point,
      required this.status,
      required this.email,
      required this.giftRef,
      required this.userRef,
      required this.createdAt});

  final String type;
  final int point;
  final String status;
  final String email;
  final DocumentReference giftRef;
  final DocumentReference userRef;
  final Timestamp createdAt;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'point': point,
      'status': status,
      'email': email,
      'giftRef': giftRef,
      'userRef': userRef,
      'createdAt': createdAt,
    };
  }

  factory GiftRequest.fromMap(Map<String, dynamic> map) {
    return GiftRequest(
        type: map['type'],
        point: map['point'],
        status: map['status'],
        email: map['email'],
        giftRef: map['giftRef'],
        userRef: map['userRef'],
        createdAt: map['createdAt']);
  }

  String getStatusText() {
    switch (status) {
      case kGiftStatusInReview:
        return 'ポイント確認中';
      case kGiftStatusInsufficient:
        return 'ポイント不足';
      case kGiftStatusPassed:
        return 'ギフト準備中';
      case kGiftStatusDone:
        return 'ギフト発送済み';
      default:
        return 'ステータス不明';
    }
  }

  String getTitleText() {
    switch (type) {
      case kGiftTypeAmazon1000:
        return kGiftTitleAmazon1000;
      case kGiftTypeAmazon3000:
        return kGiftTitleAmazon3000;
      case kGiftTypeAmazon5000:
        return kGiftTitleAmazon5000;
      default:
        return '不明のギフト';
    }
  }
}
