import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/route.dart';
import '../../import/theme.dart';
import '../../import/type.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// レビュー依頼用のダイアログ
class RatingDialog extends ConsumerWidget {
  /// レビュー依頼用のダイアログ
  const RatingDialog({super.key, required this.screen, required this.text});

  /// 画面
  final String screen;

  /// テキスト
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final ratingState = ref.watch(ratingStateProvider);
    final ratingStateNotifier = ref.watch(ratingStateProvider.notifier);

    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      contentPadding: const EdgeInsets.only(top: 10),
      content: Stack(
        children: [
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref
                    .read(firebaseAnalyticsServiceProvider)
                    .tapButton(
                      parameters: TapButtonLog(screen: screen, label: text),
                    );
                Navigator.of(context).pop();
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: ThemeText(
                  text: localizations.ratingContent,
                  color: theme.appColors.black,
                  style: theme.textTheme.h45,
                ),
              ),
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  final newRating =
                      (details.localPosition.dx / 60).clamp(1, 5).round();
                  ratingStateNotifier.rating = newRating;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Expanded(
                        child: IconButton(
                          icon: Icon(
                            index < ratingState
                                ? Icons.star
                                : Icons.star_border,
                            size: 40,
                            color:
                                index < ratingState
                                    ? theme.appColors.yellow
                                    : theme.appColors.grey,
                          ),
                          onPressed: () async {
                            await ref
                                .read(firebaseAnalyticsServiceProvider)
                                .tapButton(
                                  parameters: TapButtonLog(
                                    screen: screen,
                                    label: text,
                                  ),
                                );
                            ratingStateNotifier.rating = index + 1;
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ThemeText(
                  text: localizations.ratingContent2,
                  color: theme.appColors.black,
                  style: theme.textTheme.h20,
                  align: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        ref
                            .read(firebaseAnalyticsServiceProvider)
                            .tapButton(
                              parameters: TapButtonLog(
                                screen: screen,
                                label: text,
                              ),
                            );
                        ratingStateNotifier.handleRatingAction(
                          context: context,
                          theme: theme,
                          ratingState: ratingState,
                        );
                      },
                      child: ThemeText(
                        text:
                            ratingState == RatingUtils.maxRating
                                ? localizations.rate
                                : localizations.writeReview,
                        color: theme.appColors.black,
                        style: theme.textTheme.h40,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(firebaseAnalyticsServiceProvider)
                            .tapButton(
                              parameters: TapButtonLog(
                                screen: screen,
                                label: text,
                              ),
                            );
                        const BaseScreenRoute().go(context);
                      },
                      child: ThemeText(
                        text: localizations.notRate,
                        color: theme.appColors.grey,
                        style: theme.textTheme.h30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
