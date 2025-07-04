import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../../import/widgetbook.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/type.dart';
import '../../import/utility.dart';

/// 通常のスイッチ
class PrimarySwitch extends ConsumerWidget {
  /// 通常のスイッチ
  const PrimarySwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// ラベル
  final String label;

  /// 値
  final bool value;

  /// コールバック
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Switch(
      value: value,
      activeColor: theme.appColors.white,
      activeTrackColor: theme.appColors.main,
      inactiveThumbColor: theme.appColors.grey,
      inactiveTrackColor: theme.appColors.white,
      trackOutlineColor: WidgetStateProperty.all<Color>(
        value ? theme.appColors.main : theme.appColors.white,
      ),
      onChanged: (value) {
        ref.read(firebaseAnalyticsServiceProvider).tapSwitch(
              parameters: TapSwitchLog(
                screen: ScreenLabel.push,
                label: label,
                isEnabled: value.toString(),
              ),
            );
        onChanged?.call(value);
      },
    );
  }
}

/// PrimarySwitchウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(
  name: 'PrimarySwitch',
  type: PrimarySwitch,
)
Widget primarySwitchUseCase(BuildContext context) {
  final value =
      useBoolKnob(context: context, label: 'value', initialValue: false);

  return PrimarySwitch(
    label: '',
    value: value,
    onChanged: null,
  );
}
