import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../import/component.dart';
import '../../import/hook.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// ウォークスルー画面
class WalkThroughScreen extends HookConsumerWidget {
  /// ウォークスルー画面
  const WalkThroughScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(walkThroughStateNotifierProvider);
    final walkThroughNotifier =
        ref.watch(walkThroughStateNotifierProvider.notifier);
    final controller = usePageController();
    final localizations = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);

    useHandlePageController(controller: controller, ref: ref);

    return Scaffold(
      backgroundColor: theme.appColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              hSpace(height: 16),
              SizedBox(
                height: getScreenSize(context).height * 0.6,
                child: PageView.builder(
                  controller: controller,
                  itemCount: walkThroughNotifier.stepLength,
                  itemBuilder: (_, index) {
                    return walkThroughNotifier
                        .contents[index % walkThroughNotifier.stepLength];
                  },
                ),
              ),
              hSpace(height: 16),
              SmoothPageIndicator(
                controller: controller,
                count: walkThroughNotifier.stepLength,
                onDotClicked: (index) => walkThroughNotifier.onDotClicked(
                  index: index,
                  controller: controller,
                ),
                effect: ScrollingDotsEffect(
                  activeStrokeWidth: 2.6,
                  radius: 8,
                  spacing: 10,
                  dotHeight: 8,
                  dotWidth: 8,
                  dotColor: theme.appColors.grey,
                  activeDotColor: theme.appColors.main,
                ),
              ),
              hSpace(height: 40),
              PrimaryButton(
                screen: ScreenLabel.walkThrough,
                text: walkThroughNotifier.isLastStep
                    ? localizations.signUp
                    : localizations.next,
                width: getScreenSize(context).width * 0.8,
                isDisabled: false,
                callback: () => walkThroughNotifier.handleNextButton(
                  controller: controller,
                  context: context,
                ),
              ),
              hSpace(height: 16),
              LinkText(
                screen: ScreenLabel.walkThrough,
                text: walkThroughNotifier.isLastStep
                    ? localizations.skipWithoutRegister
                    : localizations.skip,
                onTap: () => walkThroughNotifier.handleSkipLinkText(
                  controller: controller,
                  ref: ref,
                  context: context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// WalkThroughウィジェットのWidgetbookでの確認用メソッド
@widgetbook.UseCase(
  name: ScreenLabel.walkThrough,
  type: WalkThroughScreen,
)
Widget walkThroughUseCase(BuildContext context) {
  return const WalkThroughScreen();
}
