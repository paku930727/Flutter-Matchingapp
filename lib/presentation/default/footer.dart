import 'package:flutter/material.dart';
import 'package:sukimachi/presentation/home/components/menu.dart';
import '../../constants.dart';

class Footer extends StatelessWidget {
  const Footer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kPadding / 2),
      color: kPrimaryColor,
      child: const MobFooterMenu(),
    );
  }
}
