import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../import/component.dart';
import '../../import/provider.dart';
import '../../import/theme.dart';
import '../../import/utility.dart';
import '../../l10n/app_localizations.dart';

/// カレンダーを表示
class CalendarDialog extends HookConsumerWidget {
  /// カレンダーを表示
  const CalendarDialog({
    super.key,
    required this.dateController,
    required this.callBack,
  });

  /// 日付を表示するコントローラ
  final TextEditingController dateController;

  /// コールバック
  final VoidCallback callBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final selectedDate = useState<DateTime?>(null);

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TableCalendar<dynamic>(
            focusedDay: selectedDate.value ?? DateTime.now(),
            firstDay: DateTime(1900),
            lastDay: DateTime(2100),
            locale: ref.watch(localeProvider) == const Locale('ja')
                ? 'ja_JP'
                : 'en_US',
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate.value, day);
            },
            onDaySelected: (selected, focused) {
              selectedDate.value = selected;
              dateController.text = dateFormat.format(selected);
              Navigator.of(context).pop();
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: theme.appColors.green,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: theme.appColors.grey.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          hSpace(height: 16),
          DialogSecondaryButton(
            screen: 'CalendarDialog',
            text: localizations.close,
            width: getScreenSize(context).width * 0.4,
            callback: callBack,
          ),
          hSpace(height: 16),
        ],
      ),
    );
  }
}
