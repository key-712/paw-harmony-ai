import 'package:freezed_annotation/freezed_annotation.dart';

part 'tap_icon_button_log.freezed.dart';
part 'tap_icon_button_log.g.dart';

/// FirebaseAnalyticsのイベントでアイコンボタンをタップした時のパラメータ設定用のクラス
@freezed
class TapIconButtonLog with _$TapIconButtonLog {
  /// インスタンスを作成します
  factory TapIconButtonLog({
    required String screen,
    required String icon,
  }) = _TapIconButtonLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapIconButtonLog.fromJson(Map<String, dynamic> json) =>
      _$TapIconButtonLogFromJson(json);
}
