import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/type.dart';

/// 通知権限の許可状態の変更の通知を管理するプロバイダ
final notificationPermissionStateNotifierProvider =
    StateNotifierProvider<NotificationPermissionStateNotifier, bool>(
  NotificationPermissionStateNotifier.new,
);

/// 通知権限の許可状態の変更を通知するクラス
class NotificationPermissionStateNotifier extends StateNotifier<bool> {
  /// 通知権限の許可状態の変更を通知するクラス
  NotificationPermissionStateNotifier(this._ref) : super(false);

  final Ref _ref;

  /// プッシュ通知有効フラグを有効に更新すべきかどうかを取得します
  Future<bool> shouldEnablePushNotification() async {
    final isInitialHome = _ref.read(isInitialHomeProvider);
    final isPermissionAllowed = await _requestPermission();
    if (Platform.isIOS) {
      return isInitialHome && isPermissionAllowed;
    } else if (Platform.isAndroid) {
      final notificationAndroid = FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final areNotificationsEnabled =
          await notificationAndroid?.areNotificationsEnabled() ?? false;
      return (isInitialHome || !areNotificationsEnabled) && isPermissionAllowed;
    }
    return false;
  }

  /// 通知権限の許可をリクエスト後、許可状態を取得し、通知します
  Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      state = await FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else if (Platform.isAndroid) {
      state = await FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    await _ref
        .read(firebaseAnalyticsServiceProvider)
        .selectDevicePushNotificationSetting(
          parameters: SelectPermissionDialogLog(
            isEnable: state.toString(),
          ),
        );
    return state;
  }

  /// 現在の通知権限の許可状態を最新の状態に更新して、通知します
  Future<void> update() async {
    if (Platform.isIOS) {
      state = await FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else if (Platform.isAndroid) {
      state = await FlutterLocalNotificationsPlugin()
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
  }
}
