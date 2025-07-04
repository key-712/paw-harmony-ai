import 'package:freezed_annotation/freezed_annotation.dart';

part 'ad_state.freezed.dart';
part 'ad_state.g.dart';

/// 広告の状態管理対象のデータ
@freezed
class AdState with _$AdState {
  /// インスタンスを作成します
  factory AdState({
    required bool isInterstitialAdLoaded,
  }) = _AdState;

  /// jsonデータを元に、当クラスのインスタンス作成します
  factory AdState.fromJson(Map<String, dynamic> json) =>
      _$AdStateFromJson(json);
}
