import { developDomain, getIsProd, productDomain } from "./util";

export const getToUser = (name: string | undefined) => {
  let toUser = "親愛なるユーザへ";
  if (name === undefined) {
    toUser = "親愛なるユーザへ";
  } else {
    toUser = name + "様へ";
  }
  return toUser;
};

export const registerMailBody = (name: string | undefined) => {
  const myPagePath = "/myPage/home";
  const jobsPagePath = "/jobs";
  const myPageUrl = (getIsProd() ? productDomain : developDomain) + myPagePath;
  const jobsPageUrl =
    (getIsProd() ? productDomain : developDomain) + jobsPagePath;

  return `
  ${getToUser(name)}
  この度はスキ街にご登録いただきまして、誠にありがとうございます。
  
  マイページからユーザ情報をご登録ください！
  ${myPageUrl}
  
  依頼一覧から他のユーザの依頼を確認できます！
  ${jobsPageUrl}
  
  
  スキ街
  `;
};

export const appliedMailBodyToClient = (application: any) => {
  const myPageJobDetailPagePath = "/myPage/jobDetail/" + application.jobRef.id;
  const myPageJobDetailPageUrl =
    (getIsProd() ? productDomain : developDomain) + myPageJobDetailPagePath;

  return `
  ${getToUser(application.clientName)}
    
  ${application.clientName} 様の依頼 ${application.jobTitle} へ ${
    application.applicantName
  } 様から応募がありました。
  
  応募を承諾する場合はマイページの依頼詳細ページから承諾をお願いします。
  ${myPageJobDetailPageUrl}
      
  スキ街
  `;
};

export const appliedMailBodyToApplicant = (application: any) => {
  const jobDetailPagePath = "/jobs/job_detail/" + application.jobRef.id;
  const jobDetailPageUrl =
    (getIsProd() ? productDomain : developDomain) + jobDetailPagePath;

  return `
  ${getToUser(application.applicantName)}

  ${application.clientName} 様の依頼 ${
    application.jobTitle
  } への応募が完了しました。
  
  応募の結果はメールで通知いたしますので、ご確認ください！
  いつもスキ街をご利用いただきありがとうございます！
  
  ジョブ詳細ページから応募の状況をご確認ください！
  ${jobDetailPageUrl}
  
  スキ街
  `;
};

export const applicationAcceptedMailBodyToClient = (application: any) => {
  const myPageJobDetailPagePath = "/myPage/jobDetail/" + application.jobRef.id;
  const myPageJobDetailPageUrl =
    (getIsProd() ? productDomain : developDomain) + myPageJobDetailPagePath;
  return `
  ${getToUser(application.clientName)}
      
  ${application.clientName} 様の依頼 ${application.jobTitle} への ${
    application.applicantName
  } 様からの応募を承諾いたしました。

  依頼の詳細ページはこちら
  ${myPageJobDetailPageUrl}
  
  スキ街内のチャットでやり取りを行なって、依頼が完了したら詳細ページから依頼完了ボタンをお願いします。
  
  これからもスキ街をよろしくお願いいたします。
        
  スキ街
  `;
};

export const applicationAcceptedMailBodyToApplicant = (application: any) => {
  return `
  ${getToUser(application.applicantName)}

  ${application.clientName} 様の依頼 ${
    application.jobTitle
  } への応募につきまして承認されました。

  スキ街内のチャットでやり取りを行なって、依頼の実行をお願いします。

  依頼完了後発注者が依頼完了ボタンを押すとスキ街ポイントが付与されます。
  
  これからもスキ街をよろしくお願いいたします。
      
  スキ街
  `;
};

export const applicationRejectedMailBodyToClient = (application: any) => {
  return `
  ${getToUser(application.clientName)}
      
  ${application.clientName} 様の依頼 ${application.jobTitle} への ${
    application.applicantName
  } 様からの応募をお見送りとしました。
  
  これからもスキ街をよろしくお願いいたします。
        
  スキ街
  `;
};

export const applicationRejectedMailBodyToApplicant = (application: any) => {
  return `
  ${getToUser(application.applicantName)}

  ${application.clientName} 様の依頼 ${
    application.jobTitle
  } への応募につきましてお見送りとなりました。
  
  これからもスキ街をよろしくお願いいたします。
      
  スキ街
      `;
};

