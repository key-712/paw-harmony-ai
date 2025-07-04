import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_notification_setting.freezed.dart';
part 'push_notification_setting.g.dart';

/// 全部のプッシュ通知設定を取得するWebAPIのレスポンスを個別設定単位で格納するクラス
@freezed
class PushNotificationSetting with _$PushNotificationSetting {
  /// 全部のプッシュ通知設定を取得するWebAPIのレスポンスを個別設定単位で格納するインスタンス作成します
  factory PushNotificationSetting({
    required int id,
    required String name,
    String? description,
    required bool isSendable,
  }) = _PushNotificationSetting;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory PushNotificationSetting.fromJson(Map<String, dynamic> json) =>
      _$PushNotificationSettingFromJson(json);
}
