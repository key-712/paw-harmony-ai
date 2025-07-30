# Paw Harmony - Flutter アプリケーション

## プロジェクト概要
- **フレームワーク**: Flutter (Dart)
- **プラットフォーム**: iOS, Android
- **状態管理**: Riverpod
- **ルーティング**: Go Router
- **バックエンド**: Firebase (Firestore, Auth, Functions, etc.)
- **広告**: Google Mobile Ads
- **課金**: RevenueCat
- **AI**: Google AI API

## 開発環境
- **Flutter SDK**: >=3.7.0 <4.0.0
- **Dart SDK**: 3.7.0以上
- **iOS**: Xcode が必要
- **Android**: Android Studio が必要

## 主要な依存関係
- `hooks_riverpod`: 状態管理
- `go_router`: ルーティング
- `firebase_core`, `firebase_auth`, `firebase_firestore`: Firebase統合
- `google_mobile_ads`: 広告
- `purchases_flutter`: 課金
- `just_audio`: 音声再生
- `flutter_hooks`: React風のフック

## 環境設定
- **開発環境**: `dart_env/dev.env`
- **本番環境**: `dart_env/prod.env`
- **FVM**: Flutterバージョン管理

## ビルドコマンド
```bash
# 開発環境で実行
make run-dev

# 本番環境で実行
make run-prod

# コード生成
make setup

# テスト実行
make test
```

## 重要なファイル
- `lib/main.dart`: アプリケーションのエントリーポイント
- `lib/app.dart`: アプリケーションの設定
- `lib/route/route.dart`: ルーティング設定
- `lib/provider/`: Riverpodプロバイダー
- `lib/screen/`: 画面コンポーネント
- `lib/component/`: 再利用可能なコンポーネント

## 注意事項
- Firebase設定ファイルは自動生成されます
- 環境変数は`dart_env/`ディレクトリで管理
- iOSビルドにはCocoaPodsが必要
- AndroidビルドにはGradleが必要 