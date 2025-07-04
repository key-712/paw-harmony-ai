import 'package:freezed_annotation/freezed_annotation.dart';

part 'tap_page_indicator_dot.freezed.dart';
part 'tap_page_indicator_dot.g.dart';

/// FirebaseAnalyticsのイベントでページインジケータドットをタップした時のパラメータ設定用のクラス
@freezed
class TapPageIndicatorDotLog with _$TapPageIndicatorDotLog {
  /// FirebaseAnalyticsのイベントでページインジケータドットをタップした時のパラメータ設定用のクラス
  factory TapPageIndicatorDotLog({
    required int index,
  }) = _TapPageIndicatorDotLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapPageIndicatorDotLog.fromJson(Map<String, dynamic> json) =>
      _$TapPageIndicatorDotLogFromJson(json);
}
