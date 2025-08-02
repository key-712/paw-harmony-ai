import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildLanguageCard(
                    context: context,
                    theme: theme,
                    locale: locale,
                    localeNotifier: localeNotifier,
                    languageCode: 'en',
                    languageName: l10n.english,
                    flagIcon: '🇺🇸',
                    isSelected: locale?.languageCode == 'en',
                    l10n: l10n,
                  ),
                  hSpace(height: 12),
                  _buildLanguageCard(
                    context: context,
                    theme: theme,
                    locale: locale,
                    localeNotifier: localeNotifier,
                    languageCode: 'ja',
                    languageName: l10n.japanese,
                    flagIcon: '🇯🇵',
                    isSelected: locale?.languageCode == 'ja',
                    l10n: l10n,
                  ),
                  hSpace(height: 12),
                  _buildLanguageCard(
                    context: context,
                    theme: theme,
                    locale: locale,
                    localeNotifier: localeNotifier,
                    languageCode: 'fr',
                    languageName: l10n.french,
                    flagIcon: '🇫🇷',
                    isSelected: locale?.languageCode == 'fr',
                    l10n: l10n,
                  ),
                  hSpace(height: 12),
                  _buildLanguageCard(
                    context: context,
                    theme: theme,
                    locale: locale,
                    localeNotifier: localeNotifier,
                    languageCode: 'it',
                    languageName: l10n.italian,
                    flagIcon: '🇮🇹',
                    isSelected: locale?.languageCode == 'it',
                    l10n: l10n,
                  ),
                  hSpace(height: 12),
                  _buildLanguageCard(
                    context: context,
                    theme: theme,
                    locale: locale,
                    localeNotifier: localeNotifier,
                    languageCode: 'es',
                    languageName: l10n.spanish,
                    flagIcon: '🇪🇸',
                    isSelected: locale?.languageCode == 'es',
                    l10n: l10n,
                  ),
                ],
              ),
            ),
            const AdBanner(),
          ],
        ),
      ),
    );
  }

  /// 言語選択カードを構築するメソッド
  Widget _buildLanguageCard({
    required BuildContext context,
    required AppTheme theme,
    required Locale? locale,
    required StateController<Locale?> localeNotifier,
    required String languageCode,
    required String languageName,
    required String flagIcon,
    required bool isSelected,
    required AppLocalizations l10n,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient:
            isSelected
                ? LinearGradient(
                  colors: [
                    theme.appColors.main.withValues(alpha: 0.1),
                    theme.appColors.main.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isSelected
                    ? theme.appColors.main.withValues(alpha: 0.3)
                    : ColorUtility.black10,
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
        border:
            isSelected
                ? Border.all(
                  color: theme.appColors.main.withValues(alpha: 0.3),
                  width: 2,
                )
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            localeNotifier.state = Locale(languageCode);
            Navigator.pop(context);
            Future.delayed(const Duration(milliseconds: 100), () {
              if (context.mounted) {
                showSnackBar(
                  context: context,
                  theme: theme,
                  text: AppLocalizations.of(context)!.languageSettingSuccess,
                );
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // フラグアイコン
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:
                        isSelected
                            ? theme.appColors.main.withValues(alpha: 0.1)
                            : ColorUtility.grey10,
                  ),
                  child: Center(
                    child: Text(flagIcon, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                wSpace(width: 16),
                // 言語名
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ThemeText(
                        text: languageName,
                        style: theme.textTheme.h40.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        color:
                            isSelected
                                ? theme.appColors.main
                                : theme.appColors.black,
                      ),
                      if (isSelected) ...[
                        hSpace(height: 4),
                        ThemeText(
                          text: l10n.selected,
                          style: theme.textTheme.h30,
                          color: theme.appColors.main,
                        ),
                      ],
                    ],
                  ),
                ),
                // 選択状態のアイコン
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      isSelected
                          ? Container(
                            key: const ValueKey('selected'),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.appColors.main,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.appColors.main.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          )
                          : Container(
                            key: const ValueKey('unselected'),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ColorUtility.grey30,
                                width: 2,
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
