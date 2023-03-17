import { environment, getAdminDomain, getIsProd } from "./util";

// Slack通知のメンションに使う
const mentionTarget = getIsProd() ? "@U042NMGD22V" : "@someone";

export const contactSlackBody = (contactDetail: string, contactId: string) => {
  const adminUrl = getIsProd()
    ? `https://sukimachi-cms.web.app/contacts/${contactId}}`
    : `https://sukimachi-dev-cms.web.app/contacts/${contactId}`;
  return {
    text: `<${mentionTarget}> <${adminUrl}|Open Detail>`,
    username: "お問い合わせbot",
    icon_emoji: ":robot_face:",
    attachments: [
      {
        color: "#CECE00",
        fields: [
          {
            title: "お問い合わせ内容",
            value: `${contactDetail}`,
          },
          {
            title: "実行環境",
            value: `${environment()}`,
          },
        ],
      },
    ],
  };
};

export const accountCreatedBody = (
  displayName: string | undefined,
  uid: string
) => {
  const adminUrl = getAdminDomain() + "/users";
  return {
    text: `<${mentionTarget}> <${adminUrl}|Open Detail>`,
    username: "通知bot",
    icon_emoji: ":heart_eyes:",
    attachments: [
      {
        color: "#CECE00",
        fields: [
          {
            title: "通知内容",
            value: `${displayName}がスキ街に参加しました！
              uid: ${uid}
              `,
          },
          {
            title: "実行環境",
            value: `${environment()}`,
          },
        ],
      },
    ],
  };
};

export const successDeleteAccountBody = (user: any) => {
  const adminUrl = getAdminDomain() + "/users";
  return {
    text: `<${mentionTarget}> <${adminUrl}|Open Detail>`,
    username: "通知bot",
    icon_emoji: ":cry:",
    attachments: [
      {
        color: "#CECE00",
        fields: [
          {
            title: "通知内容",
            value: `${user.userName}の退会が完了しました。`,
          },
          {
            title: "実行環境",
            value: `${environment()}`,
          },
        ],
      },
    ],
  };
};

export const failureDeleteAccountBody = (user: any) => {
  const adminUrl = getAdminDomain() + "/users";
  return {
    text: `<${mentionTarget}> <${adminUrl}|Open Detail>`,
    username: "通知bot",
    icon_emoji: ":innocent:",
    attachments: [
      {
        color: "#CECE00",
        fields: [
          {
            title: "通知内容",
            value: `${user.userName}の退会が失敗しました。原因を調査してください。`,
          },
          {
            title: "実行環境",
            value: `${environment()}`,
          },
        ],
      },
    ],
  };
};

export const requestedGiftSlackBody = (giftId: string) => {
  const adminUrl = getAdminDomain() + "/gifts";
  return {
    text: `<${mentionTarget}> <${adminUrl}|Open Detail>`,
    username: "ギフト通知bot",
    icon_emoji: ":gift:",
    attachments: [
      {
        color: "#CECE00",
        fields: [
          {
            title: "通知内容",
            value: "ギフトの申請がありました。確認して発送作業をお願いします。",
          },
          {
            title: "ギフトID",
            value: `${giftId}`,
          },
          {
            title: "実行環境",
            value: `${environment()}`,
          },
        ],
      },
    ],
  };
};
