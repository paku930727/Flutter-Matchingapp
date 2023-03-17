import 'package:flutter/material.dart';

/// urlから丸い画像表示を行うウィジェット
class CircleImage extends StatelessWidget {
  const CircleImage({Key? key, required this.assetPath, required this.url})
      : super(key: key);
  final String assetPath;
  final String? url;
  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Image.asset(assetPath);
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
    );
  }
}
