import * as functions from "firebase-functions";
import {
  sendGiftRequestInsufficientMail,
  sendGiftRequestPassedMail,
  sendSentGiftMail,
} from "./mail";
import { addPointUse } from "./point";
import { sendGiftRequestSlack } from "./slack";

export const giftRequestsCreated = functions
  .region("asia-northeast1")
  .firestore.document("/users/{userId}/giftRequests/{giftRequestId}")
  .onCreate(async (snap, context) => {
    const giftRequest = snap.data();
    console.log("giftRequestsCreated");
    await addPointUse(giftRequest);
    await sendGiftRequestSlack(snap.id);
  });

export const giftRequestsUpdate = functions
  .region("asia-northeast1")
  .firestore.document("/users/{userId}/giftRequests/{giftRequestId}")
  .onUpdate(async (snap, context) => {
    const giftRequest = snap.after.data();

    switch (giftRequest.status) {
      case "PASSED":
        // ギフト申請が通り発送待ち状態
        sendGiftRequestPassedMail(giftRequest);
        break;
      case "INSUFFICIENT":
        // ポイントが通らなくてギフト申請リジェクト
        sendGiftRequestInsufficientMail(giftRequest);
        break;
      case "SENT":
        // ギフト発送済み
        sendSentGiftMail(giftRequest);
        break;
      default:
        // 不明のステータス
        break;
    }
  });
