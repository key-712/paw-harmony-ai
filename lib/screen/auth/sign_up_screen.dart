import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/route.dart';
import '../../import/theme.dart';

/// 新規登録画面のウィジェット
class SignUpScreen extends HookConsumerWidget {
  /// SignUpScreenのコンストラクタ
  const SignUpScreen({super.key});

  @override
  /// 新規登録画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isAgreed = useState(false);
    final theme = ref.watch(appThemeProvider);

    ref.listen<AsyncValue<void>>(authStateNotifierProvider, (_, state) {
      if (state is AsyncError) {
        var errorMessage = 'アカウント作成に失敗しました。';

        if (state.error is FirebaseAuthException) {
          final authException = state.error as FirebaseAuthException;
          switch (authException.code) {
            case 'email-already-in-use':
              errorMessage = 'このメールアドレスは既に使用されています。\nログインをお試しください。';
            case 'weak-password':
              errorMessage = 'パスワードが弱すぎます。より強力なパスワードを設定してください。';
            case 'invalid-email':
              errorMessage = '無効なメールアドレスです。';
            case 'operation-not-allowed':
              errorMessage = 'メール/パスワード認証が有効になっていません。';
            case 'network-request-failed':
              errorMessage = 'ネットワークエラーが発生しました。インターネット接続を確認してください。';
            default:
              errorMessage = 'アカウント作成に失敗しました: ${authException.message}';
          }
        }

        showAlertSnackBar(context: context, theme: theme, text: errorMessage);
      }
    });

    return Scaffold(
      appBar: const BaseHeader(title: '新規アカウント作成'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                validator: (value) {
                  if (value == null || !EmailValidator.validate(value)) {
                    return '有効なメールアドレスを入力してください。';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return '8文字以上のパスワードを入力してください。';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'パスワード確認'),
                obscureText: true,
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'パスワードが一致しません。';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Checkbox(
                    value: isAgreed.value,
                    onChanged: (value) {
                      isAgreed.value = value ?? false;
                    },
                  ),
                  Flexible(
                    child: ThemeText(
                      text: '利用規約とプライバシーポリシーに同意します。',
                      color: theme.appColors.black,
                      style: theme.textTheme.h30,
                    ),
                  ),
                ],
              ),
              hSpace(height: 16),
              PrimaryButton(
                text: 'アカウントを作成',
                screen: 'sign_up_screen',
                width: double.infinity,
                isDisabled: false,
                callback: () {
                  if (formKey.currentState!.validate() && isAgreed.value) {
                    ref
                        .read(authStateNotifierProvider.notifier)
                        .signUp(emailController.text, passwordController.text);
                  }
                },
              ),
              hSpace(height: 16),
              SecondaryButton(
                text: 'ログインはこちら',
                screen: 'sign_up_screen',
                width: double.infinity,
                isDisabled: false,
                callback: () {
                  const LoginScreenRoute().go(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
