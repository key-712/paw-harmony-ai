import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// メール送信完了画面
class EmailSentScreen extends HookConsumerWidget {
  /// メール送信完了画面
  const EmailSentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    return Scaffold(
      appBar: BaseHeader(title: l10n.emailSentTitle),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ThemeText(
              text: l10n.emailSentMessage,
              color: theme.appColors.black,
              style: theme.textTheme.h30,
            ),
            hSpace(height: 24),
            PrimaryButton(
              text: l10n.goToLogin,
              screen: 'email_sent_screen',
              width: double.infinity,
              isDisabled: false,
              callback: () {
                const LoginScreenRoute().go(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
