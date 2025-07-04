import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../import/component.dart';
import '../import/provider.dart';
import '../import/route.dart';
import '../import/theme.dart';
import '../import/utility.dart';

/// 評価状態の状態管理対象データの変更の通知を管理するプロバイダ
final ratingStateProvider =
    StateNotifierProvider<RatingStateNotifier, int>((ref) {
  return RatingStateNotifier();
});

/// 評価状態の状態管理対象データの変更を通知するクラス
class RatingStateNotifier extends StateNotifier<int> {
  /// 評価状態の状態管理対象データの変更を通知するクラス
  RatingStateNotifier() : super(5);

  /// 現在の評価を取得します
  int get rating => state;

  /// 評価を更新します
  set rating(int rating) {
    state = rating;
  }

  /// 評価アクションを処理します
  Future<void> handleRatingAction({
    required BuildContext context,
    required AppTheme theme,
    required int ratingState,
  }) async {
    final localizations = AppLocalizations.of(context)!;

    ratingState == RatingUtils.maxRating
        ? openReview()
        : showSnackBar(
            context: context,
            theme: theme,
            text: localizations.ratingSent,
          );
    const BaseScreenRoute().go(context);
  }

  /// 評価ダイアログを表示するかどうかを確認します
  Future<bool> shouldShowRatingDialog({required WidgetRef ref}) async {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedDateStr =
        prefs.getString(SharedPreferencesKeys.ratingDialogDate);
    if (savedDateStr == null) {
      return true;
    }
    final savedDate = DateTime.parse(savedDateStr);
    final currentDate = DateTime.now();
    final difference = currentDate.difference(savedDate).inDays;
    return difference > RatingUtils.ratingDialogIntervalDays;
  }
}
