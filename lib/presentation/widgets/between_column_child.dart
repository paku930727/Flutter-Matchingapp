import 'package:flutter/cupertino.dart';

class BetweenColumnChild extends StatelessWidget {
  const BetweenColumnChild({Key? key, this.isStart = true, required this.child})
      : super(key: key);
  final bool isStart;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
