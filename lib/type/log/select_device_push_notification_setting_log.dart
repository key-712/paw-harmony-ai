import 'package:freezed_annotation/freezed_annotation.dart';

part 'select_device_push_notification_setting_log.freezed.dart';
part 'select_device_push_notification_setting_log.g.dart';

/// FirebaseAnalyticsのイベントでプッシュ通知設定許可ダイアログの回答を選択した時のパラメータ設定用のクラス
@freezed
class SelectDevicePushNotificationSettingLog
    with _$SelectDevicePushNotificationSettingLog {
  /// FirebaseAnalyticsのイベントでプッシュ通知設定許可ダイアログの回答を選択した時のパラメータ設定用のクラス
  factory SelectDevicePushNotificationSettingLog({
    required String isEnable,
  }) = _SelectDevicePushNotificationSettingLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory SelectDevicePushNotificationSettingLog.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SelectDevicePushNotificationSettingLogFromJson(json);
}
