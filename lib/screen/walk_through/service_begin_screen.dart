import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/gen.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// サービス開始の案内ページ(ウォークスルーの構成ページ)
class ServiceBeginScreen extends HookConsumerWidget {
  /// サービス開始の案内ページ(ウォークスルーの構成ページ)
  const ServiceBeginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    return Scaffold(
      backgroundColor: theme.appColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Assets.image.walkThrough3.image(width: 300, height: 300),
              ThemeText(
                text: l10n.serviceBeginScreen,
                color: theme.appColors.black,
                style: theme.textTheme.h60.bold(),
                align: TextAlign.center,
              ),
              hSpace(height: 16),
              ThemeText(
                text: l10n.serviceBeginContent,
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
