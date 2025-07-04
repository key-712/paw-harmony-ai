import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_state.freezed.dart';
part 'purchase_state.g.dart';

/// 購入画面の状態管理対象のデータ
@freezed
class PurchaseState with _$PurchaseState {
  /// インスタンスを作成します
  factory PurchaseState({
    required bool isSubscribed,
  }) = _PurchaseState;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory PurchaseState.fromJson(Map<String, dynamic> json) =>
      _$PurchaseStateFromJson(json);
}
