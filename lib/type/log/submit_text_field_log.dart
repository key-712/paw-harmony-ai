import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_text_field_log.freezed.dart';
part 'submit_text_field_log.g.dart';

/// FirebaseAnalyticsのイベントでテキストフィールドが入力完了した時のパラメータ設定用のクラス
@freezed
class SubmitTextFieldLog with _$SubmitTextFieldLog {
  /// FirebaseAnalyticsのイベントでテキストフィールドが入力完了した時のパラメータ設定用のクラス
  factory SubmitTextFieldLog({
    required String screen,
    required String placeholder,
    required String value,
  }) = _SubmitTextFieldLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory SubmitTextFieldLog.fromJson(Map<String, dynamic> json) =>
      _$SubmitTextFieldLogFromJson(json);
}
