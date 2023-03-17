library go_router;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sukimachi/constants.dart';
import 'package:sukimachi/presentation/widgets/show_dialog.dart';

extension GoRouterHelper on BuildContext {
  bool _checkNeedLogin(String location) {
    return requiredLoginPages.contains(location) ||
        location.startsWith('/myPage');
  }

  bool _getShowDialog(String location, bool isSignIn) {
    return _checkNeedLogin(location) && !isSignIn;
  }

  Future go(String location, bool isSignIn, {Object? extra}) async {
    if (_getShowDialog(location, isSignIn)) {
      await showLoginDialog(this);
      if (!isSignIn) {
        return;
      }
    }
    GoRouter.of(this).go(location, extra: extra);
  }

  Future push(String location, bool isSignIn, {Object? extra}) async {
    if (_getShowDialog(location, isSignIn)) {
      await showLoginDialog(this);
      if (!isSignIn) {
        return;
      }
    }
    GoRouter.of(this).push(location, extra: extra);
  }

  void pop() => GoRouter.of(this).pop();
}
