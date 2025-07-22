#!/bin/bash

# エラー時に停止
set -e

# Flutter環境のセットアップ
echo "Flutter環境をセットアップ中..."

# Flutterのインストール（もし存在しない場合）
if ! command -v flutter &> /dev/null; then
    echo "Flutterをインストール中..."
    
    # 必要な依存関係をインストール
    sudo apt-get update
    sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
    
    # Flutter SDKをダウンロード（より新しいバージョン）
    FLUTTER_VERSION="3.24.5"
    FLUTTER_HOME="/opt/flutter"
    
    # Flutter SDKをダウンロードしてインストール
    cd /tmp
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$FLUTTER_VERSION-stable.tar.xz
    sudo tar xf flutter_linux_$FLUTTER_VERSION-stable.tar.xz -C /opt
    sudo chown -R $(id -u):$(id -g) $FLUTTER_HOME
    
    # PATHにFlutterを追加
    echo 'export PATH="$FLUTTER_HOME/bin:$PATH"' >> ~/.bashrc
    export PATH="$FLUTTER_HOME/bin:$PATH"
    
    # Flutterを最新版にアップグレード
    echo "Flutterを最新版にアップグレード中..."
    flutter upgrade --force
    
    echo "Flutterのインストールが完了しました"
else
    echo "Flutterは既にインストールされています。バージョンを確認中..."
    # 既存のFlutterを最新版にアップグレード
    flutter upgrade --force
fi

# Flutter doctorで環境を確認
echo "Flutter環境を確認中..."
flutter doctor || echo "Flutter doctorで警告が発生しましたが、続行します"

# Dart SDKのバージョンを確認
echo "Dart SDKのバージョンを確認中..."
dart --version

# プロジェクトディレクトリに移動
cd /app

# Flutterの依存関係を取得
echo "Flutter依存関係を取得中..."
flutter pub get

# コード生成の実行
echo "コード生成を実行中..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# ローカライゼーションの生成
echo "ローカライゼーションを生成中..."
flutter gen-l10n --arb-dir=lib/l10n --template-arb-file=app_en.arb --output-localization-file=app_localizations.dart --output-class=AppLocalizations --synthetic-package=false

# 開発環境の設定
echo "Flutter開発環境の設定が完了しました"
echo ""
echo "利用可能なコマンド:"
echo "  - flutter run (Androidエミュレータまたはデバイスで実行)"
echo "  - flutter build apk (Android APKビルド)"
echo "  - flutter test (テスト実行)"
echo "  - flutter doctor (環境確認)"
echo "  - flutter gen-l10n (ローカライゼーション生成)"
echo "  - flutter packages pub run build_runner build (コード生成)"
echo ""
echo "注意事項:"
echo "  - iOSビルドはJules環境では利用できません（Linuxベースのため）"
echo "  - Android開発にはAndroid SDKが必要です"
echo "  - 環境変数は ~/.bashrc に保存されています"
echo ""
echo "環境確認:"
echo "  - Flutter: $(flutter --version | head -n 1)"
echo "  - Dart: $(dart --version | head -n 1)"
echo "  - プロジェクトディレクトリ: $(pwd)" 