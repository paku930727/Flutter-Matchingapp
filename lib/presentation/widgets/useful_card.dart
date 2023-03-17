import 'package:flutter/material.dart';

/// 一覧表示に用いる基本的カード
class UsefulCard extends StatelessWidget {
  const UsefulCard(
      {Key? key,
      this.center,
      this.title,
      this.number,
      this.contents,
      this.onTap,
      this.height})
      : super(key: key);

  final Widget? center;
  final Widget? title;
  final Widget? contents;
  final double? height;
  final int? number;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                title ?? const SizedBox(),
                center ?? const SizedBox(),
                contents ?? const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
