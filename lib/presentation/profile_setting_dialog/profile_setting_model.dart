import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/domain/user.dart';
import 'package:sukimachi/exception/user_null_exception.dart';
import 'package:sukimachi/extension/sns_list_extension.dart';
import 'package:sukimachi/log/logger.dart';
import 'package:sukimachi/repository/user_repository.dart';

final profileSettingProvider = ChangeNotifierProvider.autoDispose((ref) =>
    ProfileSettingModel._(userRepository: ref.watch(userRepositoryProvider)));

//Todo 未登録ならset,登録済みならupdateとする。
class ProfileSettingModel extends ChangeNotifier {
  ProfileSettingModel._({required this.userRepository}) {
    checkRegisteredUserInfo();
  }

  /// userRepository,DIで挿入
  final UserRepository userRepository;

  /// FirebaseAuth
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  /// 現在のfirebase_authのuid
  late String uid;

  /// 現在のユーザー情報
  User? currentUser;

  /// ユーザーの性別
  int sex = 9;

  /// firebaseStorageに格納されているプロフィール画像のパス
  String? userImagePath;

  /// プロフィール画像のURL
  // String? userImageUrl;

  /// ImagePickerで選択した画像をByte表記にしたもの
  Uint8List? pickedImgBytes;

  /// ImagePickerで選択した画像
  Image? pickedImg;

  /// ローディング中の場合True
  bool isLoading = false;

  /// ユーザー名のTextEditingController
  TextEditingController userNameController = TextEditingController();

  /// 依頼者への一言のTextEditingController
  TextEditingController introForClientController = TextEditingController();

  /// 受注者への一言のTextEditingController
  TextEditingController introForContractorController = TextEditingController();

  /// SNSのURLリスト
  List<Map<String, dynamic>> snsUrlFormList = [
    {
      snsName: null,
      snsAddress: TextEditingController(),
    }
  ];

  /// ユーザーが登録するSNSの数,必ず1以上の数字
  int snsCount = 1;

  @override
  void dispose() {
    userNameController.dispose();
    introForClientController.dispose();
    introForContractorController.dispose();
    notifyListeners();
    super.dispose();
  }

  /// ユーザー登録が済んでいるか確認するメソッド
  ///
  /// ユーザー登録済の場合は、hasUser = true
  /// ユーザー登録されていない場合は、UserNullExceptionが発生する。
  Future<void> checkRegisteredUserInfo() async {
    uid = _auth.currentUser!.uid;
    try {
      currentUser = await userRepository.fetchCurrentUserCache();
    } on UserNullException catch (e, st) {
      logger.fine(e);
      logger.fine(st);
    } catch (e, st) {
      logger.severe(e);
      logger.severe(st);
    } finally {
      if (currentUser != null) {
        _setUserInfo(currentUser!);
      } else {
        _setInitUserInfo();
      }
      notifyListeners();
    }
  }

  /// ユーザー情報を取得する。
  Future<void> fetchUser(String id) async {
    try {
      currentUser = await userRepository.fetchCurrentUserCache();
    } on UserNullException catch (e, st) {
      logger.fine(e);
      logger.fine(st);
    } catch (e, st) {
      logger.warning(e);
      logger.warning(st);
    } finally {
      notifyListeners();
    }
  }

  /// プロフィール入力をキャンセルした際のアクション
  void cancel() {}

  /// ダイアログでアクションを押した際のロジック
  Future<String> sendAction() async {
    try {
      if (currentUser != null) {
        await updateProfile();
        return "プロフィールを更新しました。";
      } else {
        await resisterMyProfile();
        return "プロフィールを登録しました。";
      }
    } catch (e) {
      return "プロフィールの登録に失敗しました。\n お手数ですがもう一度お試しください。";
    }
  }

  /// ユーザー情報登録
  Future<void> resisterMyProfile() async {
    try {
      final uid = _auth.currentUser!.uid;
      userRepository.resisterMyProfile(
        uid: uid,
        userName: userNameController.text,
        sex: sex,
        introduceForClient: introForClientController.text,
        introduceForContractor: introForContractorController.text,
        snsUrlList: _convertToSnsUrlDbData(snsUrlFormList),
        profileImgBytes: pickedImgBytes,
      );
    } catch (e, st) {
      logger.severe(e);
      logger.severe(st);
      rethrow;
    }
  }

  /// プロフィール更新時のアクション
  Future<void> updateProfile() async {
    try {
      logger.config(pickedImgBytes);
      userRepository.updateProfile(
          data: _updateData(),
          userRef: currentUser!.userRef,
          profileImgBytes: pickedImgBytes);
    } catch (e, st) {
      logger.warning(e);
      logger.warning(st);
      rethrow;
    }
  }

