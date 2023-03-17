import { firestore } from "firebase-admin";
import * as functions from "firebase-functions";
import {
  sendApplicationAcceptedMailToApplicant,
  sendApplicationAcceptedMailToClient,
  sendApplicationDoneMailToApplicant,
  sendApplicationDoneMailToClient,
  sendApplicationMailToApplicant,
  sendApplicationMailToClient,
  sendApplicationRejectedMailToApplicant,
  sendApplicationRejectedMailToClient,
} from "./mail";
import { addPointGet } from "./point";

export const jobCreated = functions
  .region("asia-northeast1")
  .firestore.document("jobs/{jobsId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    data.clientRef.collection("clientJobs").doc(snap.id).set(data);
  });

export const jobUpdated = functions
  .region("asia-northeast1")
  .firestore.document("jobs/{jobsId}")
  .onUpdate(async (snap, context) => {
    const data = snap.after.data();
    data.clientRef.collection("clientJobs").doc(snap.after.id).set(data);

    // 残りの依頼を全てリジェクトする
    if (data.jobStatus == "CLOSED") {
      rejectRemainingApplications(data.jobRef);
    }
  });

export const rejectRemainingApplications = async (
  jobRef: firestore.DocumentReference
) => {
  const applications: firestore.QuerySnapshot = await jobRef
    .collection("applications")
    .where("status", "==", "IN_REVIEW")
    .get();
  applications.docs.forEach((application) =>
    application.data()["applicationRef"].update({ status: "REJECTED" })
  );
};

export const applicationCreated = functions
  .region("asia-northeast1")
  .firestore.document("users/{userId}/applications/{jobId}")
  .onCreate(async (snap, context) => {
    const application = snap.data();
    // 依頼への応募をjob配下のサブコレクションにコピーする
    const newApplicationRef = application.jobRef
      .collection("applications")
      .doc(application.applicantRef.id);
    application["applicationRef"] = newApplicationRef;
    newApplicationRef.set(application);

    // 依頼への応募が完了したことを応募者にメールする
    sendApplicationMailToApplicant(application);

    // 依頼への応募があったことを発注者にメールする
    sendApplicationMailToClient(application);
  });

export const applicationDelete = functions
  .region("asia-northeast1")
  .firestore.document("users/{userId}/applications/{jobId}")
  .onDelete(async (snap, context) => {
    const data = snap.data();
    data.jobRef.collection("applications").doc(data.applicantRef.id).delete();
  });

export const applicationUpdate = functions
  .region("asia-northeast1")
  .firestore.document("jobs/{jobId}/applications/{applicationId}")
  .onUpdate(async (snap, context) => {
    const application = snap.after.data();
    const underUserApplicationRef = application.applicantRef
      .collection("applications")
      .doc(application.jobRef.id);
    underUserApplicationRef.update({
      status: application.status,
    });

    if (application.status === "ACCEPTED") {
      await sendApplicationAcceptedMailToApplicant(application);
      await sendApplicationAcceptedMailToClient(application);
      await countUpOrderedJobsCount(application);
      await countUpAcceptedJobsCount(application);
    } else if (application.status === "REJECTED") {
      await sendApplicationRejectedMailToApplicant(application);
      await sendApplicationRejectedMailToClient(application);
    } else if (application.status === "DONE") {
      await sendApplicationDoneMailToApplicant(application);
      await sendApplicationDoneMailToClient(application);
      await addPointGet(application);
    }
  });

export const countUpOrderedJobsCount = async (application: any) => {
  application.clientRef.update({
    orderedJobsCount: firestore.FieldValue.increment(1),
  });
};

export const countUpAcceptedJobsCount = async (application: any) => {
  application.applicantRef.update({
    acceptedJobsCount: firestore.FieldValue.increment(1),
  });
};
