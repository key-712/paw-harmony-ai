import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// ご意見・ご要望画面
class RequestScreen extends HookConsumerWidget {
  /// ご意見・ご要望画面
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final subjectController = TextEditingController();
    final contentController = TextEditingController();

    return Scaffold(
      appBar: BackIconHeader(title: localizations.request),
      backgroundColor: theme.appColors.background,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ThemeText(
                    text: localizations.requestForm,
                    color: theme.appColors.white,
                    style: theme.textTheme.h30,
                  ),
                  hSpace(height: 16),
                  CustomTextFormField(
                    controller: subjectController,
                    labelText: localizations.subject,
                  ),
                  hSpace(height: 16),
                  CustomTextFormField(
                    controller: contentController,
                    labelText: localizations.content,
                    maxLines: 5,
                  ),
                  hSpace(height: 16),
                  PrimaryButton(
                    screen: ScreenLabel.request,
                    text: localizations.send,
                    width: getScreenSize(context).width * 0.8,
                    isDisabled: false,
                    callback: () async {
                      await sendToSlack(
                        context: context,
                        subject: subjectController.text,
                        content: contentController.text,
                      );
                      if (context.mounted) {
                        showSnackBar(
                          context: context,
                          theme: theme,
                          text: localizations.sendSuccessRequest,
                        );
                        const BaseScreenRoute().go(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
