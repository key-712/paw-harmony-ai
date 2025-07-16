import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../l10n/app_localizations.dart';

/// 言語設定画面
class LanguageSettingScreen extends HookConsumerWidget {
  /// 言語設定画面
  const LanguageSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.watch(localeProvider.notifier);

    return Scaffold(
      appBar: BackIconHeader(title: l10n.languageSetting),
      backgroundColor: theme.appColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: ThemeText(
                    text: l10n.english,
                    style: theme.textTheme.h40,
                    color:
                        locale == const Locale('en')
                            ? theme.appColors.black
                            : theme.appColors.grey,
                  ),
                  trailing:
                      locale == const Locale('en')
                          ? Icon(Icons.check, color: theme.appColors.primary)
                          : null,
                  onTap: () {
                    localeNotifier.locale = const Locale('en');
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        showSnackBar(
                          context: context,
                          theme: theme,
                          text:
                              AppLocalizations.of(
                                context,
                              )!.languageSettingSuccess,
                        );
                      }
                    });
                  },
                ),
                ListTile(
                  title: ThemeText(
                    text: l10n.japanese,
                    style: theme.textTheme.h40,
                    color:
                        locale == const Locale('ja')
                            ? theme.appColors.black
                            : theme.appColors.grey,
                  ),
                  trailing:
                      locale == const Locale('ja')
                          ? Icon(Icons.check, color: theme.appColors.primary)
                          : null,
                  onTap: () {
                    localeNotifier.locale = const Locale('ja');
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        showSnackBar(
                          context: context,
                          theme: theme,
                          text:
                              AppLocalizations.of(
                                context,
                              )!.languageSettingSuccess,
                        );
                      }
                    });
                  },
                ),
                ListTile(
                  title: ThemeText(
                    text: l10n.french,
                    style: theme.textTheme.h40,
                    color:
                        locale == const Locale('fr')
                            ? theme.appColors.black
                            : theme.appColors.grey,
                  ),
                  trailing:
                      locale == const Locale('fr')
                          ? Icon(Icons.check, color: theme.appColors.primary)
                          : null,
                  onTap: () {
                    localeNotifier.locale = const Locale('fr');
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        showSnackBar(
                          context: context,
                          theme: theme,
                          text:
                              AppLocalizations.of(
                                context,
                              )!.languageSettingSuccess,
                        );
                      }
                    });
                  },
                ),
                ListTile(
                  title: ThemeText(
                    text: l10n.italian,
                    style: theme.textTheme.h40,
                    color:
                        locale == const Locale('it')
                            ? theme.appColors.black
                            : theme.appColors.grey,
                  ),
                  trailing:
                      locale == const Locale('it')
                          ? Icon(Icons.check, color: theme.appColors.primary)
                          : null,
                  onTap: () {
                    localeNotifier.locale = const Locale('it');
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        showSnackBar(
                          context: context,
                          theme: theme,
                          text:
                              AppLocalizations.of(
                                context,
                              )!.languageSettingSuccess,
                        );
                      }
                    });
                  },
                ),
                ListTile(
                  title: ThemeText(
                    text: l10n.spanish,
                    style: theme.textTheme.h40,
                    color:
                        locale == const Locale('es')
                            ? theme.appColors.black
                            : theme.appColors.grey,
                  ),
                  trailing:
                      locale == const Locale('es')
                          ? Icon(Icons.check, color: theme.appColors.primary)
                          : null,
                  onTap: () {
                    localeNotifier.locale = const Locale('es');
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        showSnackBar(
                          context: context,
                          theme: theme,
                          text:
                              AppLocalizations.of(
                                context,
                              )!.languageSettingSuccess,
                        );
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}
