import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isAgreed = useState(false);
    final theme = ref.watch(appThemeProvider);

    ref.listen<AsyncValue<void>>(authStateNotifierProvider, (_, state) {
      if (state is AsyncError) {
        var errorMessage = l10n.accountCreationFailed;

        if (state.error is FirebaseAuthException) {
          final authException = state.error as FirebaseAuthException;
          switch (authException.code) {
            case 'email-already-in-use':
              errorMessage = l10n.emailAlreadyInUse;
            case 'weak-password':
              errorMessage = l10n.weakPassword;
            case 'invalid-email':
              errorMessage = l10n.invalidEmail;
            case 'operation-not-allowed':
              errorMessage = l10n.operationNotAllowed;
            case 'network-request-failed':
              errorMessage = l10n.networkRequestFailed;
            default:
              errorMessage = l10n.accountCreationFailedWithError(
                authException.message ?? '',
              );
          }
        }

        showAlertSnackBar(context: context, theme: theme, text: errorMessage);
      }
    });

    return Scaffold(
      appBar: BaseHeader(title: l10n.signUpTitle),
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
                  if (value == null || value.length < 8) {
                    return l10n.passwordTooShortSignUp;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: l10n.confirmPassword),
                obscureText: true,
                validator: (value) {
                  if (value != passwordController.text) {
                    return l10n.passwordMismatch;
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
                      text: l10n.agreeToTerms,
                      color: theme.appColors.black,
                      style: theme.textTheme.h30,
                    ),
                  ),
                ],
              ),
              hSpace(height: 16),
              PrimaryButton(
                text: l10n.createAccount,
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
                text: l10n.goToLogin,
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
