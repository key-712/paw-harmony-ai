import 'package:flutter/material.dart';

import '../../import/model.dart';
import '../../l10n/app_localizations.dart';

/// おすすめアプリのリスト
List<AppInfo> getRecommendedApps(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return <AppInfo>[
    AppInfo(
      appName: l10n.recommendAppNameMinesweeper,
      appDescription: l10n.recommendAppDescriptionMinesweeper,
      iconPath:
          'https://drive.google.com/uc?export=view&id=1tY3E2p7E-RmvF4VTimt6ApDyJ_ST-kcO',
      appStoreUrl: 'https://apps.apple.com/jp/app/id6738711205',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.crelve.minesweeper.mobile.prod',
    ),
    AppInfo(
      appName: l10n.recommendAppNameSudoku,
      appDescription: l10n.recommendAppDescriptionSudoku,
      iconPath:
          'https://drive.google.com/uc?export=view&id=1nPtFVL3ZaLh5xEVTcsL_H9iQufItBa5M',
      appStoreUrl: 'https://apps.apple.com/jp/app/id6738382462',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.crelve.sudoku.quest',
    ),
    AppInfo(
      appName: l10n.recommendAppNameScience,
      appDescription: l10n.recommendAppDescriptionScience,
      iconPath:
          'https://drive.google.com/uc?export=view&id=1WMd32GVdFD7SWIYr75qb5NT5_U7ON8Vh',
      appStoreUrl: 'https://apps.apple.com/jp/app/id6670769894',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=crelve.jh.science.mobile.prod',
    ),
    AppInfo(
      appName: l10n.recommendAppNameMath,
      appDescription: l10n.recommendAppDescriptionMath,
      iconPath:
          'https://drive.google.com/uc?export=view&id=1C1fKk4N5YaGntBvrIvAePYJA1XVozSou',
      appStoreUrl: 'https://apps.apple.com/jp/app/id6535654198',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=crelve.jh.math.mobile.prod',
    ),
    AppInfo(
      appName: l10n.recommendAppNameEnglish,
      appDescription: l10n.recommendAppDescriptionEnglish,
      iconPath:
          'https://drive.google.com/uc?export=view&id=1yzTsRP8tPrADUQoVPGHB9uwswX-LKLL9',
      appStoreUrl: 'https://apps.apple.com/jp/app/id6670703273',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=crelve.jh.english.mobile.prod',
    ),
    AppInfo(
      appName: l10n.recommendAppNameSocialStudies,
      appDescription: l10n.recommendAppDescriptionSocialStudies,
      iconPath:
          'https://drive.google.com/uc?export=view&id=106E-MfWNgLghxzq_4QpwIoHU24WV-ika',
      appStoreUrl: 'https://apps.apple.com/jp/app/id6730126937',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=crelve.jh.society.mobile.prod',
    ),
    AppInfo(
      appName: l10n.recommendAppNameKanji,
      appDescription: l10n.recommendAppDescriptionKanji,
      iconPath:
          'https://drive.google.com/uc?export=view&id=138U3uF3nHhO3FkOi4KYN0RpsjQq0y-lq',
      appStoreUrl: 'https://apps.apple.com/jp/app/id6714472898',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=crelve.jh.kanji.mobile.prod',
    ),
    AppInfo(
      appName: l10n.recommendAppNameHighSchoolSocialStudies,
      appDescription: l10n.recommendAppDescriptionHighSchoolSocialStudies,
      iconPath:
          'https://drive.google.com/uc?export=view&id=1vtTMZlPZuriolRuQGpB9xrA75VV8fyMY',
      appStoreUrl: 'https://apps.apple.com/jp/app/id6736946222',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=crelve.hs.society.mobile.prod',
    ),
  ];
}
