import * as functions from "firebase-functions";
import * as firebaseAdmin from "firebase-admin";

firebaseAdmin.initializeApp(functions.config().firebase);

import * as mail from "./mail";
import * as job from "./job";
import * as gift from "./gift";
import * as point from "./point";
import * as contact from "./contact";
import * as user from "./user";

export { mail, job, gift, point, contact, user };
