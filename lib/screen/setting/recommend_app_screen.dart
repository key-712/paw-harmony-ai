import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// その他のオススメアプリ画面
class RecommendAppScreen extends HookConsumerWidget {
  /// その他のオススメアプリ画面
  const RecommendAppScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);

    final filteredApps =
        getRecommendedApps(
          context,
        ).where((app) => app.appName != l10n.productName).toList();

    return Scaffold(
      appBar: BackIconHeader(title: l10n.recommendApp),
      backgroundColor: theme.appColors.background,
      body: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: ListView.builder(
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        openExternalBrowser(
                          url:
                              Platform.isAndroid
                                  ? app.playStoreUrl
                                  : app.appStoreUrl,
                        );
                      },
                      child: Card(
                        color: theme.appColors.main.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: theme.appColors.black.withValues(
                          alpha: 0.5,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              app.iconPath,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          title: ThemeText(
                            text: app.appName,
                            color: theme.appColors.white,
                            style: theme.textTheme.h40.bold(),
                          ),
                          subtitle: ThemeText(
                            text: app.appDescription,
                            color: theme.appColors.white,
                            style: theme.textTheme.h30,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}
