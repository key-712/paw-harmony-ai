import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// マスキング解除機能付きパスワードフィールド
class PasswordTextFormField extends HookWidget {
  /// PasswordTextFormFieldのコンストラクタ
  const PasswordTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.autofocus = false,
  });

  /// テキストコントローラー
  final TextEditingController controller;

  /// ラベルテキスト
  final String labelText;

  /// バリデーション関数
  final String? Function(String?)? validator;

  /// テキスト変更時のコールバック
  final void Function(String)? onChanged;

  /// フィールド送信時のコールバック
  final void Function(String)? onFieldSubmitted;

  /// テキスト入力アクション
  final TextInputAction? textInputAction;

  /// 自動フォーカス
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final isPasswordVisible = useState(false);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onPressed: () {
            isPasswordVisible.value = !isPasswordVisible.value;
          },
        ),
      ),
      obscureText: !isPasswordVisible.value,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      autofocus: autofocus,
    );
  }
}
