import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/utility.dart';

/// プッシュ通知に含まれているpathデータの状態を管理するプロバイダ
final fcmLinkProvider = StateProvider<String>((ref) => '');

/// 起動時のプッシュ通知を取得し、対応するプロバイダ
final FutureProviderFamily<void, BuildContext> initialMessageProvider =
    FutureProvider.family<void, BuildContext>((ref, context) async {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (context.mounted) {
        await handleCloudMessage(
          type: CloudMessageType.initial,
          message: message,
          ref: ref,
          context: context,
        );
      }
    });

/// フォアグラウンド時のプッシュ通知を取得し、対応するプロバイダ
final FutureProviderFamily<void, BuildContext> foregroundMessageProvider =
    FutureProvider.family<void, BuildContext>((ref, context) {
      FirebaseMessaging.onMessage.listen((message) {
        if (context.mounted) {
          handleCloudMessage(
            type: CloudMessageType.foreground,
            message: message,
            ref: ref,
            context: context,
          );
        }
      });
    });

/// バックグラウンド時のプッシュ通知を取得し、対応するプロバイダ
final FutureProviderFamily<void, BuildContext> backgroundMessageProvider =
    FutureProvider.family<void, BuildContext>((ref, context) {
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (context.mounted) {
          handleCloudMessage(
            type: CloudMessageType.background,
            message: message,
            ref: ref,
            context: context,
          );
        }
      });
    });
