import * as functions from "firebase-functions";
import * as firebaseAdmin from "firebase-admin";
import { getIsProd } from "./util";
import {
  applicationAcceptedMailBodyToApplicant,
  applicationAcceptedMailBodyToClient,
  applicationRejectedMailBodyToApplicant,
  applicationRejectedMailBodyToClient,
  applicationDoneMailBodyToApplicant,
  appliedMailBodyToApplicant,
  appliedMailBodyToClient,
  registerMailBody,
  applicationDoneMailBodyToClient,
  giftRequestPassedMailBody,
  giftRequestInsufficientMailBody,
  sentAmazonGiftMailBody,
  successDeleteAccountMailBody,
  failureDeleteAccountMailBody,
} from "./mailBody";
import { sendAccountCreatedSlack } from "./slack";

const db = firebaseAdmin.firestore();

export const sendMail = async (
  email: string,
  subjectText: string,
  contentText: string
) => {
  const isProd = getIsProd();
  if (!isProd) subjectText = "[開発]" + subjectText;

  const mailData = {
    to: email,
    from: "スキ街<info@sukimachi.app>",
    message: {
      subject: subjectText,
      text: contentText,
    },
    createdAt: firebaseAdmin.firestore.FieldValue.serverTimestamp(),
  };

  await db.collection("mail").add(mailData);
};

export const onCreateUser = functions
  .region("asia-northeast1")
  .auth.user()
  .onCreate(async (data, context) => {
    const { displayName, email } = data;

    if (!email) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "email is required"
      );
    }

    const subjectText = "ご登録ありがとうございます";

    await sendMail(email, subjectText, registerMailBody(displayName));
    await sendAccountCreatedSlack(displayName, data.uid);
  });

export const sendApplicationMailToApplicant = async (application: any) => {
  const applicantId = application.applicantRef.id;
  const applicant = await firebaseAdmin.auth().getUser(applicantId);
  const applicantEmail = applicant.email;

  if (!applicantEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "applicant email is required"
    );
  }

  const subjectTextToApplicant = "依頼への応募が完了しました";
  await sendMail(
    applicantEmail,
    subjectTextToApplicant,
    appliedMailBodyToApplicant(application)
  );
};

export const sendApplicationMailToClient = async (application: any) => {
  const clientId = application.clientRef.id;
  const client = await firebaseAdmin.auth().getUser(clientId);
  const clientEmail = client.email;
  if (!clientEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "client email is required"
    );
  }

  const subjectTextToClient = "依頼への応募がありました";

  sendMail(
    clientEmail,
    subjectTextToClient,
    appliedMailBodyToClient(application)
  );
};

export const sendApplicationAcceptedMailToApplicant = async (
  application: any
) => {
  const applicantId = application.applicantRef.id;
  const applicant = await firebaseAdmin.auth().getUser(applicantId);
  const applicantEmail = applicant.email;

  if (!applicantEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "applicant email is required"
    );
  }

  const subjectTextToApplicant = "依頼への応募が承諾されました";
  await sendMail(
    applicantEmail,
    subjectTextToApplicant,
    applicationAcceptedMailBodyToApplicant(application)
  );
};

export const sendApplicationAcceptedMailToClient = async (application: any) => {
  const clientId = application.clientRef.id;
  const client = await firebaseAdmin.auth().getUser(clientId);
  const clientEmail = client.email;
  if (!clientEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "client email is required"
    );
  }
  const subjectTextToClient = "依頼への応募を承諾いたしました";
  await sendMail(
    clientEmail,
    subjectTextToClient,
    applicationAcceptedMailBodyToClient(application)
  );
};

export const sendApplicationRejectedMailToApplicant = async (
  application: any
) => {
  const applicantId = application.applicantRef.id;
  const applicant = await firebaseAdmin.auth().getUser(applicantId);
  const applicantEmail = applicant.email;

  if (!applicantEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "applicant email is required"
    );
  }
  const subjectTextToApplicant = "依頼への応募がお見送りとなりました";
  await sendMail(
    applicantEmail,
    subjectTextToApplicant,
    applicationRejectedMailBodyToApplicant(application)
  );
};

