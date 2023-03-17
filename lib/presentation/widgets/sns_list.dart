import 'package:flutter/cupertino.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SnsListWidget extends StatelessWidget {
  const SnsListWidget({Key? key, required this.snsUrlList}) : super(key: key);
  final Map<String, dynamic>? snsUrlList;

  @override
  Widget build(BuildContext context) {
    if (snsUrlList == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SNS一覧",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Column(
            children: snsUrlList!.keys
                .map((key) => Linkify(
                      onOpen: (link) async {
                        await launchUrlString(link.url);
                      },
                      text: "$key: ${snsUrlList![key]}",
                    ))
                .toList()),
      ],
    );
  }
}
