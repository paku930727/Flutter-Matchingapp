import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(
      {Key? key,
      required this.backgroundColor,
      this.textColor = Colors.black,
      required this.text})
      : super(key: key);
  final Color backgroundColor;
  final Color? textColor;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: backgroundColor),
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                color: textColor,
                height: 1.5,
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
