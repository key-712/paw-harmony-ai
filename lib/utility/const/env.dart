/// dartで利用する環境変数を管理するクラス
/// ※Dart-define-from-file引数で渡されるデータ(dart_envフォルダ配下のファイル)が元データ
class Env {
  /// フレーバー
  static const flavor = String.fromEnvironment('flavor');

  /// アプリIDサフィックス
  static const appIdSuffix = String.fromEnvironment('appIdSuffix');

  /// アプリリンク
  static const appLinks = String.fromEnvironment('appLinks');

  /// ユニバーサルリンク
  static const universalLinks = String.fromEnvironment('universalLinks');

  /// カスタムURLスキーム
  static const customUrlScheme = String.fromEnvironment('customUrlScheme');

  /// バナー広告ID(iOS)
  static const iOSBannerAdUnitId = String.fromEnvironment('iOSBannerAdUnitId');

  /// インタースティシャル広告ID(iOS)
  static const iOSInterstitialAdUnitId = String.fromEnvironment(
    'iOSInterstitialAdUnitId',
  );

  /// バナー広告ID(Android)
  static const androidBannerAdUnitId = String.fromEnvironment(
    'androidBannerAdUnitId',
  );

  /// インタースティシャル広告ID(Android)
  static const androidInterstitialAdUnitId = String.fromEnvironment(
    'androidInterstitialAdUnitId',
  );

  /// SlackWebhookのURL
  static const slackWebhookUrl = String.fromEnvironment('slackWebhookUrl');

  /// RevenueCat APIキー(Apple)
  static const revenueCatAppleApiKey = String.fromEnvironment(
    'revenueCatAppleApiKey',
  );

  /// RevenueCat APIキー(Google)
  static const revenueCatGoogleApiKey = String.fromEnvironment(
    'revenueCatGoogleApiKey',
  );
}
