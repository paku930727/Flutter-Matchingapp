import 'package:flutter/material.dart';
import '../../constants.dart';

class HeaderContainer extends StatelessWidget {
  const HeaderContainer({
    Key? key,
    required this.content,
  }) : super(key: key);

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: kPrimaryColor,
      padding: const EdgeInsets.all(8.0),
      child: content,
    );
  }
}
