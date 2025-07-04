import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/gen.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// アプリ概要についての案内ページ(ウォークスルーの構成ページ)
class WelcomeScreen extends HookConsumerWidget {
  /// アプリ概要についての案内ページ(ウォークスルーの構成ページ)
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: theme.appColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Assets.image.walkThrough1.image(width: 300, height: 300),
              ThemeText(
                text: localizations.welcomeMessage(localizations.productName),
                color: theme.appColors.black,
                style: theme.textTheme.h60.bold(),
                align: TextAlign.center,
              ),
              hSpace(height: 16),
              ThemeText(
                text: localizations.descriptionMessage,
                color: theme.appColors.black,
                style: theme.textTheme.h30,
                align: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
