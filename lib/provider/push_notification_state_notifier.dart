import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/component.dart';
import '../import/provider.dart';
import '../import/theme.dart';
import '../import/type.dart';
import '../import/utility.dart';

/// プッシュ通知関連の状態管理対象データの更新通知を管理するプロバイダ
final AutoDisposeStateNotifierProvider<
  PushNotificationStateNotifier,
  PushNotificationState
>
pushNotificationStateNotifierProvider = StateNotifierProvider.autoDispose<
  PushNotificationStateNotifier,
  PushNotificationState
>(PushNotificationStateNotifier.new);

/// プッシュ通知関連の状態管理対象データの変更を通知するクラス
class PushNotificationStateNotifier
    extends StateNotifier<PushNotificationState> {
  /// プッシュ通知関連の状態管理対象データの変更を通知するクラス
  PushNotificationStateNotifier(this._ref)
    : super(PushNotificationState(isEnabledPushNotification: true, token: ''));

  final Ref _ref;

  /// ローディング中かどうかの状態を管理するクラス
  late final LoadingStateManager loadingStateManager = _ref.watch(
    loadingStateManagerProvider,
  );

  /// 通知権限の許可状態の変更を通知するクラス
  late final NotificationPermissionStateNotifier
  notificationPermissionNotifier = _ref.watch(
    notificationPermissionStateNotifierProvider.notifier,
  );

  /// FirebaseMessagingServiceのインスタンス
  final messagingService = FirebaseMessagingService();

  /// プッシュ通知有効フラグを更新する
  Future<void> updateIsEnabledPushNotification({
    required bool isEnabled,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    if (isEnabled) {
      if (context.mounted) await getToken();
    } else {
      if (context.mounted) return _deleteToken();
    }
  }

  /// プッシュ通知の設定を更新します
  Future<void> updatePushNotificationSetting({
    required BuildContext context,
  }) async {
    final shouldEnablePushNotification =
        await notificationPermissionNotifier.shouldEnablePushNotification();
    if (shouldEnablePushNotification && context.mounted) {
      await getToken();
    }
  }

  /// FCMトークンを取得する
  Future<void> getToken() async {
    final token = await messagingService.getToken();
    state = state.copyWith(token: token);
    state = state.copyWith(isEnabledPushNotification: true);
  }

  /// FCMトークンを削除する
  Future<void> _deleteToken() async {
    state = state.copyWith(isEnabledPushNotification: false);
    state = state.copyWith(token: '');
  }

  /// Push通知を送信します
  Future<void> pushNotification({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final theme = ref.watch(appThemeProvider);
    if (state.token.isNotEmpty && context.mounted) {
      logger.d(state.token);
      final messagingService = FirebaseMessagingService();
      await messagingService.sendPushNotification(
        title: 'Push通知テスト',
        body: '自分から届きました',
        token: state.token,
        context: context,
        ref: ref,
      );
    } else {
      if (context.mounted) {
        showAlertSnackBar(
          context: context,
          theme: theme,
          text: '通知が許可されていません。',
        );
      }
    }
  }
}