export const sendApplicationRejectedMailToClient = async (application: any) => {
  const clientId = application.clientRef.id;
  const client = await firebaseAdmin.auth().getUser(clientId);
  const clientEmail = client.email;
  if (!clientEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "client email is required"
    );
  }
  const subjectTextToClient = "依頼への応募を見送りとしました";

  await sendMail(
    clientEmail,
    subjectTextToClient,
    applicationRejectedMailBodyToClient(application)
  );
};

// 依頼が完了したときに送るメール(受注者)
export const sendApplicationDoneMailToApplicant = async (application: any) => {
  const applicantId = application.applicantRef.id;
  const applicant = await firebaseAdmin.auth().getUser(applicantId);
  const applicantEmail = applicant.email;

  if (!applicantEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "applicant email is required"
    );
  }
  const subjectTextToApplicant = "依頼が完了しました！";
  await sendMail(
    applicantEmail,
    subjectTextToApplicant,
    applicationDoneMailBodyToApplicant(application)
  );
};

// 依頼が完了したときに送るメール(発注者)
export const sendApplicationDoneMailToClient = async (application: any) => {
  const clientId = application.clientRef.id;
  const client = await firebaseAdmin.auth().getUser(clientId);
  const clientEmail = client.email;
  if (!clientEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "client email is required"
    );
  }

  const subjectTextToApplicant = "依頼が完了しました！";
  await sendMail(
    clientEmail,
    subjectTextToApplicant,
    applicationDoneMailBodyToClient(application)
  );
};

// ギフト申請が通ったときに送るメール
export const sendGiftRequestPassedMail = async (giftRequest: any) => {
  const userRef = giftRequest.userRef;
  const userSnapshot = await userRef.get();
  const user = userSnapshot.data();
  const userId = userRef.id;
  const userAuth = await firebaseAdmin.auth().getUser(userId);
  const userEmail = userAuth.email;

  if (!userEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "user email is required"
    );
  }

  const subjectText = "ギフト申請を承りました！";
  await sendMail(
    userEmail,
    subjectText,
    giftRequestPassedMailBody(giftRequest, user)
  );
};

// ギフト申請がリジェクトされたときに送るメール
export const sendGiftRequestInsufficientMail = async (giftRequest: any) => {
  const userRef = giftRequest.userRef;
  const userSnapshot = await userRef.get();
  const user = userSnapshot.data();
  const userId = userRef.id;
  const userAuth = await firebaseAdmin.auth().getUser(userId);
  const userEmail = userAuth.email;

  if (!userEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "user email is required"
    );
  }

  const subjectText = "ギフト申請が承諾されませんでした。";
  await sendMail(
    userEmail,
    subjectText,
    giftRequestInsufficientMailBody(giftRequest, user)
  );
};

// ギフトを発想したときに送るメール
export const sendSentGiftMail = async (giftRequest: any) => {
  const userRef = giftRequest.userRef;
  const userSnapshot = await userRef.get();
  const user = userSnapshot.data();
  const userId = userRef.id;
  const userAuth = await firebaseAdmin.auth().getUser(userId);
  const userEmail = userAuth.email;

  if (!userEmail) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "user email is required"
    );
  }

  // ギフトのタイプごとにメールの本文を差し替える
  let mailBody = "";
  switch (giftRequest.type) {
    case "AMAZON_GIFT_1000":
    case "AMAZON_GIFT_3000":
    case "AMAZON_GIFT_5000":
      mailBody = sentAmazonGiftMailBody(giftRequest, user);
      break;
    default:
      // 不明なGiftTypeの場合
      break;
  }
  const subjectText = "ギフトを発送いたしました！";
  await sendMail(userEmail, subjectText, mailBody);
};

export const sendSuccessDeleteAccountMail = async (
  user: any,
  userEmail: string
) => {
  const subjectText = "退会完了メール";
  const mailBody = successDeleteAccountMailBody(user);
  await sendMail(userEmail, subjectText, mailBody);
  console.log("退会完了メール送信完了");
};

export const sendFailureDeleteAccountMail = async (
  user: any,
  userEmail: string
) => {
  const subjectText = "退会に失敗しました。";
  const mailBody = failureDeleteAccountMailBody(user);
  await sendMail(userEmail, subjectText, mailBody);
  console.log("退会失敗メール送信完了");
};
