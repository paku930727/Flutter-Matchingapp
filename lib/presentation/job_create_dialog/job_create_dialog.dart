import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/job_create_dialog/job_create_model.dart';
import 'package:sukimachi/presentation/my_page/my_page_model.dart';
import 'package:sukimachi/presentation/widgets/custom_text_field_dialog.dart';
import 'package:sukimachi/presentation/widgets/show_dialog.dart';
import 'package:sukimachi/validator/validators.dart';

/// 依頼登録のダイアログウィジェット
///
/// Viewのページに書くと、notifyListnerによってダイアログ内の画面更新がされないため、
/// ウィジェットを分けて対処した。
class JobCreateDialog extends ConsumerWidget {
  const JobCreateDialog({this.jobId, Key? key}) : super(key: key);

  final String? jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPageState = ref.watch(myPageProvider);
    final jobCreateState = ref.watch(jobCreateProvider(jobId));

    Future<void> _selectApplicationDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
          context: context,
          // applicationDeadlineが今日より前の日付の場合、エラーが発生するため
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 5));
      if (picked != null && picked != jobCreateState.applicationDeadline) {
        jobCreateState.setApplicationDeadLine(picked);
      }
    }

    Future<void> _selectDeliveryDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
          context: context,
          // deliveryDeadlineが今日より前の日付の場合、エラーが発生するため
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 5));
      if (picked != null && picked != jobCreateState.deliveryDeadline) {
        jobCreateState.setDeliveryDeadLine(picked);
      }
    }

    /// dialogのbody
    /// jobIdを取得中は,Indicatorを表示する
    if (jobCreateState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return CustomTextFieldDialog(
        title: '新しく依頼を作成する',
        cancelActionText: 'キャンセル',
        defaultActionText: 'OK',
        action: () async {
          await jobCreateState.createJob(showTextDialog: (String title) async {
            await showTextDialog(context, title: title);
          }, showConfirmDialog: (String title) async {
            await showConfirmDialog(
                context: context,
                title: title,
                message: "依頼はまだ未公開です。詳細画面から公開することでお仕事一覧に掲載されます\n依頼一覧を開きますか？",
                okText: "遷移する。",
                function: () {
                  context.go(kMyPageClientJobsPath);
                });
          });
          await myPageState.fetchMyClientJobs();
          await myPageState.fetchMyUser();
        },
        contentWidget: SingleChildScrollView(
          child: SizedBox(
            //Todo 横幅調整
            width: 620,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  /// 依頼タイトル入力フォーム
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('依頼タイトル'),
                      const SizedBox(height: 6),
                      // 依頼タイトルのテキストフォーム
                      TextFormField(
                        controller: jobCreateState.jobTitleController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: jobTitleValidator(),
                        decoration: const InputDecoration(
                            hintText: 'スキ街の依頼募集',
                            errorMaxLines: 3,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// 依頼カテゴリ選択フォーム
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('依頼カテゴリ'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField2(
                        decoration: const InputDecoration(
                          isDense: true,
                          errorMaxLines: 3,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        iconSize: 30,
                        buttonHeight: 65,
                        buttonPadding:
                            const EdgeInsets.only(left: 20, right: 10),
                        hint: const Text("カテゴリーを選択してください"),
                        items: jobCreateState.categoryDropdownItems,
                        validator: (value) {
                          if (value == null) {
                            return '依頼のカテゴリーを選択してください';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          jobCreateState.changeJobCategory(
                              selectCategory: value as String);
                        },
                        value: jobCreateState.jobCategory,
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// 依頼金額の入力フォーム
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('依頼金額'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: jobCreateState.jobPriceController,
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.rtl,
                              textInputAction: TextInputAction.next,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: jobPriceValidator(),
                              decoration: const InputDecoration(
                                  hintText: '100000',
                                  errorMaxLines: 3,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black26),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.lightBlue),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  )),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('円'),
                        ],
                      ),
                    ],
                  ),
                  // Jobの依頼金額
                  const SizedBox(height: 30),

                  // Jobの詳細入力フォーム
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('依頼の詳細'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: jobCreateState.jobDetailController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: '受注者に伝わるように詳細をご記入ください。(複数行の入力可能です)',
                          errorMaxLines: 3,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// 募集期限の入力フォーム
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('募集期限'),
                      const SizedBox(height: 6),
                      TextFormField(
                        readOnly: true,
                        controller:
                            jobCreateState.applicationDeadlineController,
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _selectApplicationDate(context);
                        },
                        validator: applicationDeadlineValidator(),
                        decoration: const InputDecoration(
                            hintText: '2022/10/01',
                            errorMaxLines: 3,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// 納品日の入力フォーム
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('納品日'),
                      const SizedBox(height: 6),
                      TextFormField(
                        readOnly: true,
                        controller: jobCreateState.deliveryDeadlineController,
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _selectDeliveryDate(context);
                        },
                        validator: deliveryDeadlineValidator(
                            jobCreateState.applicationDeadlineController.text),
                        decoration: const InputDecoration(
                            hintText: '2022/12/01',
                            errorMaxLines: 3,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
