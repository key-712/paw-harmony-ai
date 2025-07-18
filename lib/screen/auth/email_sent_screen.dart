import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/route.dart';
import '../../l10n/app_localizations.dart';

class EmailSentScreen extends HookConsumerWidget {
  const EmailSentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: BaseHeader(title: l10n.emailSentTitle),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.emailSentMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
