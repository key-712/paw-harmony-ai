/// SingleSelectChipは、複数の選択肢から単一項目を選択できるチップコンポーネントです。
///
/// 各チップは選択状態に応じて見た目が変化し、タップすることで選択/非選択を切り替えることができます。
///
/// 使用例:
/// ```dart
/// SingleSelectChip(
///   choices: const ['Option A', 'Option B', 'Option C'],
///   selectedChoice: 'Option A',
///   onSelectionChanged: (selectedItem) {
///     // 選択された項目が変更されたときの処理
///   },
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/theme.dart';

/// 単一選択可能なチップコンポーネント
class SingleSelectChip extends HookConsumerWidget {
  /// 単一選択可能なチップコンポーネントのコンストラクタ
  const SingleSelectChip({
    super.key,
    required this.choices,
    this.selectedChoice,
    required this.onSelectionChanged,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.textColor,
    this.selectedTextColor,
    this.borderColor,
    this.selectedBorderColor,
    this.padding,
    this.horizontalSpace = 8.0,
    this.verticalSpace = 8.0,
  });

  /// チップとして表示する選択肢のリスト。
  final List<String> choices;

  /// 現在選択されている選択肢。
  final String? selectedChoice;

  /// 選択状態が変更されたときに呼び出されるコールバック。
  /// 変更後の選択された選択肢が引数として渡されます。
  final ValueChanged<String?> onSelectionChanged;

  /// チップの背景色。
  final Color? backgroundColor;

  /// 選択されたチップの背景色。
  final Color? selectedBackgroundColor;

  /// チップのテキスト色。
  final Color? textColor;

  /// 選択されたチップのテキスト色。
  final Color? selectedTextColor;

  /// チップのボーダー色。
  final Color? borderColor;

  /// 選択されたチップのボーダー色。
  final Color? selectedBorderColor;

  /// チップのパディング。
  final EdgeInsetsGeometry? padding;

  /// チップ間の水平方向のスペース。
  final double horizontalSpace;

  /// チップ間の垂直方向のスペース。
  final double verticalSpace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: horizontalSpace,
      runSpacing: verticalSpace,
      children:
          choices.map((choice) {
            final isSelected = selectedChoice == choice;
            final theme = ref.watch(appThemeProvider);

            return ChoiceChip(
              label: ThemeText(
                text: choice,
                color:
                    isSelected
                        ? selectedTextColor ?? theme.appColors.white
                        : textColor ?? theme.appColors.black,
                style: theme.textTheme.h30,
              ),
              selected: isSelected,
              selectedColor: selectedBackgroundColor ?? theme.appColors.primary,
              backgroundColor: backgroundColor ?? theme.appColors.white,
              side: BorderSide(
                color:
                    isSelected
                        ? selectedBorderColor ?? theme.appColors.primary
                        : borderColor ?? theme.appColors.grey,
              ),
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              showCheckmark: false,
              onSelected: (selected) {
                onSelectionChanged(selected ? choice : null);
              },
            );
          }).toList(),
    );
  }
}
