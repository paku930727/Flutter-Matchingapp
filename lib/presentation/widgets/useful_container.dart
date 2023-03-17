import 'package:flutter/material.dart';

/// 一覧表示に用いる基本的カード
class UsefulContainer extends StatelessWidget {
  const UsefulContainer(
      {Key? key,
      this.center,
      this.leading,
      this.title,
      this.trailing,
      this.number,
      this.contents,
      this.onTap,
      this.height})
      : super(key: key);

  final Widget? center;
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final Widget? contents;
  final double? height;
  final int? number;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.green),
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                title ?? const SizedBox(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    leading ?? const SizedBox(),
                    center ?? const SizedBox(),
                    trailing ?? const SizedBox(),
                  ],
                ),
                const SizedBox(height: 10),
                contents ?? const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget dummy({height = 180}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.green),
        ),
      ),
    );
  }
}
