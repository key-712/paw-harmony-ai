// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../import/provider.dart';
import '../import/utility.dart';

/// ratingDialogDateに最新の日付をセットします
Future<void> saveCurrentDate({required WidgetRef ref}) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final currentDate = DateTime.now().toIso8601String();
  await prefs.setString(SharedPreferencesKeys.ratingDialogDate, currentDate);
}

/// ratingDialogShownにtrueをセットします
Future<void> setRatingDialogShown({required WidgetRef ref}) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  await prefs.setBool(SharedPreferencesKeys.ratingDialogShown, true);
}

/// ratingDialogShownがtrueかを判定します
Future<bool> hasRatingDialogShown({required WidgetRef ref}) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(SharedPreferencesKeys.ratingDialogShown) ?? false;
}

/// 日付を "MM月dd日" の形式にフォーマット
String formattedDate({required BuildContext context, required DateTime date}) {
  final localizations = AppLocalizations.of(context)!;
  final month = DateFormat.MMM(localizations.localeName).format(date);
  final day = date.day;
  return localizations.formattedDate(month, day);
}

/// 日付を "yyyy/MM/dd" の形式にフォーマット
final dateFormat = DateFormat('yyyy/MM/dd');
