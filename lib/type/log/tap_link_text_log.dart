import 'package:freezed_annotation/freezed_annotation.dart';

part 'tap_link_text_log.freezed.dart';
part 'tap_link_text_log.g.dart';

/// FirebaseAnalyticsのイベントでリンクテキストをタップした時のパラメータ設定用のクラス
@freezed
class TapLinkTextLog with _$TapLinkTextLog {
  /// インスタンスを作成します
  factory TapLinkTextLog({
    required String screen,
    required String text,
    @Default('') String url,
  }) = _TapLinkTextLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory TapLinkTextLog.fromJson(Map<String, dynamic> json) =>
      _$TapLinkTextLogFromJson(json);
}
