import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/type.dart';
import '../import/utility.dart';

/// トラッキング許可ダイアログを表示します
Future<void> requestTrackingAuthorization({
  required WidgetRef ref,
}) async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await Future<void>.delayed(Durations.long2);
    final result = await AppTrackingTransparency.requestTrackingAuthorization();
    if (Platform.isIOS) {
      final isEnable = result == TrackingStatus.authorized;
      await ref
          .read(firebaseAnalyticsServiceProvider)
          .selectRequestTrackingAuthorization(
            parameters: SelectPermissionDialogLog(
              isEnable: isEnable.toString(),
            ),
          );
    }
    logger.d(result);
  }
}
