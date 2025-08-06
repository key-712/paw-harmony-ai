import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
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
    final emailFocusNode = useFocusNode();
    final passwordFocusNode = useFocusNode();
    final confirmPasswordFocusNode = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final isAgreed = useState(false);
    final theme = ref.watch(appThemeProvider);

    ref.listen<AsyncValue<void>>(authStateNotifierProvider, (_, state) {
      if (state is AsyncData) {
        // サインアップ成功後は直接ログイン画面に遷移
        const LoginScreenRoute().go(context);
      }
      if (state is AsyncError) {
        var errorMessage = l10n.accountCreationFailed;

        if (state.error is FirebaseAuthException) {
          final authException = state.error as FirebaseAuthException;
          switch (authException.code) {
            case 'email-already-in-use':
              errorMessage = l10n.emailAlreadyInUse;
            case 'invalid-email':
              errorMessage = l10n.invalidEmail;
            case 'operation-not-allowed':
              errorMessage = l10n.operationNotAllowed;
            case 'network-request-failed':
              errorMessage = l10n.networkRequestFailed;
            default:
              errorMessage = l10n.accountCreationFailed;
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
                focusNode: emailFocusNode,
                decoration: InputDecoration(labelText: l10n.emailAddress),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  passwordFocusNode.requestFocus();
                },
                validator: (value) {
                  if (value == null || !EmailValidator.validate(value)) {
                    return l10n.emailInvalid;
                  }
                  return null;
                },
              ),
              PasswordTextFormField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                labelText: l10n.password,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  confirmPasswordFocusNode.requestFocus();
                },
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return l10n.passwordTooShortSignUp;
                  }
                  return null;
                },
              ),
              PasswordTextFormField(
                controller: confirmPasswordController,
                focusNode: confirmPasswordFocusNode,
                labelText: l10n.confirmPassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value != passwordController.text) {
                    return l10n.passwordMismatch;
                  }
                  return null;
                },
              ),
              hSpace(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isAgreed.value,
                    onChanged: (value) {
                      isAgreed.value = value ?? false;
                    },
                  ),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.h30.copyWith(
                          color: theme.appColors.black,
                        ),
                        children: [
                          TextSpan(text: l10n.agreeToTermsPrefix),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                openExternalBrowser(
                                  url: ExternalPageList.legal,
                                );
                              },
                              child: ThemeText(
                                text: l10n.legal,
                                color: theme.appColors.main,
                                style: theme.textTheme.h30.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(text: l10n.agreeToTermsMiddle),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                openExternalBrowser(
                                  url: ExternalPageList.privacyPolicy,
                                );
                              },
                              child: ThemeText(
                                text: l10n.privacyPolicy,
                                color: theme.appColors.main,
                                style: theme.textTheme.h30.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(text: l10n.agreeToTermsSuffix),
                        ],
                      ),
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
                  if (formKey.currentState!.validate()) {
                    if (isAgreed.value) {
                      ref
                          .read(authStateNotifierProvider.notifier)
                          .signUp(
                            emailController.text,
                            passwordController.text,
                          );
                    } else {
                      showAlertSnackBar(
                        context: context,
                        theme: theme,
                        text: l10n.termsAgreementRequired,
                      );
                    }
                  }
                },
              ),
              hSpace(height: 8),
              ThemeText(
                text: l10n.emailVerificationRequired,
                color: theme.appColors.grey,
                style: theme.textTheme.h20,
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