export const applicationDoneMailBodyToApplicant = (application: any) => {
  const giftPagePath = "/gift";
  const giftPageUrl =
    (getIsProd() ? productDomain : developDomain) + giftPagePath;
  return `
  ${getToUser(application.applicantName)}

  ${application.clientName} 様の依頼 ${application.jobTitle} を完了されました。
  
  スキ街ポイントが${application.jobPrice}ptが付与されます。
  スキ街ポイントはマイページのギフト一覧ページからお好きなギフトと交換可能です。

  ギフト一覧ページ
  ${giftPageUrl}

      
  いつも、スキ街のご利用ありがとうございます！

  これからもスキ街をよろしくお願いいたします。
      
  スキ街
  `;
};

export const applicationDoneMailBodyToClient = (application: any) => {
  return `
  ${getToUser(application.clientName)}

  ${application.clientName} 様の依頼 ${application.jobTitle} の ${
    application.applicantName
  } 様との契約を完了とし、${
    application.applicantName
  } 様にスキ街ポイントを付与いたしました。

  いつも、スキ街のご利用ありがとうございます！

  これからもスキ街をよろしくお願いいたします。
      
  スキ街
  `;
};

export const giftRequestPassedMailBody = (giftRequest: any, user: any) => {
  const giftTitle = getGiftTitle(giftRequest.type);
  return `
${getToUser(user.userName)}

${giftTitle} の申請を承りました。ギフトの発送までは数日かかることもございます。
本ギフト申請で利用したスキ街ポイントは${giftRequest.point}ptです。

1週間ほど経過してもギフト発送メールが届かない場合は、大変お手数おかけしますが本メールアドレス宛にご連絡いただきますようお願いいたします。

これからもスキ街をよろしくお願いいたします。

スキ街
  `;
};

export const giftRequestInsufficientMailBody = (
  giftRequest: any,
  user: any
) => {
  const giftTitle = getGiftTitle(giftRequest.type);
  return `
${getToUser(user.userName)}

${giftTitle} の申請をいただきましたがスキ街ポイントが不足していたため、今回のギフト申請は承諾されませんでした。
大変恐れ入りますがサイトに表示されているポイントと実際のポイントにずれが生じている可能性があります。
サイトのページを更新してもポイントのずれが解消されない場合は、こちらのメールにご返信いただけば幸いです。
運営の方でポイントの詳細についてお調べいたします。

これからもスキ街をよろしくお願いいたします。

スキ街
  `;
};

export const sentAmazonGiftMailBody = (giftRequest: any, user: any) => {
  const giftTitle = getGiftTitle(giftRequest.type);
  return `
${getToUser(user.userName)}

申請いただいておりました ${giftTitle} のギフトの発送をいたしました。
Amazonギフト券はご登録されておりますメールアドレスに送信されたコードからご利用いただけます。

これからもスキ街をよろしくお願いいたします。

スキ街
  `;
};

export const getGiftTitle = (giftType: string) => {
  switch (giftType) {
    case "AMAZON_GIFT_1000":
      return "Amazonギフト券1000円分";
    case "AMAZON_GIFT_3000":
      return "Amazonギフト券3000円分";
    case "AMAZON_GIFT_5000":
      return "Amazonギフト券5000円分";
    default:
      // 不明なGiftTypeの場合
      return "";
  }
};

export const successDeleteAccountMailBody = (user: any) => {
  return `
  ${getToUser(user.userName)}

  退会が完了しました。

  今までスキ街のご利用ありがとうございました。

  またいつでもスキ街を覗きにきてください！
  より良い街づくりを進めながら、またのお越しをお待ちしております！

  スキ街
  `;
};

export const failureDeleteAccountMailBody = (user: any) => {
  return `
  ${getToUser(user.userName)}

  なんらかの理由でスキ街の退会に失敗しました。大変申し訳ございません。
  運営の方で原因を調査いたします。

  原因が判明し次第、ご連絡差し上げます。
  
  こちらのメールを受け取って3日ほど経過しても連絡がない場合は大変お手数をおかけしますが、スキ街のお問合せページからお問い合わせをお願いします。

  スキ街
  `;
};
