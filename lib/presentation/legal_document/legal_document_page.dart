import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/presentation/legal_document/privacy_poricy.dart';
import 'package:sukimachi/presentation/legal_document/terms_of_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../default/default_page.dart';

class LegalDocumentPage extends ConsumerWidget {
  const LegalDocumentPage(this.contentsId, {Key? key}) : super(key: key);
  final String contentsId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String getSource() {
      switch (contentsId) {
        case "privacy_policy":
          return privacyPolicyHtml;
        case "term_of_service":
          return termsOfServiceHtml;
        default:
          return "ページが見つかりません。";
      }
    }

    return DefaultPage(
      bodyWidget: Html(
        data: getSource(),
        onLinkTap: (
          url,
          context,
          attributes,
          element,
        ) {
          if (url == null) return;
          launchUrlString(url);
        },
      ),
      pageName: "legal",
    );
  }
}
