import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/theme.dart';

/// カスタムテキストフィールド
class CustomTextFormField extends HookConsumerWidget {
  /// カスタムテキストフィールド
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.onTap,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.readOnly = false,
    this.keyboardType,
    this.inputFormatters,
    this.autovalidateMode,
    this.validator,
  });

  /// コントローラー
  final TextEditingController controller;

  /// ラベルテキスト
  final String labelText;

  /// プレフィックスアイコン
  final Widget? prefixIcon;

  /// 最大行数
  final int? maxLines;

  /// タップ時の処理
  final VoidCallback? onTap;

  /// テキストフィールドの入力が完了したときの処理
  final VoidCallback? onFieldSubmitted;

  /// 読み取り専用
  final bool readOnly;

  /// キーボードタイプ
  final TextInputType? keyboardType;

  /// 入力フォーマッター
  final List<TextInputFormatter>? inputFormatters;

  /// 自動検証モード
  final AutovalidateMode? autovalidateMode;

  /// バリデーター
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: theme.textTheme.h20,
        prefixIcon: prefixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.appColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.appColors.primary,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.appColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.appColors.red),
        ),
      ),
      style: TextStyle(color: theme.appColors.black),
      cursorColor: theme.appColors.primary,
      validator: validator,
      onFieldSubmitted: (value) {
        onFieldSubmitted?.call();
      },
      onTap: onTap,
    );
  }
}
