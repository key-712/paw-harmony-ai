import 'package:freezed_annotation/freezed_annotation.dart';

part 'tap_bottom_navigation.freezed.dart';
part 'tap_bottom_navigation.g.dart';

/// FirebaseAnalyticsのイベントでボトムナビゲーションバーをタップした時のパラメータ設定用のクラス
@freezed
class TapBottomNavigationLog with _$TapBottomNavigationLog {
  /// インスタンスを作成します
  factory TapBottomNavigationLog({
    required String from,
    required String to,
  }) = _TapBottomNavigationLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapBottomNavigationLog.fromJson(Map<String, dynamic> json) =>
      _$TapBottomNavigationLogFromJson(json);
}
