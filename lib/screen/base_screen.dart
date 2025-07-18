import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/component.dart';
import '../import/hook.dart';
import '../import/provider.dart';
import '../import/screen.dart';
import '../import/utility.dart';
import '../l10n/app_localizations.dart';

/// ベース画面
class BaseScreen extends HookConsumerWidget {
  /// ベース画面
  const BaseScreen({super.key});

  /// ベース画面のUIを構築します。
  ///
  /// [context] はウィジェットツリー内の現在のビルドコンテキストです。
  /// [ref] はプロバイダーを監視するためのWidgetRefです。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = ref.watch(baseStateNotifierProvider);
    final baseStateNotifier = ref.watch(baseStateNotifierProvider.notifier);
    final scrollControllers = useMemoized(
      () => List.generate(3, (_) => ScrollController()),
      const [],
    );

    UpdateChecker().checkForUpdate(
      context: context,
      ref: ref,
      screen: ScreenLabel.base,
    );

    usePushNotificationSetting(context: context, ref: ref);
    useNetworkCheck(context: context, ref: ref, screen: ScreenLabel.base);
    requestTrackingAuthorization(ref: ref);

    ref.listen<AppLifecycleState>(appLifecycleStateNotifierProvider, (
      _,
      next,
    ) async {
      if (next == AppLifecycleState.resumed) {
        await baseStateNotifier.onResumed(context: context);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: base.selectIndex,
                children: [
                  AudioGenerationScreen(scrollController: scrollControllers[0]),
                  PlayerListScreen(scrollController: scrollControllers[1]),
                  SettingScreen(scrollController: scrollControllers[2]),
                ],
              ),
            ),
            const AdBanner(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: base.selectIndex,
        onTap: (index) {
          if (index == base.selectIndex) {
            scrollControllers[index].animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            baseStateNotifier.setIndex(index: index);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label:
                ThemeText(
                  text: AppLocalizations.of(context)!.audioGeneration,
                  color: Theme.of(context).colorScheme.onSurface,
                  style: Theme.of(context).textTheme.bodyMedium!,
                ).text,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.music_note),
            label:
                ThemeText(
                  text: AppLocalizations.of(context)!.playerList,
                  color: Theme.of(context).colorScheme.onSurface,
                  style: Theme.of(context).textTheme.bodyMedium!,
                ).text,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label:
                ThemeText(
                  text: AppLocalizations.of(context)!.setting,
                  color: Theme.of(context).colorScheme.onSurface,
                  style: Theme.of(context).textTheme.bodyMedium!,
                ).text,
          ),
        ],
      ),
    );
  }
}
