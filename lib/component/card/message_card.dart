import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/type.dart';
import '../../import/widgetbook.dart';

/// メッセージカード
class MessageCard extends ConsumerWidget {
  /// メッセージカード
  const MessageCard({
    super.key,
    this.title,
    required this.screen,
    required this.message,
    this.onTap,
  });

  /// タイトル
  final String? title;

  /// 画面
  final String screen;

  /// メッセージ
  final String message;

  /// タップ
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return GestureDetector(
      onTap: () async {
        await ref.read(firebaseAnalyticsServiceProvider).tapCard(
              parameters: TapCardLog(
                screen: screen,
                label: title ?? '',
              ),
            );
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: theme.appColors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: ThemeText(
                        text: title!,
                        color: theme.appColors.black,
                        style: theme.textTheme.h20.medium(),
                      ),
                    ),
                  SelectableText(
                    message,
                    style: theme.textTheme.h20.copyWith(
                      color: theme.appColors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.navigate_next),
              ),
          ],
        ),
      ),
    );
  }
}

/// MessageCardウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(
  name: 'MessageCard',
  type: MessageCard,
)
Widget messageCardUseCase(BuildContext context) {
  final title =
      useStringKnob(context: context, label: 'Title', initialValue: '');
  final message =
      useStringKnob(context: context, label: 'Message', initialValue: 'メッセージ');
  final useOnTap = useBoolKnob(
    context: context,
    label: 'TapEvent',
    initialValue: false,
  );

  return MessageCard(
    screen: '',
    title: title.isEmpty ? null : title,
    message: message,
    onTap: useOnTap ? () {} : null,
  );
}
