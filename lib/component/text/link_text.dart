import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/type.dart';
import '../../import/widgetbook.dart';
import '../../l10n/app_localizations.dart';

/// リンクテキスト
class LinkText extends ConsumerWidget {
  /// リンクテキスト
  const LinkText({
    super.key,
    required this.text,
    required this.screen,
    required this.onTap,
  });

  /// テキスト
  final String text;

  /// 画面
  final String screen;

  /// コールバック
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);

    return GestureDetector(
      onTap: () {
        ref.read(firebaseAnalyticsServiceProvider).tapLinkText(
              parameters: TapLinkTextLog(
                screen: screen,
                text: localizations.skip,
              ),
            );
        onTap();
      },
      child: ThemeText(
        text: text,
        color: theme.appColors.black,
        style: theme.textTheme.h40.copyWith(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// LinkTextウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(
  name: 'LinkText',
  type: LinkText,
)
Widget linkTextUseCase(BuildContext context) {
  final text =
      useStringKnob(context: context, label: 'Title', initialValue: 'ボタン');
  final screen = useStringKnob(
    context: context,
    label: 'Screen',
    initialValue: 'Screen',
  );
  void onTap() {}

  return LinkText(
    text: text,
    screen: screen,
    onTap: onTap,
  );
}
