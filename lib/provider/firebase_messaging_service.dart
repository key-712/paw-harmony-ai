import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../import/provider.dart';
import '../import/utility.dart';

/// FirebaseMessagingを操作するサービスクラス
class FirebaseMessagingService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'asia-northeast1',
  );

  /// FCMトークンを取得する
  Future<String> getToken() async {
    return await _fcm.getToken() ?? '';
  }

  /// Push通知を送信します
  Future<void> sendPushNotification({
    required String title,
    required String body,
    required String token,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final localizations = AppLocalizations.of(context)!;

    if (title.isEmpty || body.isEmpty || token.isEmpty) {
      logger.e('無効な引数: title, body, または token が空です');
      return;
    }

    try {
      final callable = _functions.httpsCallable('pushTest');
      // ignore: inference_failure_on_function_invocation
      final result = await callable.call({
        'title': title,
        'body': body,
        'token': token,
      });
      logger.d('result.data: ${result.data}');
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      logger.e('FCM通知エラー: $e');
      final dialogStateNotifier = ref.watch(
        dialogStateNotifierProvider.notifier,
      );
      if (context.mounted) {
        await dialogStateNotifier.showActionDialog(
          screen: 'FCM通知',
          title: localizations.error,
          content: e.toString(),
          buttonLabel: localizations.close,
          barrierDismissible: false,
          callback: () {},
          context: context,
        );
      }
    }
  }
}
