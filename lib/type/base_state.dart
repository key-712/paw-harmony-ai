import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_state.freezed.dart';
part 'base_state.g.dart';

/// ベース画面の状態管理対象のデータ
@freezed
class BaseState with _$BaseState {
  /// インスタンスを作成します
  factory BaseState({
    required int selectIndex,
  }) = _BaseState;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory BaseState.fromJson(Map<String, dynamic> json) =>
      _$BaseStateFromJson(json);
}
