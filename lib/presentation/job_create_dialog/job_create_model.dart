import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/category.dart';
import 'package:sukimachi/domain/job.dart';
import 'package:sukimachi/domain/user.dart';
import 'package:sukimachi/log/logger.dart';
import 'package:sukimachi/repository/category_repository.dart';
import 'package:sukimachi/repository/job_repository.dart';
import 'package:intl/intl.dart';

import '../../repository/user_repository.dart';

final jobCreateProvider = ChangeNotifierProvider.autoDispose
    .family((ref, String? jobId) => JobCreateModel._(
          jobRepository: JobRepository.instance,
          userRepository: ref.watch(userRepositoryProvider),
          categoryRepository: CategoryRepository.instance,
          jobId: jobId,
        ));

/// ユーザー情報登録時のダイアログを状態管理するViewModel
class JobCreateModel extends ChangeNotifier {
  JobCreateModel._({
    required this.jobRepository,
    required this.userRepository,
    required this.categoryRepository,
    this.jobId,
  }) {
    initialize();
  }

  /// jobRepository,DIで挿入
  final JobRepository jobRepository;

  /// userRepository,DIで挿入
  final UserRepository userRepository;

  /// categoryRepository,DIで挿入
  final CategoryRepository categoryRepository;

  /// jobId,編集の場合に指定しているJobのId
  final String? jobId;

  /// FirebaseAuth
  //final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  /// ローディング状態を表す,[isLoading] = trueなら、Indicatorを表示する。
  bool isLoading = false;

  /// 依頼タイトルのTextEditingController
  TextEditingController jobTitleController = TextEditingController();

  /// 依頼詳細のTextEditingController
  TextEditingController jobDetailController = TextEditingController();

  /// 依頼のカテゴリ
  late String jobCategory;

  /// 依頼金額
  TextEditingController jobPriceController = TextEditingController();

  /// 応募期限
  DateTime applicationDeadline = DateTime.now();

  /// 応募期限のTextEditingController
  TextEditingController applicationDeadlineController = TextEditingController();

  /// 依頼納品日
  DateTime deliveryDeadline = DateTime.now();

  /// 依頼納品日のTextEditingController
  TextEditingController deliveryDeadlineController = TextEditingController();

  /// 日付のFormat
  DateFormat formattedDate = DateFormat('yyyy/MM/dd');

  /// カテゴリー一覧
  List<Category> categories = [];

  /// カテゴリーのドロップダウンリスト
  List<DropdownMenuItem<String>> categoryDropdownItems = [];

  /// 現在のユーザー情報
  User? currentUser;

  /// jobのstatus, 更新する際に必要な値
  String jobStatus = kJobStatusPrivate;

  /// jobのcreatedAt, 更新する際に必要な値
  DateTime jobCreatedAt = DateTime.now();

  /// 初期化
  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();
    await _fetchCategories();
    await _fetchCurrentUser();
    if (jobId != null) {
      await setJobByJobId(jobId: jobId!);
    }
    isLoading = false;
    notifyListeners();
  }

  /// 依頼登録
  Future<void> createJob({
    required Future Function(String title) showTextDialog,
    required Future Function(String title) showConfirmDialog,
  }) async {
    try {
      final jobPrice = _convertPriceToInt(jobPriceController.text);
      await jobRepository.createJob(
        userId: currentUser!.userRef.id,
        jobTitle: jobTitleController.text,
        jobDetail: jobDetailController.text,
        jobPrice: jobPrice,
        jobStatus: kJobStatusPrivate,
        applicationDeadline: applicationDeadline,
        deliveryDeadline: deliveryDeadline,
        jobCategory: jobCategory,
        clientRef: currentUser!.userRef,
        clientName: currentUser!.userName,
      );
      await showConfirmDialog("依頼の作成に成功しました。");
    } catch (e, st) {
      await showTextDialog("依頼の作成に失敗しました。");
      logger.severe(e);
      logger.severe(st);
    }
  }

  /// プライスの文字列を数字に変換する
  int _convertPriceToInt(String text) {
    try {
      return int.parse(text);
    } on FormatException catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      return 0;
    }
  }

  /// 現在のログインしているユーザー情報をセットする
  Future<void> _fetchCurrentUser() async {
    try {
      currentUser = await userRepository.fetchCurrentUserCache();
    } catch (e, st) {
      logger.severe(e);
      logger.severe(st);
    }
  }

  /// 選択したJobCategoryの変更
  void changeJobCategory({required String selectCategory}) {
    jobCategory = selectCategory;
    notifyListeners();
  }

  /// カテゴリーの取得
  Future<void> _fetchCategories() async {
    categories = await categoryRepository.fetchCategoryList();
    categoryDropdownItems = categories.map((category) {
      return DropdownMenuItem(
        child: Text(category.name),
        value: category.name,
      );
    }).toList();
    //Todo 最初の読み込み時にjobCategoryをnullにするかは要検討すること
    jobCategory = categories.first.name;
    notifyListeners();
  }

  /// 募集期限をセットする
  void setApplicationDeadLine(DateTime picked) {
    applicationDeadline = picked;
    applicationDeadlineController.text =
        formattedDate.format(applicationDeadline);
    notifyListeners();
  }

  /// 納品日をセットする
  void setDeliveryDeadLine(DateTime picked) {
    deliveryDeadline = picked;
    deliveryDeadlineController.text = formattedDate.format(deliveryDeadline);
    notifyListeners();
  }

  /// 編集したいJob情報をダイアログの変数にセットする
  Future<void> setJobByJobId({required String jobId}) async {
    try {
      final job = await _fetchMyJobById(jobId: jobId);
      jobTitleController.text = job.jobTitle;
      jobDetailController.text = job.jobDetail;
      jobCategory = job.jobCategory;
      jobPriceController.text = job.jobPrice.toString();
      applicationDeadline = job.applicationDeadline.toDate();
      applicationDeadlineController.text =
          formattedDate.format(applicationDeadline);
      deliveryDeadline = job.deliveryDeadline.toDate();
      deliveryDeadlineController.text = formattedDate.format(deliveryDeadline);
      jobStatus = job.jobStatus;
      jobCreatedAt = job.createdAt.toDate();
    } on Exception catch (e, st) {
      logger.severe(e);
      logger.severe(st);
    }
  }

  /// jobIdから自分のjobを取得する
  Future<Job> _fetchMyJobById({required String jobId}) async {
    try {
      logger.config(jobId);
      await _fetchCurrentUser();
      final job = await userRepository.fetchMyJobById(
          uid: currentUser!.userRef.id, jobId: jobId);
      return job;
    } catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      rethrow;
    }
  }
}
