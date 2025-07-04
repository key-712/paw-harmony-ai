import 'package:freezed_annotation/freezed_annotation.dart';

import '../../import/utility.dart';

part 'tap_push_notification_log.freezed.dart';
part 'tap_push_notification_log.g.dart';

/// FirebaseAnalyticsのイベントでプッシュ通知をタップした時のパラメータ設定用のクラス
@freezed
class TapPushNotificationLog with _$TapPushNotificationLog {
  /// インスタンスを作成します
  factory TapPushNotificationLog({
    required CloudMessageType type,
    required String title,
    required String path,
  }) = _TapPushNotificationLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapPushNotificationLog.fromJson(Map<String, dynamic> json) =>
      _$TapPushNotificationLogFromJson(json);
}
