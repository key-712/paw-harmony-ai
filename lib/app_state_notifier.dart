import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/type.dart';
import '../import/utility.dart';

/// アプリ全体の状態管理対象データの更新通知を管理するプロバイダ
final AutoDisposeStateNotifierProvider<AppStateNotifier, void>
appStateNotifierProvider =
    StateNotifierProvider.autoDispose<AppStateNotifier, void>(
      AppStateNotifier.new,
    );

/// アプリ全体の状態管理対象データの変更を通知するクラス
class AppStateNotifier extends StateNotifier<void> {
  /// インスタンスを作成します
  AppStateNotifier(this._ref) : super(() {});

  final Ref _ref;

  /// 画面遷移ログ
  // ignore: omit_obvious_property_types
  TransitLog transitLog = TransitLog(from: '', to: '');

  /// 画面遷移を記録します
  Future<void> _logTransitScreen() async {
    final goRouter = _ref.read(goRouterProvider);
    transitLog = transitLog.copyWith(
      from: transitLog.to,
      to: goRouter.location,
    );
    await _ref
        .read(firebaseAnalyticsServiceProvider)
        .transitScreen(parameters: transitLog);
  }

  /// 画面遷移後の処理を行います
  Future<void> handleTransit({required BuildContext context}) async {
    await _logTransitScreen();
  }
}
