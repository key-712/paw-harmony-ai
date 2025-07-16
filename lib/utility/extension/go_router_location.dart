import 'package:go_router/go_router.dart';

/// GoRouterクラスの拡張関数定義
extension GoRouterLocation on GoRouter {
  /// 現在表示中の画面のURIを取得します
  String get location {
    if (routerDelegate.currentConfiguration.isEmpty) {
      return '';
    }
    final lastMatch = routerDelegate.currentConfiguration.last;
    final matchList =
        lastMatch is ImperativeRouteMatch
            ? lastMatch.matches
            : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
