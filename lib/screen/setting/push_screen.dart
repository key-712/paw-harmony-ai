import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../../../import/component.dart';
import '../../../../import/provider.dart';
import '../../../../import/theme.dart';
import '../../../../import/utility.dart';
import '../../import/hook.dart';
import '../../l10n/app_localizations.dart';

/// プッシュ通知設定画面
class PushScreen extends HookConsumerWidget {
  /// プッシュ通知設定画面
  const PushScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final pushNotificationState = ref.watch(
      pushNotificationStateNotifierProvider,
    );
    final pushNotificationStateNotifier = ref.watch(
      pushNotificationStateNotifierProvider.notifier,
    );
    final notificationPermissionAllowed = ref.watch(
      notificationPermissionStateNotifierProvider,
    );
    final mediaQuery = ref.watch(mediaQueryStateNotifierProvider);

    usePushNotificationToken(context: context, ref: ref);
    useNetworkCheck(context: context, ref: ref, screen: ScreenLabel.push);

    return Scaffold(
      appBar: BackIconHeader(title: l10n.pushNotification),
      backgroundColor: theme.appColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                mediaQuery == MediaType.sp
                    ? LayoutList.spHorizontalPadding
                    : tabletHorizontalPadding(context: context),
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!notificationPermissionAllowed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MessageCard(
                    screen: ScreenLabel.push,
                    title: l10n.onPushNotificationDenied(l10n.productName),
                    message: l10n.onPushNotificationContent,
                    onTap: openAppSettings,
                  ),
                ),
              MessageCard(
                screen: ScreenLabel.push,
                message: l10n.onPushNotificationContent2,
              ),
              hSpace(height: 16),
              Row(
                children: [
                  ThemeText(
                    text: l10n.onPushNotification,
                    color:
                        notificationPermissionAllowed
                            ? theme.appColors.black
                            : theme.appColors.black.withValues(alpha: 0.5),
                    style: theme.textTheme.h30,
                  ),
                  const Spacer(),
                  PrimarySwitch(
                    label: l10n.onPushNotification,
                    value: pushNotificationState.isEnabledPushNotification,
                    onChanged:
                        notificationPermissionAllowed
                            ? (value) => pushNotificationStateNotifier
                                .updateIsEnabledPushNotification(
                                  isEnabled: value,
                                  context: context,
                                  ref: ref,
                                )
                            : null,
                  ),
                ],
              ),
              isNotProduction()
                  ? SelectableText(
                    pushNotificationState.token,
                    style: theme.textTheme.h30,
                  )
                  : Container(height: 1, color: theme.appColors.background),
              hSpace(height: 16),
              const AdBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

/// PushNotificationウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(name: 'PushScreen', type: PushScreen)
Widget pushNotificationUseCase(BuildContext context) {
  return const PushScreen();
}
