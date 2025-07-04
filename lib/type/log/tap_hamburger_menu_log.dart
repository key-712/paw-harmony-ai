import 'package:freezed_annotation/freezed_annotation.dart';

part 'tap_hamburger_menu_log.freezed.dart';
part 'tap_hamburger_menu_log.g.dart';

/// FirebaseAnalyticsのイベントでハンバーガーメニューをタップした時のパラメータ設定用のクラス
@freezed
class TapHamburgerMenuLog with _$TapHamburgerMenuLog {
  /// インスタンスを作成します
  factory TapHamburgerMenuLog({
    required String title,
  }) = _TapHamburgerMenuLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapHamburgerMenuLog.fromJson(Map<String, dynamic> json) =>
      _$TapHamburgerMenuLogFromJson(json);
}
