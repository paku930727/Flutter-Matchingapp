import 'package:flutter/material.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/widgets/circle_image.dart';

/// firebaseのstoragePathから丸い形でプロフィール画像を表示するウィジェット
class CircleProfileImg extends StatelessWidget {
  const CircleProfileImg(
      {Key? key,
      required this.photoUrl,
      required this.pickedImg,
      required this.radius,
      this.onTapAction})
      : super(key: key);

  /// アイコン画像URL
  final String? photoUrl;

  /// PickedImageで選択した画像
  final Image? pickedImg;

  /// アイコン画像の円周サイズ
  final double radius;

  /// 画像をタップした時のアクション
  final Function? onTapAction;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (onTapAction != null) await onTapAction!();
      },
      child: Container(
        //constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        height: radius,
        width: radius,
        child: pickedImg != null
            ? FittedBox(
                fit: BoxFit.cover,
                child: pickedImg,
              )
            : CircleImage(assetPath: kIconImagePath, url: photoUrl),
      ),
    );
  }
}
