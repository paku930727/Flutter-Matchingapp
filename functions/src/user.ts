import * as functions from "firebase-functions";
import { firestore, storage, auth } from "firebase-admin";
import {
  sendFailureDeleteAccountMail,
  sendSuccessDeleteAccountMail,
} from "./mail";
import {
  sendFailureDeleteAccountSlack,
  sendSuccessDeleteAccountSlack,
} from "./slack";

export const onIsDeletedTrue = functions
  .region("asia-northeast1")
  .firestore.document("/users/{userId}")
  .onUpdate(async (snap, context) => {
    const beforeIsDeleted = snap.before.data().isDeleted;
    const afterIsDeleted = snap.after.data().isDeleted;
    // 更新前がisDeleted == falseかつ更新後がisDeleted == trueの場合のみ処理を実行する。
    if (!beforeIsDeleted && afterIsDeleted) {
      console.log("start deleteAccount");
      const user = snap.after.data();
      console.log(user.userName);
      // 退会チェック

      // IN_REVIEW,ACCEPTEDの応募が存在しないか
      const isExistsMyApplicationInReviewOrAccepted =
        await getIsExistsMyApplicationInReviewOrAccepted(user);
      if (isExistsMyApplicationInReviewOrAccepted) {
        console.log("IN_REVIEW,ACCEPTEDの応募が存在します。");
      } else {
        console.log("IN_REVIEW,ACCEPTEDの応募が存在しません。");
      }
      // IN_REVIEW,ACCEPTEDの応募が存在するjobを持っていないか
      const isExistsMyJobHasApplicationInReviewOrAccepted =
        await getIsExistsMyJobHasApplicationInReviewOrAccepted(user);
      if (isExistsMyJobHasApplicationInReviewOrAccepted) {
        console.log("IN_REVIEW,ACCEPTEDの応募がある依頼が存在します。");
      } else {
        console.log("IN_REVIEW,ACCEPTEDの応募がある依頼が存在しません。");
      }

      // PUBLICのJobを持っていないか
      const isExistsMyPublicJobs = await getIsExistsMyPublicJobs(user);
      if (isExistsMyPublicJobs) {
        console.log("PUBLICな依頼が存在します。");
      } else {
        console.log("PUBLICな依頼が存在しません。");
      }

      // authを削除してからだとメールアドレスを取得できなくなるので、ここで取得しておく
      const userAuth = await auth().getUser(user.userRef.id);
      const userEmail = userAuth.email;

      if (!userEmail) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "user email is required"
        );
      }

      if (
        !isExistsMyApplicationInReviewOrAccepted &&
        !isExistsMyJobHasApplicationInReviewOrAccepted &&
        !isExistsMyPublicJobs
      ) {
        // 退会処理を実施する
        const isSuccess = await deleteAccount(user.userRef.id);
        if (isSuccess) {
          // 退会完了メールを送信
          await sendSuccessDeleteAccountMail(user, userEmail);
          await sendSuccessDeleteAccountSlack(user);
          return;
        }
      }
      // 退会失敗処理を実施する
      await sendFailureDeleteAccountMail(user, userEmail);
      await sendFailureDeleteAccountSlack(user);
      await user.userRef.update(snap.before.data());
    }
  });

export const getIsExistsMyPublicJobs = async (user: any) => {
  const snapshot = await user.userRef
    .collection("clientJobs")
    .where("jobStatus", "==", "PUBLIC")
    .get();
  return snapshot.docs.length !== 0;
};

export const getIsExistsMyApplicationInReviewOrAccepted = async (user: any) => {
  const snapshot = await user.userRef
    .collection("applications")
    .where("status", "in", ["IN_REVIEW", "ACCEPTED"])
    .get();
  return snapshot.docs.length !== 0;
};

export const getIsExistsMyJobHasApplicationInReviewOrAccepted = async (
  user: any
) => {
  const jobSnapshot: firestore.QuerySnapshot = await user.userRef
    .collection("clientJobs")
    .get();
  if (jobSnapshot.docs.length === 0) {
    return false;
  }

  for (let i = 0; i < jobSnapshot.docs.length; i++) {
    const applicationSnapshot = await jobSnapshot.docs[i]
      .data()
      .jobRef.collection("applications")
      .where("status", "in", ["IN_REVIEW", "ACCEPTED"])
      .get();
    if (applicationSnapshot.docs.length !== 0) {
      return true;
    }
  }
  return false;
};

export const uploadDeleteAccountImage = async (userId: string) => {
  const uploadPath = `users/${userId}/profileImg/${userId}_profile.jpeg`;
  const bucket = storage().bucket();
  await bucket.upload("image/deletedAccountImage.png", {
    destination: uploadPath,
  });
};

// 実際の退会処理
// 退会済み画像のアップロード
// Authユーザの削除
export const deleteAccount = async (userId: string): Promise<boolean> => {
  try {
    console.log("退会済みユーザ画像アップロード開始");
    await uploadDeleteAccountImage(userId);
    console.log("退会済みユーザ画像アップロード完了");
    console.log("退会済みユーザAuthを削除開始");
    await auth().deleteUser(userId);
    console.log("退会済みユーザAuthを削除完了");
    return true;
  } catch (e) {
    // 退会済み処理が失敗したことを通知
    return false;
  }
};
