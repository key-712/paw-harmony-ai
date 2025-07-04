/// おすすめアプリの情報に関するクラス
class AppInfo {
  /// おすすめアプリの情報に関するクラス
  AppInfo({
    required this.appName,
    required this.appDescription,
    required this.iconPath,
    required this.appStoreUrl,
    required this.playStoreUrl,
  });

  /// アプリ名
  final String appName;

  /// アプリの説明
  final String appDescription;

  /// アイコンのパス
  final String iconPath;

  /// App StoreのURL
  final String appStoreUrl;

  /// Play StoreのURL
  final String playStoreUrl;
}
