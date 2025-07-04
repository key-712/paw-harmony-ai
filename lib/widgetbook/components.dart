import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Widgetbook上でインタラクティブに変更可能なbool型データを取得
bool useBoolKnob({
  required BuildContext context,
  required String label,
  String? description,
  required bool initialValue,
}) {
  return context.knobs.boolean(
    label: label,
    description: description,
    initialValue: initialValue,
  );
}

/// Widgetbook上でインタラクティブに変更可能な文字列型データを取得
String useStringKnob({
  required BuildContext context,
  required String label,
  required String initialValue,
}) {
  return context.knobs.string(label: label, initialValue: initialValue);
}

/// Widgetbook上でインタラクティブに変更可能なDouble型データを取得
double useSliderKnob({
  required BuildContext context,
  required String label,
  required double initialValue,
  required double max,
  required int divisions,
}) {
  return context.knobs.doubleOrNull.slider(
        label: label,
        initialValue: initialValue,
        max: max,
        divisions: divisions,
      ) ??
      0;
}

/// Widgetbook上でインタラクティブに変更可能な色データを取得
Color useListKnob({
  required BuildContext context,
  required String label,
  required List<Color> options,
}) {
  return context.knobs.list(label: label, options: options);
}
