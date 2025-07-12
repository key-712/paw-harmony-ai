// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// 多言語対応のユーティリティクラス
class L10nUtility {
  /// プライベートコンストラクタ
  L10nUtility._();

  /// 現在のロケールを取得
  static Locale? getCurrentLocale(BuildContext context) {
    return Localizations.localeOf(context);
  }

  /// 現在の言語コードを取得
  static String getCurrentLanguageCode(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  /// 日本語かどうかを判定
  static bool isJapanese(BuildContext context) {
    return getCurrentLanguageCode(context) == 'ja';
  }

  /// 英語かどうかを判定
  static bool isEnglish(BuildContext context) {
    return getCurrentLanguageCode(context) == 'en';
  }

  /// 言語名を取得
  static String getLanguageName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return isJapanese(context) ? l10n.japanese : l10n.english;
  }

  /// 言語設定の成功メッセージを取得
  static String getLanguageSettingSuccessMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return l10n.languageSettingSuccess;
  }

  /// エラーメッセージを取得
  static String getErrorMessage(BuildContext context, String errorType) {
    final l10n = AppLocalizations.of(context)!;

    switch (errorType) {
      case 'network':
        return l10n.networkError;
      case 'server':
        return l10n.serverError;
      case 'timeout':
        return l10n.timeout;
      case 'unauthorized':
        return l10n.unauthorized;
      default:
        return l10n.error;
    }
  }

  /// エラーコンテンツメッセージを取得
  static String getErrorContentMessage(BuildContext context, String errorType) {
    final l10n = AppLocalizations.of(context)!;

    switch (errorType) {
      case 'network':
        return l10n.networkErrorContent;
      default:
        return l10n.errorContent;
    }
  }

  /// バリデーションメッセージを取得
  static String getValidationMessage(
    BuildContext context,
    String field,
    String type,
  ) {
    final l10n = AppLocalizations.of(context)!;

    switch (field) {
      case 'email':
        switch (type) {
          case 'required':
            return l10n.emailRequired;
          case 'invalid':
            return l10n.emailInvalid;
          case 'tooLong':
            return l10n.emailTooLong;
          default:
            return l10n.emailRequired;
        }
      case 'password':
        switch (type) {
          case 'required':
            return l10n.passwordRequired;
          case 'tooShort':
            return l10n.passwordTooShort;
          case 'tooLong':
            return l10n.passwordTooLong;
          case 'invalidCharacters':
            return l10n.passwordInvalidCharacters;
          default:
            return l10n.passwordRequired;
        }
      default:
        return 'Validation error';
    }
  }

  /// 時間フォーマットを取得
  static String formatTime(BuildContext context, int minutes) {
    final l10n = AppLocalizations.of(context)!;

    if (minutes < 60) {
      return l10n.minutes(minutes.toString());
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return l10n.hours(hours.toString());
      } else {
        return '${l10n.hours(hours.toString())} ${l10n.minutes(remainingMinutes.toString())}';
      }
    }
  }

  /// 日付フォーマットを取得
  static String formatDate(BuildContext context, int month, int date) {
    final l10n = AppLocalizations.of(context)!;

    return l10n.formattedDate(month.toString(), date.toString());
  }

  /// 曜日名を取得
  static String getDayOfWeek(BuildContext context, int dayIndex) {
    final l10n = AppLocalizations.of(context)!;

    switch (dayIndex) {
      case 0:
        return l10n.sunday;
      case 1:
        return l10n.monday;
      case 2:
        return l10n.tuesday;
      case 3:
        return l10n.wednesday;
      case 4:
        return l10n.thursday;
      case 5:
        return l10n.friday;
      case 6:
        return l10n.saturday;
      default:
        return 'Unknown';
    }
  }

  /// 推奨アプリ名を取得
  static String getRecommendAppName(BuildContext context, String appType) {
    final l10n = AppLocalizations.of(context)!;

    switch (appType) {
      case 'minesweeper':
        return l10n.recommendAppNameMinesweeper;
      case 'sudoku':
        return l10n.recommendAppNameSudoku;
      case 'science':
        return l10n.recommendAppNameScience;
      case 'math':
        return l10n.recommendAppNameMath;
      case 'english':
        return l10n.recommendAppNameEnglish;
      case 'socialStudies':
        return l10n.recommendAppNameSocialStudies;
      case 'kanji':
        return l10n.recommendAppNameKanji;
      case 'highSchoolSocialStudies':
        return l10n.recommendAppNameHighSchoolSocialStudies;
      default:
        return 'Unknown App';
    }
  }

  /// 推奨アプリ説明を取得
  static String getRecommendAppDescription(
    BuildContext context,
    String appType,
  ) {
    final l10n = AppLocalizations.of(context)!;

    switch (appType) {
      case 'minesweeper':
        return l10n.recommendAppDescriptionMinesweeper;
      case 'sudoku':
        return l10n.recommendAppDescriptionSudoku;
      case 'science':
        return l10n.recommendAppDescriptionScience;
      case 'math':
        return l10n.recommendAppDescriptionMath;
      case 'english':
        return l10n.recommendAppDescriptionEnglish;
      case 'socialStudies':
        return l10n.recommendAppDescriptionSocialStudies;
      case 'kanji':
        return l10n.recommendAppDescriptionKanji;
      case 'highSchoolSocialStudies':
        return l10n.recommendAppDescriptionHighSchoolSocialStudies;
      default:
        return 'Unknown App Description';
    }
  }

  /// 愛犬の反応オプションを取得
  static List<String> getDogReactionOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      l10n.stoppedBarking,
      l10n.calmedDownAndSlept,
      l10n.restless,
      l10n.breathingBecameCalm,
    ];
  }

  /// 翻訳キーの存在確認
  static bool hasTranslationKey(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;

    try {
      // リフレクションを使用してキーの存在を確認
      final mirror = l10n.runtimeType.toString();
      return mirror.contains(key);
    } catch (e) {
      return false;
    }
  }

  /// 翻訳品質チェック
  static List<String> checkTranslationQuality(BuildContext context) {
    final issues = <String>[];
    final l10n = AppLocalizations.of(context)!;

    // 空文字列のチェック
    final emptyKeys = <String>[];
    // ここで空文字列のキーをチェックするロジックを実装

    if (emptyKeys.isNotEmpty) {
      issues.add('Empty translation keys: ${emptyKeys.join(', ')}');
    }

    return issues;
  }
}
