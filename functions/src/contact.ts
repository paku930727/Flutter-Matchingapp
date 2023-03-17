import * as functions from "firebase-functions";
import { sendContactSlack } from "./slack";

export const onCreateContact = functions
  .region("asia-northeast1")
  .firestore.document("contact/{id}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    sendContactSlack(data["contactDetail"], snap.id);
  });
