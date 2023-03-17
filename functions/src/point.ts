import { firestore } from "firebase-admin";
import * as firebaseAdmin from "firebase-admin";
import * as functions from "firebase-functions";

const kPointEvents = "pointEvents";
const db = firebaseAdmin.firestore();

export const addPointGet = async (application: any) => {
  const type = "GET";
  const point = application.jobPrice;
  const createdAt = firebaseAdmin.firestore.Timestamp.now();
  const effectiveDate = createdAt.toDate();
  effectiveDate.setDate(effectiveDate.getDate() + 180); // 1日前
  effectiveDate.setHours(-7); // 午前2時 (時差9時間分)
  effectiveDate.setMinutes(0);
  effectiveDate.setSeconds(0);
  const event = {
    type: type,
    point: point,
    createdAt: createdAt,
    effectiveDate: effectiveDate,
    applicationRef: application.applicationRef,
  };

  application.applicantRef.collection(kPointEvents).doc().set(event);
};

export const addPointUse = async (giftRequest: any) => {
  const type = "USE";
  const point = giftRequest.point;
  const createdAt = firebaseAdmin.firestore.Timestamp.now();
  const giftRef = giftRequest.giftRef;

  // ユーザの残ポイントを計算する
  const currentPoint = await calculateCurrentPoint(giftRequest.userRef);
  console.log(currentPoint);
  if (currentPoint < point) {
    // ポイントが足りないのでgiftRequestのstatusをINSUFFICIENTに変更
    await giftRef.update({
      status: "INSUFFICIENT",
    });
  } else {
    // ポイントが足りているので、ポイントイベントを作成&statusをpassedに変更
    const event = {
      type: type,
      point: point,
      createdAt: createdAt,
      giftRef: giftRef,
    };
    await giftRequest.userRef.collection(kPointEvents).doc().set(event);
    await giftRef.update({
      status: "PASSED",
    });
  }
};

export const calculateCurrentPoint = async (
  userRef: firebaseAdmin.firestore.DocumentReference
) => {
  const pointEvents = await userRef.collection(kPointEvents).get();
  let currentPoint = 0;
  // userのポイントを数え上げる。
  // typeがGETなら加算、USEorLOSTなら減算
  for (const doc of pointEvents.docs) {
    const pointEvent = doc.data();
    if (pointEvent.type === "GET") {
      currentPoint += pointEvent.point;
    } else {
      currentPoint -= pointEvent.point;
    }
  }
  return currentPoint;
};

export const onCreatePointEvent = functions
  .region("asia-northeast1")
  .firestore.document("users/{userId}/pointEvents/{pointEventId}")
  .onCreate(async (snap, context) => {
    const pointEvent = snap.data();
    const isPlus = pointEvent.type === "GET";
    const point = pointEvent.point * getSign(isPlus);

    const userRef = snap.ref.parent.parent;
    if (userRef == undefined) {
      throw Error("ユーザが見つかりません。");
    }
    const secretProfiles = await userRef!.collection("secretProfiles").get();

    if (secretProfiles.empty) {
      // secretProfileが存在しない
      const secretProfileRef = userRef!.collection("secretProfiles").doc();
      secretProfileRef.set({
        point: point,
        secretProfileRef: secretProfileRef,
      });
    } else {
      // secretProfileが存在
      const secretProfile = secretProfiles.docs[0].data();
      // pointが存在しない場
      if (secretProfile.point == undefined) {
        secretProfile.secretProfileRef.set({ point: point });
      }
      secretProfile.secretProfileRef.update({
        point: firestore.FieldValue.increment(point),
      });
    }
  });

export const getSign = (isPlus: boolean) => {
  if (isPlus) {
    return 1;
  } else {
    return -1;
  }
};

exports.checkLostPoint = functions
  .region("asia-northeast1")
  .pubsub.schedule("every day 02:00")
  .timeZone("Asia/Tokyo")
  .onRun(async (context) => {
    const userList = await db.collection("users").get();
    const userIdList = userList.docs.map((doc) => doc.id);
    const currentTime = firebaseAdmin.firestore.Timestamp.now().toDate();
    currentTime.setHours(-7); // 午前2時 (時差9時間分)
    currentTime.setMinutes(0);
    currentTime.setSeconds(0);
    currentTime.setMilliseconds(0);
    console.log(currentTime);
    console.log(firebaseAdmin.firestore.Timestamp.fromDate(currentTime));

    for (const userId of userIdList) {
      // 各ループはトランザクションで実行する。
      db.runTransaction(async (t) => {
        const snapshot = await t.get(
          db.collection("users").doc(userId).collection("pointEvents")
          // .where("effectiveDate", "==", currentTime)
        );

        if (snapshot.empty) {
          console.log(`${userId}は本日失効するポイントがありません。`);
        } else {
          // USEとLOSTのpointEventを取得
          const usePointSnapshot = await t.get(
            db
              .collection("users")
              .doc(userId)
              .collection("pointEvents")
              .where("type", "==", "USE")
          );
          const usePointEvents = usePointSnapshot.docs.map((doc) => doc.data());
          const lostPointSnapshot = await t.get(
            db
              .collection("users")
              .doc(userId)
              .collection("pointEvents")
              .where("type", "==", "LOST")
          );

          const lostPointEvents = lostPointSnapshot.docs.map((doc) =>
            doc.data()
          );

          // 今日までに有効期限が切れたpointEventを取得
          const getPointSnapshot = await t.get(
            db
              .collection("users")
              .doc(userId)
              .collection("pointEvents")
              .where("type", "==", "GET")
              .where("effectiveDate", "<=", currentTime)
          );
          const getPointEvents = getPointSnapshot.docs.map((doc) => doc.data());

          // 今日消費されるpointを計算

          // 使用済みポイントの合計
          const totalUsePoint = usePointEvents
            .map((event) => event.point)
            .reduce((x: number, y: number) => x + y, 0);
          console.log(`totalUsePoint ${totalUsePoint}`);
          // 失効済みポイントの合計
          const totalLostPoint = lostPointEvents
            .map((event) => event.point)
            .reduce((x: number, y: number) => x + y, 0);
          console.log(`totalLostPoint ${totalLostPoint}`);
          // 今日までに有効期限が切れている取得ポイントの合計
          const totalGetPoint = getPointEvents
            .map((event) => event.point)
            .reduce((x: number, y: number) => x + y, 0);
          console.log(`totalGetPoint ${totalGetPoint}`);
          const lostPoint = totalGetPoint - totalUsePoint - totalLostPoint;

          // 今日消費されるpointEventを作成
          if (lostPoint > 0) {
            console.log(`${userId}のポイントを${lostPoint}失効しました。`);
            await t.set(
              db
                .collection("users")
                .doc(userId)
                .collection("pointEvents")
                .doc(),
              {
                type: "LOST",
                point: lostPoint,
                createdAt: currentTime,
              }
            );
          } else {
            console.log(`${userId}は本日失効するポイントがありません。`);
          }
        }
      });
    }
  });
