import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/default/body_container.dart';
import 'package:sukimachi/presentation/default/footer.dart';
import 'package:sukimachi/presentation/default/header.dart';
import 'package:sukimachi/presentation/default/header_container.dart';
import 'package:sukimachi/presentation/home/components/menu.dart';
import 'package:sukimachi/presentation/home/error_message/error_message_widget.dart';
import 'package:sukimachi/presentation/widgets/responsive.dart';

class DefaultPage extends ConsumerWidget {
  const DefaultPage(
      {Key? key,
      required this.bodyWidget,
      this.headerWidget,
      required this.pageName})
      : super(key: key);
  final Widget bodyWidget;
  final Widget? headerWidget;
  final String pageName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SelectionArea(
      child: Scaffold(
        /// Drawer
        drawer: Drawer(
          child: ListView(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const DrawerHeader(
                child: Center(
                  child: Text(
                    "スキ街",
                    style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w900,
                        color: kSecondaryColor),
                  ),
                ),
              ),
              const MobMenu()
            ],
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  /// Header
                  HeaderContainer(
                    content: Container(
                      padding: const EdgeInsets.all(kPadding),
                      constraints: const BoxConstraints(maxWidth: kMaxWidth),
                      child: Column(
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          const Header(),
                          headerWidget != null
                              ? Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    headerWidget!,
                                  ],
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ),
                  const ErrorMessageWidget(),
                  BodyContainer(
                    content: bodyWidget,
                  ),
                ],
              ),
            ),

            /// Footer
            if (!Responsive.isMobile(context))
              const SliverFillRemaining(
                hasScrollBody: false,
                child:
                    Align(alignment: Alignment.bottomCenter, child: Footer()),
              ),
          ],
        ),
      ),
    );
  }
}
