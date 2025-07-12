import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../import/utility.dart'; // loggerのために追加

/// ログイン画面のウィジェット
class LoginScreen extends HookConsumerWidget {
  /// LoginScreenのコンストラクタ
  const LoginScreen({super.key});

  @override
  /// ログイン画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final theme = ref.watch(appThemeProvider);

    ref.listen<AsyncValue<void>>(authStateNotifierProvider, (_, state) {
      if (state is AsyncData) {
        logger.d('[LoginScreen] Login successful.');
        // ログイン成功時の画面遷移はGoRouterのredirectに任せるため、ここでは何もしない
      } else if (state is AsyncError) {
        logger.e(
          '[LoginScreen] Login failed: ${state.error}',
          error: state.error,
          stackTrace: state.stackTrace,
        );
        var errorMessage = 'ログインに失敗しました。';

        if (state.error is FirebaseAuthException) {
          final authException = state.error as FirebaseAuthException;
          switch (authException.code) {
            case 'user-not-found':
              errorMessage = 'このメールアドレスで登録されたユーザーが見つかりません。\n新規登録をお試しください。';
            case 'wrong-password':
              errorMessage = 'パスワードが間違っています。';
            case 'invalid-credential':
              errorMessage = 'メールアドレスまたはパスワードが正しくありません。';
            case 'user-disabled':
              errorMessage = 'このアカウントは無効になっています。';
            case 'too-many-requests':
              errorMessage = 'ログイン試行回数が多すぎます。しばらく時間をおいてから再試行してください。';
            case 'network-request-failed':
              errorMessage = 'ネットワークエラーが発生しました。インターネット接続を確認してください。';
            default:
              errorMessage = 'ログインに失敗しました: ${authException.message}';
          }
        }

        showAlertSnackBar(context: context, theme: theme, text: errorMessage);
      }
    });

    return Scaffold(
      appBar: const BaseHeader(title: 'ログイン'),
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
                  if (value == null || value.isEmpty) {
                    return 'パスワードを入力してください。';
                  }
                  return null;
                },
              ),
              hSpace(height: 16),
              PrimaryButton(
                text: 'ログイン',
                screen: 'login_screen',
                width: double.infinity,
                isDisabled: false,
                callback: () {
                  if (formKey.currentState!.validate()) {
                    logger.d(
                      '[LoginScreen] Login button pressed. Attempting login...',
                    );
                    ref
                        .read(authStateNotifierProvider.notifier)
                        .login(emailController.text, passwordController.text);
                  }
                },
              ),
              hSpace(height: 16),
              SecondaryButton(
                text: 'パスワードをお忘れですか？',
                screen: 'login_screen',
                width: double.infinity,
                isDisabled: false,
                callback: () {
                  const PasswordResetScreenRoute().push<void>(context);
                },
              ),
              hSpace(height: 16),
              SecondaryButton(
                text: '新規登録はこちら',
                screen: 'login_screen',
                width: double.infinity,
                isDisabled: false,
                callback: () {
                  const SignUpScreenRoute().push<void>(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
