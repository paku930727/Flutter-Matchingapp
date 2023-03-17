import { IncomingWebhook, IncomingWebhookSendArguments } from "@slack/webhook";
import {
  contactDevChannelURL,
  contactProdChannelURL,
  giftDevChannelURL,
  giftProdChannelURL,
  othersDevChannelURL,
  othersProdChannelURL,
} from "./constants";
import {
  accountCreatedBody,
  contactSlackBody,
  failureDeleteAccountBody,
  requestedGiftSlackBody,
  successDeleteAccountBody,
} from "./slackBody";
import { getIsProd } from "./util";

const sendSlack = async (
  webhookUrl: string,
  message: string | IncomingWebhookSendArguments
) => {
  const webhook = new IncomingWebhook(webhookUrl);
  await webhook.send(message);
};

export const sendContactSlack = (contactDetail: string, contactId: string) => {
  const webhookUrl = getIsProd() ? contactProdChannelURL : contactDevChannelURL;
  sendSlack(webhookUrl, contactSlackBody(contactDetail, contactId));
};

export const sendAccountCreatedSlack = async (
  displayName: string | undefined,
  userId: string
) => {
  const webhookUrl = getIsProd() ? othersProdChannelURL : othersDevChannelURL;
  await sendSlack(webhookUrl, accountCreatedBody(displayName, userId));
};

export const sendSuccessDeleteAccountSlack = async (user: any) => {
  const webhookUrl = getIsProd() ? othersProdChannelURL : othersDevChannelURL;
  await sendSlack(webhookUrl, successDeleteAccountBody(user));
};

export const sendFailureDeleteAccountSlack = async (user: any) => {
  const webhookUrl = getIsProd() ? othersProdChannelURL : othersDevChannelURL;
  await sendSlack(webhookUrl, failureDeleteAccountBody(user));
};

export const sendGiftRequestSlack = async (giftId: string) => {
  const webhookUrl = getIsProd() ? giftProdChannelURL : giftDevChannelURL;
  await sendSlack(webhookUrl, requestedGiftSlackBody(giftId));
};
