import 'package:freezed_annotation/freezed_annotation.dart';

part 'walk_through_state.freezed.dart';
part 'walk_through_state.g.dart';

/// ウォークスルー画面の状態管理対象のデータ
@freezed
class WalkThroughState with _$WalkThroughState {
  /// ウォークスルー画面の状態管理対象のデータ
  factory WalkThroughState({
    required int currentPage,
    required bool isAnimating,
  }) = _WalkThroughState;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory WalkThroughState.fromJson(Map<String, dynamic> json) =>
      _$WalkThroughStateFromJson(json);
}
