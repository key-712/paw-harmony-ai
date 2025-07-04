import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_notification_state.freezed.dart';
part 'push_notification_state.g.dart';

/// プッシュ通知関連の状態管理対象のデータ
@freezed
class PushNotificationState with _$PushNotificationState {
  /// インスタンスを作成します
  factory PushNotificationState({
    required bool isEnabledPushNotification,
    required String token,
  }) = _PushNotificationState;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory PushNotificationState.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationStateFromJson(json);
}
