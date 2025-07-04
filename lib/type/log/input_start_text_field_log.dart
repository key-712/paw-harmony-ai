import 'package:freezed_annotation/freezed_annotation.dart';

part 'input_start_text_field_log.freezed.dart';
part 'input_start_text_field_log.g.dart';

/// FirebaseAnalyticsのイベントでテキストフィールドが入力開始した時のパラメータ設定用のクラス
@freezed
class InputStartTextFieldLog with _$InputStartTextFieldLog {
  /// インスタンスを作成します
  factory InputStartTextFieldLog({
    required String screen,
    required String placeholder,
  }) = _InputStartTextFieldLog;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory InputStartTextFieldLog.fromJson(Map<String, dynamic> json) =>
      _$InputStartTextFieldLogFromJson(json);
}
