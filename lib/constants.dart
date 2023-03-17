import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFe1eaf1); //primary color of our website
const kSecondaryColor = Color.fromRGBO(254, 87, 34, 1); //secondary color
const kGreyColor = Colors.grey;
const kErrorColor = Color.fromRGBO(253, 245, 230, 1);
const kMaxWidth = 1232.0;
const kPadding = 20.0;
const kThreeDivideWidth = 380.0;

//PageName
const kHomePageName = "home";
const kJobsPageName = "jobs";
const kProfilePageName = "profile";
const kJobDetailPageName = "job_detail";
const kMyPageName = "myPage";
const kMyPageJobDetailName = "my_page_job_detail";
const kGiftPageName = "gift";
const kContactName = "contact";
const kContactSuccessName = "contact_success";
const kLegalDocumentName = "legal_documents";
const kPrivacyPolicyName = "privacy_policy";
const kTermOfServiceUrlName = "term_of_service";

//PagePath
const kHomePagePath = "/";
const kJobsPagePath = "/jobs";
const kJobDetailPagePath = "/jobs/job_detail/:id";
const kProfilePagePath = "/profile/:id";
const kMyPagePath = "/myPage/:myPageId";
const kMyPageJobDetailPath = "/myPage/jobDetail/:id";
const kGiftPagePath = "/gift";
const kMyPageHomeTabId = "home";
const kMyPageHomePath = "/myPage/" + kMyPageHomeTabId;
const kMyPageClientJobsTabId = "clientJobs";
const kMyPageClientJobsPath = "/myPage/" + kMyPageClientJobsTabId;
const kMyPageApplicationPageTabId = "applications";
const kMyPageReceivedJobsPath = "/myPage/" + kMyPageApplicationPageTabId;
const kContactPath = "/contact";
const kContactSuccessPath = "/contact_success";
const kLegalDocumentPath = "/documents/:contentsId";

//ImagePath
const kIconImagePath = "assets/images/sukimachi_icon.png";
const kTwitterIconImagePath = "assets/icons/twitter.png";

//文言
const kTopPageCatchCopy1 = "新しい形の";
const kTopPageCatchCopy2 = "副業マッチングサービス！";
const kTopPageServiceDetail1 =
    "お仕事を受けたい人は掲載されたお仕事を受注します！お仕事が完了したらスキ街ポイントをゲット   ";
const kTopPageServiceDetail2 = "スキ街ポイントはサイト内からギフトと交換できます";

/// firestoreのコレクション名
const kUsers = 'users';
const kJobs = 'jobs';
const kClientJobs = 'clientJobs';
const kApplications = 'applications';
const kGiftRequest = 'giftRequests';
const kSecretProfile = 'secretProfiles';
const kContact = 'contact';

/// 応募のステータス
const kApplicationStatusInReview = 'IN_REVIEW';
const kApplicationStatusInReviewView = '応募中';
const kApplicationStatusAccepted = 'ACCEPTED';
const kApplicationStatusAcceptedView = '契約中';
const kApplicationStatusRejected = 'REJECTED';
const kApplicationStatusRejectedView = '落選';
const kApplicationStatusDone = 'DONE';
const kApplicationStatusDoneView = '完了';

/// 依頼のステータス
const kJobStatus = 'jobStatus';
const kJobStatusPrivate = 'PRIVATE';
const kJobStatusPrivateView = "未公開";
const kJobStatusPublic = 'PUBLIC';
const kJobStatusPublicView = "公開中";
const kJobStatusClosed = 'CLOSED';
const kJobStatusClosedView = "公開終了";
const kJobStatusUnknownView = "状態不明";

/// ギフトタイプ
const kGiftTypeAmazon1000 = 'AMAZON_GIFT_1000';
const kGiftTypeAmazon3000 = 'AMAZON_GIFT_3000';
const kGiftTypeAmazon5000 = 'AMAZON_GIFT_5000';

const kGiftStatusInReview = 'IN_REVIEW';
const kGiftStatusPassed = 'PASSED';
const kGiftStatusInsufficient = 'INSUFFICIENT';
const kGiftStatusDone = 'DONE';

const kGiftPointAmazon1000 = 1500;
const kGiftPointAmazon3000 = 3600;
const kGiftPointAmazon5000 = 5800;

const kGiftTitleAmazon1000 = "Amazonギフト券1000円分";
const kGiftTitleAmazon3000 = "Amazonギフト券3000円分";
const kGiftTitleAmazon5000 = "Amazonギフト券5000円分";

const kGiftDetailAmazon1000 =
    "登録されているGoogleAccountのメールアドレスにAmazonギフト券1000円分をお送りします。";
const kGiftDetailAmazon3000 =
    "登録されているGoogleAccountのメールアドレスにAmazonギフト券3000円分をお送りします。";
const kGiftDetailAmazon5000 =
    "登録されているGoogleAccountのメールアドレスにAmazonギフト券5000円分をお送りします。";

//決まった数字
const kCommentLoadLimit = 4;

///SnsUrlListFormのキー名,key名打ち間違えをしないようにするために定義
// snsName,snsListFormの1番目のKey名
const String snsName = "snsName";
// snsAddress,snsListFormの2番目のKey名
const String snsAddress = "address";

const List<String> requiredLoginPages = [
  kGiftPagePath,
];

//SNSのリスト
enum SnsList {
  twitter,
  //facebook,
  instagram,
  //github,
  other,
  non,
}

/// スクリーンのタイプを判別するEnum
/// レスポンシブ対応を行うため
enum ScreenType { desktop, tablet, mobile }

// 利用規約のURL
const termsOfServiceUrl =
    "https://www.kiyac.app/termsOfService/OTi5jzNlqUvZl0JIoiie";
// プライバシーポリシーのURL
const privacyPolicyUrl = "https://kiyac.app/privacypolicy/IfQbZsjE80j3WRvdEwFH";
// 公式TwitterのURL
const twitterUrl = "https://twitter.com/suki_machi";

// プレリリースの紹介スライドのURL
const preReleaseSlideUrl =
    "https://docs.google.com/presentation/d/1G7DKt9Z0p3hFNANqd30wNu5EPXivzMl6fSUxvvhv_MU/edit?usp=sharing";

// プレリリースの公式からの依頼のid
const officialJobIds = [
  // 開発環境
  'kpNcMecz8tPMilgJ7B7M',
  'DHovzZffqFViEvpfHpAj',
  'E6hyOVSqzIO9r6NX3yVO',
  // 本番環境
  'pEAxntuhOSsRONU0zO9Q',
  '6K5BYC3dne2W08B85y5O',
  'G1WTVwv84F2kiHukjFey',
];
