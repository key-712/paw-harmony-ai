import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/provider.dart';
import '../import/route.dart';
import '../import/type.dart';
import '../import/utility.dart';

/// ウォークスルー画面の状態管理対象データの更新通知を管理するプロバイダ
final AutoDisposeStateNotifierProvider<
  WalkThroughStateNotifier,
  WalkThroughState
>
walkThroughStateNotifierProvider = StateNotifierProvider.autoDispose<
  WalkThroughStateNotifier,
  WalkThroughState
>(WalkThroughStateNotifier.new);

/// ウォークスルー画面の状態管理対象データの変更を通知するクラス
class WalkThroughStateNotifier extends StateNotifier<WalkThroughState> {
  /// ウォークスルー画面の状態管理対象データの変更を通知するクラス
  WalkThroughStateNotifier(this._ref)
    : super(WalkThroughState(currentPage: 0, isAnimating: false));

  final Ref _ref;

  /// ウォークスルー画面の構成ページ
  List<Widget> get contents =>
      WalkThroughContents.values.map((e) => e.widget).toList();

  /// ウォークスルー画面の構成ページの数
  int get stepLength => contents.length;

  /// 次のページのインデックス
  int get nextStepIndex => state.currentPage + 1;

  /// 最後のページのインデックス
  int get lastStepIndex => stepLength - 1;

  /// 最後のページかどうか
  bool get isLastStep => state.currentPage == lastStepIndex;

  /// 表示ページの変更完了を通知します
  void updateCurrentPage(int index) {
    if (state.currentPage == index) return;
    _ref
        .read(firebaseAnalyticsServiceProvider)
        .transitPageIndicator(
          parameters: TransitLog(
            from: state.currentPage.toString(),
            to: index.toString(),
          ),
        );
    state = state.copyWith(currentPage: index, isAnimating: false);
  }

  /// 表示ページを変更します
  Future<void> switchPage(int index, PageController controller) async {
    if (state.isAnimating) return;

    state = state.copyWith(isAnimating: true);
    await controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    updateCurrentPage(index);
  }

  /// ページインジケータのドットをタップ時の処理を行います
  Future<void> onDotClicked({
    required int index,
    required PageController controller,
  }) async {
    await _ref
        .read(firebaseAnalyticsServiceProvider)
        .tapPageIndicatorDot(parameters: TapPageIndicatorDotLog(index: index));
    await switchPage(index, controller);
  }

  /// 次へボタン押下時の処理を行います
  Future<void> handleNextButton({
    required PageController controller,
    required BuildContext context,
  }) async {
    if (state.isAnimating) return;

    if (isLastStep && context.mounted) {
      const BaseScreenRoute().go(context);
    } else {
      await switchPage(nextStepIndex, controller);
    }
  }

  /// スキップリンク押下時の処理を行います
  Future<void> handleSkipLinkText({
    required PageController controller,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    if (isLastStep && context.mounted) {
      if (context.mounted) {
        const BaseScreenRoute().go(context);
      }
    } else {
      await switchPage(lastStepIndex, controller);
    }
  }
}
