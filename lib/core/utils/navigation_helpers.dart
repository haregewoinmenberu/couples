import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension SafeNavigation on BuildContext {
  /// Pop only when there is somewhere to go back to; otherwise return home.
  void safePop({String fallback = '/home'}) {
    final router = GoRouter.of(this);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(fallback);
    }
  }
}
