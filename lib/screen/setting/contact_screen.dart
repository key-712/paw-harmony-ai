import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// お問い合わせ画面
class ContactScreen extends HookConsumerWidget {
  /// お問い合わせ画面
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final subjectController = TextEditingController();
    final contentController = TextEditingController();

    return Scaffold(
      appBar: BackIconHeader(title: l10n.contact),
      backgroundColor: theme.appColors.background,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ThemeText(
                    text: l10n.contactContentForm,
                    color: theme.appColors.black,
                    style: theme.textTheme.h30,
                  ),
                  hSpace(height: 16),
                  CustomTextFormField(
                    controller: subjectController,
                    labelText: l10n.subject,
                  ),
                  hSpace(height: 32),
                  CustomTextFormField(
                    controller: contentController,
                    labelText: l10n.contactContent,
                    maxLines: 5,
                  ),
                  const Spacer(),
                  PrimaryButton(
                    screen: ScreenLabel.contact,
                    text: l10n.send,
                    width: getScreenSize(context).width,
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
                          text: l10n.sendSuccess,
                        );
                        const BaseScreenRoute().go(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}
