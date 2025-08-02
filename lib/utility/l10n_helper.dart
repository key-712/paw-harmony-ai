import '../l10n/app_localizations.dart';

/// l10nの多言語キーから値を取得するヘルパー関数
///
/// [l10n] AppLocalizationsインスタンス
/// [key] 取得したい多言語キー
/// Returns 多言語文字列
String getL10nValue(AppLocalizations l10n, String key) {
  switch (key) {
    // 性格
    case 'personalityEasygoing':
      return l10n.personalityEasygoing;
    case 'personalityActive':
      return l10n.personalityActive;
    case 'personalityTimid':
      return l10n.personalityTimid;
    case 'personalitySociable':
      return l10n.personalitySociable;
    case 'personalityAffectionate':
      return l10n.personalityAffectionate;
    case 'personalityMyPace':
      return l10n.personalityMyPace;

    // 品種
    case 'breedToyPoodle':
      return l10n.breedToyPoodle;
    case 'breedChihuahua':
      return l10n.breedChihuahua;
    case 'breedShiba':
      return l10n.breedShiba;
    case 'breedMiniatureDachshund':
      return l10n.breedMiniatureDachshund;
    case 'breedPomeranian':
      return l10n.breedPomeranian;
    case 'breedFrenchBulldog':
      return l10n.breedFrenchBulldog;
    case 'breedGoldenRetriever':
      return l10n.breedGoldenRetriever;
    case 'breedLabradorRetriever':
      return l10n.breedLabradorRetriever;
    case 'breedMix':
      return l10n.breedMix;
    case 'breedOther':
      return l10n.breedOther;
    case 'breedAkita':
      return l10n.breedAkita;
    case 'breedMaltese':
      return l10n.breedMaltese;
    case 'breedSiberianHusky':
      return l10n.breedSiberianHusky;
    case 'breedAlaskanMalamute':
      return l10n.breedAlaskanMalamute;
    case 'breedBorderCollie':
      return l10n.breedBorderCollie;
    case 'breedAustralianShepherd':
      return l10n.breedAustralianShepherd;
    case 'breedBulldog':
      return l10n.breedBulldog;
    case 'breedPug':
      return l10n.breedPug;
    case 'breedGermanShepherd':
      return l10n.breedGermanShepherd;
    case 'breedDoberman':
      return l10n.breedDoberman;
    case 'breedBeagle':
      return l10n.breedBeagle;
    case 'breedDachshund':
      return l10n.breedDachshund;
    case 'breedSamoyed':
      return l10n.breedSamoyed;
    case 'breedGreatPyrenees':
      return l10n.breedGreatPyrenees;
    case 'breedCorgi':
      return l10n.breedCorgi;
    case 'breedWelshCorgi':
      return l10n.breedWelshCorgi;
    case 'breedShihTzu':
      return l10n.breedShihTzu;
    case 'breedPekingese':
      return l10n.breedPekingese;
    case 'breedBerneseMountainDog':
      return l10n.breedBerneseMountainDog;
    case 'breedSaintBernard':
      return l10n.breedSaintBernard;
    case 'breedBostonTerrier':
      return l10n.breedBostonTerrier;
    case 'breedWestHighlandWhiteTerrier':
      return l10n.breedWestHighlandWhiteTerrier;
    case 'breedYorkshireTerrier':
      return l10n.breedYorkshireTerrier;
    case 'breedNewfoundland':
      return l10n.breedNewfoundland;
    case 'breedRetriever':
      return l10n.breedRetriever;
    case 'breedShetlandSheepdog':
      return l10n.breedShetlandSheepdog;
    case 'breedCollie':
      return l10n.breedCollie;
    case 'breedBassetHound':
      return l10n.breedBassetHound;
    case 'breedBloodhound':
      return l10n.breedBloodhound;
    case 'breedGreyhound':
      return l10n.breedGreyhound;
    case 'breedWhippet':
      return l10n.breedWhippet;
    default:
      return key;
  }
}
