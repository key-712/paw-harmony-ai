import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/type.dart';
import '../import/utility.dart';

/// プッシュ通知受信の種類
enum CloudMessageType {
  /// フォアグラウンド
  foreground,

  /// バックグラウンド
  background,

  /// 初期
  initial,
}

/// 受信したプッシュ通知に対応した処理を実行
Future<void> handleCloudMessage({
  required CloudMessageType type,
  required RemoteMessage? message,
  required Ref ref,
  required BuildContext context,
}) async {
  logger.i('Received at $type. Data is ${message?.toMap()}');

  if (message == null) return;

  /// 受信したプッシュ通知に含まれているpathデータを取得
  String? getPath() {
    final data = message.data;
    const pathKey = 'path';
    if (data.containsKey(pathKey) && data[pathKey] is String) {
      return data[pathKey] as String;
    }
    return null;
  }

  /// 受信したプッシュ通知に含まれているpathデータをプロバイダに保存
  Future<void> savePath() async {
    final path = getPath();
    await ref.read(firebaseAnalyticsServiceProvider).tapPushNotification(
          parameters: TapPushNotificationLog(
            title: message.notification?.title ?? '',
            path: path ?? '',
            type: type,
          ),
        );
    if (path != null) ref.read(fcmLinkProvider.notifier).state = path;
  }

  switch (type) {
    case CloudMessageType.initial:
      await savePath();

    // フォアグラウンドの場合はローカルプッシュ通知を出す
    case CloudMessageType.foreground:
      await showLocalPushNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        path: getPath(),
        onTap: savePath,
      );

    case CloudMessageType.background:
      await savePath();
  }
}
