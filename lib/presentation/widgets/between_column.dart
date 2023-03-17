import 'package:flutter/widgets.dart';
import 'package:sukimachi/presentation/widgets/between_column_child.dart';

class BetweenColumn extends StatelessWidget {
  const BetweenColumn({Key? key, required this.children}) : super(key: key);

  final List<BetweenColumnChild> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children
          .map((child) => Align(
              alignment: child.isStart ? Alignment.topLeft : Alignment.topRight,
              child: child))
          .toList(),
    );
  }
}
