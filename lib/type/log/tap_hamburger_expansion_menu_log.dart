import 'package:freezed_annotation/freezed_annotation.dart';

part 'tap_hamburger_expansion_menu_log.freezed.dart';
part 'tap_hamburger_expansion_menu_log.g.dart';

/// FirebaseAnalyticsのイベントでハンバーガーメニューをタップした時のパラメータ設定用のクラス
@freezed
class TapHamburgerExpansionMenuLog with _$TapHamburgerExpansionMenuLog {
  /// インスタンスを作成します
  factory TapHamburgerExpansionMenuLog({
    required String title,
    required String isExpanded,
  }) = _TapHamburgerExpansionMenuLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapHamburgerExpansionMenuLog.fromJson(Map<String, dynamic> json) =>
      _$TapHamburgerExpansionMenuLogFromJson(json);
}
