import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../import/component.dart';

/// ローカルプッシュ通知を表示
/// ※fakeContext引数は、テストコード実行環境用です。
Future<void> showLocalPushNotification({
  required String title,
  required String body,
  required String? path,
  required VoidCallback onTap,
  BuildContext? fakeContext,
}) async {
  final flnp = FlutterLocalNotificationsPlugin();
  if (fakeContext != null) {
    // テストコード実行環境では、プッシュ通知表示できないので、ダイアログで代替
    await showDialog<void>(
      context: fakeContext,
      builder: (context) {
        return AlertDialog(
          title: ThemeText(
            text: title,
            color: Colors.black,
            style: const TextStyle(fontSize: 14),
          ),
          content: ThemeText(
            text: body,
            color: Colors.black,
            style: const TextStyle(),
          ),
        );
      },
    );
  } else if (Platform.isAndroid) {
    await flnp.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (_) => onTap(),
    );
    await flnp.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default',
          'default',
          channelDescription: 'default',
        ),
      ),
      payload: path,
    );
  } else if (Platform.isIOS) {
    await flnp.initialize(
      const InitializationSettings(iOS: DarwinInitializationSettings()),
      onDidReceiveNotificationResponse: (_) => onTap(),
    );
    await flnp.show(0, title, body, const NotificationDetails(), payload: path);
  }
}
