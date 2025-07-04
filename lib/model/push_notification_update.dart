import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_notification_update.freezed.dart';
part 'push_notification_update.g.dart';

/// プッシュ通知設定を更新するWebAPIに渡すデータを格納するクラス
@freezed
class PushNotificationUpdate with _$PushNotificationUpdate {
  /// プッシュ通知設定を更新するWebAPIに渡すデータを格納するインスタンス作成します
  factory PushNotificationUpdate({
    required int notificationId,
    required bool isSendable,
  }) = _PushNotificationUpdate;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory PushNotificationUpdate.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationUpdateFromJson(json);
}
