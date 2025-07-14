import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// パスワードリセット画面のウィジェット
class PasswordResetScreen extends HookConsumerWidget {
  /// PasswordResetScreenのコンストラクタ
  const PasswordResetScreen({super.key});

  @override
  /// パスワードリセット画面を構築するメソッド
  ///
  /// [context] ビルドコンテキスト
  /// [ref] RiverpodのRefインスタンス
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final emailController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final theme = ref.watch(appThemeProvider);

    ref.listen<AsyncValue<void>>(authStateNotifierProvider, (_, state) {
      if (state is AsyncError) {
        var errorMessage = l10n.passwordResetFailed;

        if (state.error is FirebaseAuthException) {
          final authException = state.error as FirebaseAuthException;
          switch (authException.code) {
            case 'user-not-found':
              errorMessage = l10n.userNotFound;
            case 'invalid-email':
              errorMessage = l10n.invalidEmail;
            case 'too-many-requests':
              errorMessage = l10n.tooManyRequests;
            case 'network-request-failed':
              errorMessage = l10n.networkRequestFailed;
            default:
              errorMessage = l10n.passwordResetFailedWithError(
                authException.message ?? '',
              );
          }
        }

        showAlertSnackBar(context: context, theme: theme, text: errorMessage);
      } else if (state is AsyncData) {
        showSnackBar(
          context: context,
          theme: theme,
          text: l10n.passwordResetEmailSent,
        );
        GoRouter.of(context).pop();
      }
    });

    return Scaffold(
      appBar: BackIconHeader(title: l10n.passwordResetTitle),
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
              hSpace(height: 16),
              PrimaryButton(
                text: l10n.sendPasswordResetEmail,
                screen: 'password_reset_screen',
                width: double.infinity,
                isDisabled: false,
                callback: () {
                  if (formKey.currentState!.validate()) {
                    ref
                        .read(authStateNotifierProvider.notifier)
                        .sendPasswordResetEmail(emailController.text);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
