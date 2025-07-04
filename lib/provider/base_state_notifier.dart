import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/type.dart';

/// ベース画面の状態管理対象データの更新通知を管理するプロバイダ
final AutoDisposeStateNotifierProvider<BaseStateNotifier, BaseState>
baseStateNotifierProvider =
    StateNotifierProvider.autoDispose<BaseStateNotifier, BaseState>(
      BaseStateNotifier.new,
    );

/// ベース画面の状態管理対象データの変更を通知するクラス
class BaseStateNotifier extends StateNotifier<BaseState> {
  /// ベース画面の状態管理対象データの変更を通知するクラス
  BaseStateNotifier(this._ref) : super(BaseState(selectIndex: 0));

  final Ref _ref;

  /// プッシュ通知の許可状態を管理するプロバイダ
  NotificationPermissionStateNotifier get notificationPermissionNotifier =>
      _ref.read(notificationPermissionStateNotifierProvider.notifier);

  /// 選択中のタブを更新します
  void setIndex({required int index}) {
    state = state.copyWith(selectIndex: index);
  }

  /// アプリの状態が非アクティブからアクティブになった時の処理を行います
  Future<void> onResumed({required BuildContext context}) async {
    await notificationPermissionNotifier.update();
  }
}
