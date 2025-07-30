# RevenueCat設定ガイド

## 概要
このドキュメントは、Paw HarmonyアプリのRevenueCat設定に関する問題を解決するためのガイドです。

## 現在の問題
- エラーコード23: CONFIGURATION_ERROR
- RevenueCatダッシュボードで商品が設定されていない
- App Store Connectとの連携が不完全

## 解決手順

### 1. RevenueCatダッシュボードでの設定

#### 1.1 プロジェクトの作成
1. [RevenueCatダッシュボード](https://app.revenuecat.com/)にアクセス
2. 新しいプロジェクトを作成
3. プロジェクト名: "Paw Harmony"

#### 1.2 APIキーの取得
1. プロジェクト設定 → API Keys
2. iOS用のAPIキーをコピー
3. Android用のAPIキーをコピー

#### 1.3 商品の設定
1. Products → Add Product
2. 商品IDを設定（例: `premium_monthly`）
3. 商品名を設定（例: "Premium Monthly"）
4. 価格を設定

#### 1.4 オファリングの設定
1. Offerings → Add Offering
2. オファリングIDを設定（例: `default`）
3. オファリング名を設定（例: "Default Offering"）
4. 商品をオファリングに追加

### 2. App Store Connectでの設定

#### 2.1 アプリ内課金商品の作成
1. App Store Connectにログイン
2. アプリを選択
3. 機能 → アプリ内課金
4. 新しい商品を追加
5. 商品IDをRevenueCatと同じに設定

#### 2.2 商品の詳細設定
- 商品タイプ: 自動更新型サブスクリプション
- 期間: 月次
- 価格: 適切な価格を設定
- 地域: 対象地域を選択

### 3. 環境変数の更新

#### 3.1 本番環境
```bash
# dart_env/prod.env を更新
revenueCatAppleApiKey="実際のApple APIキー"
revenueCatGoogleApiKey="実際のGoogle APIキー"
```

#### 3.2 開発環境
```bash
# dart_env/dev.env を更新
revenueCatAppleApiKey="開発用のApple APIキー"
revenueCatGoogleApiKey="開発用のGoogle APIキー"
```

### 4. コードの修正

#### 4.1 エラーハンドリングの改善
現在のコードは適切にエラーハンドリングされていますが、以下の点を確認：

1. `lib/main.dart`の`_initializePurchases()`関数
2. `lib/screen/subscription/subscription_setting_screen.dart`のエラーハンドリング

#### 4.2 デバッグ情報の追加
```dart
// デバッグ用のログを追加
logger.i('RevenueCat API Key: ${appleApiKey.substring(0, 10)}...');
logger.i('Platform: ${Platform.operatingSystem}');
```

### 5. テスト手順

#### 5.1 開発環境でのテスト
1. サンドボックス環境でテスト
2. テスト用アカウントでログイン
3. 課金機能をテスト

#### 5.2 本番環境でのテスト
1. App Store Connectで商品を承認
2. 実際の課金をテスト
3. レシート検証を確認

## 注意事項

1. **APIキーの管理**
   - APIキーは機密情報として扱う
   - バージョン管理システムにコミットしない
   - 環境ごとに適切なキーを使用

2. **商品IDの一貫性**
   - RevenueCat、App Store Connect、Google Play Consoleで同じ商品IDを使用
   - 商品IDは変更不可なので慎重に設定

3. **テスト環境**
   - 開発時はサンドボックス環境を使用
   - テスト用アカウントで課金テストを実行

## トラブルシューティング

### よくある問題

1. **エラーコード23**
   - APIキーが正しく設定されているか確認
   - 商品がRevenueCatダッシュボードで設定されているか確認

2. **オファリングが空**
   - オファリングに商品が追加されているか確認
   - 商品IDが正しく設定されているか確認

3. **課金が失敗する**
   - テスト用アカウントでテストしているか確認
   - サンドボックス環境を使用しているか確認

## 参考リンク

- [RevenueCat公式ドキュメント](https://docs.revenuecat.com/)
- [App Store Connect ヘルプ](https://help.apple.com/app-store-connect/)
- [Google Play Console ヘルプ](https://support.google.com/googleplay/android-developer) 