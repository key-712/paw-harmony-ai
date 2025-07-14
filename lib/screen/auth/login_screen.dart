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
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
        var errorMessage = l10n.loginFailed;

        if (state.error is FirebaseAuthException) {
          final authException = state.error as FirebaseAuthException;
          switch (authException.code) {
            case 'user-not-found':
              errorMessage = l10n.userNotFoundLogin;
            case 'wrong-password':
              errorMessage = l10n.wrongPassword;
            case 'invalid-credential':
              errorMessage = l10n.invalidCredential;
            case 'user-disabled':
              errorMessage = l10n.userDisabled;
            case 'too-many-requests':
              errorMessage = l10n.tooManyLoginAttempts;
            case 'network-request-failed':
              errorMessage = l10n.networkRequestFailed;
            default:
              errorMessage = l10n.loginFailedWithError(
                authException.message ?? '',
              );
          }
        }

        showAlertSnackBar(context: context, theme: theme, text: errorMessage);
      }
    });

    return Scaffold(
      appBar: BaseHeader(title: l10n.loginTitle),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: l10n.emailAddress),
                validator: (value) {
                  if (value == null || !EmailValidator.validate(value)) {
                    return l10n.emailInvalid;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: l10n.password),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.passwordRequired;
                  }
                  return null;
                },
              ),
              hSpace(height: 16),
              PrimaryButton(
                text: l10n.login,
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
                text: l10n.forgotPassword,
                screen: 'login_screen',
                width: double.infinity,
                isDisabled: false,
                callback: () {
                  const PasswordResetScreenRoute().push<void>(context);
                },
              ),
              hSpace(height: 16),
              SecondaryButton(
                text: l10n.goToSignUp,
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