  /// firestoreへ送信するUserデータ
  User _updateData() {
    return currentUser!.copyWith(
      userName: userNameController.text,
      sex: sex,
      introduceForClient: introForClientController.text,
      introduceForContractor: introForContractorController.text,
      updatedAt: Timestamp.now(),
      snsUrlList: _convertToSnsUrlDbData(snsUrlFormList),
    );
  }

  /// 入力フォームと関連する変数にUser情報を格納する.
  void _setUserInfo(User currentUser) {
    userNameController.text = currentUser.userName;
    introForClientController.text = currentUser.introduceForClient ?? '';
    introForContractorController.text =
        currentUser.introduceForContractor ?? '';
    snsUrlFormList = _convertToSnsUrlForm(currentUser.snsUrlList);
    sex = currentUser.sex;
    snsCount =
        currentUser.snsUrlList == null ? 1 : currentUser.snsUrlList!.length;
  }

  /// ユーザー情報がデータベースに登録されていない場合のフィールドセット
  void _setInitUserInfo() {
    userNameController.text = "";
    introForContractorController.text = "";
    introForClientController.text = "";
    snsUrlFormList = [
      {
        "snsName": null,
        "address": TextEditingController(),
      },
    ];
    snsCount = 1;
  }

  /// 性別の切り替え
  void changeSex(int value) {
    sex = value;
    notifyListeners();
  }

  /// [index]番目のsnsUrlListFormの"snsName"を変更する
  void changeSnsName(int index, Object? value) {
    snsUrlFormList[index][snsName] = value;
    notifyListeners();
  }

  /// SnsUrlListFormで1行追加時の処理
  void addSnsUrlListForm() {
    snsUrlFormList.add({
      snsName: null,
      snsAddress: TextEditingController(),
    });
    snsCount += 1;
    notifyListeners();
  }

  /// SnsUrlListFormで[index]番目の内容を削除する処理
  void deleteSnsComponent(int index) {
    if (snsCount > 1) {
      snsUrlFormList.removeAt(index);
      snsCount -= 1;
    } else {
      // snsCountが1の時
      snsUrlFormList = [
        {snsName: null, snsAddress: TextEditingController()}
      ];
    }
    notifyListeners();
  }

  /// firestoreのsnsUrlListのMapから、EditDialogのフォームで利用できる形[snsUrlFormList]に変換
  ///
  /// [{'snsName':'Instagram', 'address': 'https://instagram.com},{'snsName':'Github', 'address': 'https://github.com'}]
  /// のような形が返却される。
  List<Map<String, dynamic>> _convertToSnsUrlForm(
      Map<String, dynamic>? snsUrlDbData) {
    List<Map<String, dynamic>> _snsUrlFormList = [];
    if (snsUrlDbData == null) {
      _snsUrlFormList.add({
        snsName: null,
        snsAddress: TextEditingController(),
      });
    } else {
      snsUrlDbData.forEach((key, value) {
        dynamic snsNameForm = key.toEnumSnsList();
        dynamic snsAddressForm = TextEditingController(text: value.toString());
        final snsUrlForm = {snsName: snsNameForm, snsAddress: snsAddressForm};
        _snsUrlFormList.add(snsUrlForm);
      });
    }
    return _snsUrlFormList;
  }

  /// [snsUrlListForm]をfirestoreで登録する形に変換
  ///
  /// {'instagram':'https://instagram.com',} のような形にする。
  Map<String, dynamic>? _convertToSnsUrlDbData(
      List<Map<String, dynamic>> snsUrlFormList) {
    Map<String, dynamic> snsUrlList = {};
    for (Map<String, dynamic> snsUrlForm in snsUrlFormList) {
      if (snsUrlForm[snsName] == null || snsUrlForm[snsName] == SnsList.non) {
        // もし、snsが入力されていない場合はnullを返却
        return null;
      } else {
        SnsList name = snsUrlForm[snsName];
        TextEditingController address = snsUrlForm[snsAddress];
        final snsUrl = {name.toSnsString: address.text};
        snsUrlList.addEntries(snsUrl.entries);
      }
    }
    return snsUrlList;
  }

  /// プロフィール画像をタップした際のアクション
  Future<void> onTapProfileUrl() async {
    try {
      // 画像をバイト配列で、受け取る。
      // これによって、Fileパスを覚えておく必要がないため、画像データを保持することが可能となる。
      pickedImgBytes = await ImagePickerWeb.getImageAsBytes();
      pickedImg = Image.memory(pickedImgBytes!);
    } on Exception catch (e, st) {
      logger.severe(e);
      logger.severe(st);
    }
    notifyListeners();
  }

  /// ImagePickerで取得した画像ウィジェットをnullに変更する。
  /// ダイアログが閉じる際に行う。
  void resetPickedImg() async {
    pickedImg = null;
    pickedImgBytes = null;
  }
}
