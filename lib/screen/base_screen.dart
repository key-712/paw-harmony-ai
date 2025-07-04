import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../import/component.dart';
import '../import/hook.dart';
import '../import/provider.dart';
import '../import/screen.dart';
import '../import/utility.dart';

/// ベース画面
class BaseScreen extends HookConsumerWidget {
  /// ベース画面
  const BaseScreen({super.key});

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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '選手一覧'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: '選手追加'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
