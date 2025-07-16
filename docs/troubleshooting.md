# トラブルシューティングガイド

## Google AI APIキー関連のエラー

### エラー: "Method doesn't allow unregistered callers"

このエラーは、Google AI APIキーが正しく設定されていないか、無効であることを示しています。

#### 解決手順

1. **Google AI StudioでAPIキーを取得**
   - [Google AI Studio](https://ai.google.dev/)にアクセス
   - アカウントにログイン
   - APIキーを生成
   - 生成されたAPIキーをコピー

2. **環境変数ファイルの更新**
   ```bash
   # dart_env/dev.env
   googleAiApiKey="AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   
   # dart_env/prod.env
   googleAiApiKey="AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   ```

3. **アプリの再起動**
   ```bash
   flutter run --dart-define-from-file=dart_env/dev.env
   ```

4. **設定の確認**
   - AI音楽生成画面の設定ボタン（⚙️）をタップ
   - APIキーの設定状況を確認

#### よくある問題

**問題**: APIキーが「your_google_ai_api_key_here」のまま
**解決**: 実際のAPIキーに置き換えてください

**問題**: APIキーが空文字列
**解決**: 有効なAPIキーを設定してください

**問題**: 403エラーが発生
**解決**: APIキーが正しく設定されているか確認してください

### エラー: "Network error"

ネットワーク接続の問題です。

#### 解決手順

1. **インターネット接続の確認**
2. **VPNの無効化**（使用している場合）
3. **ファイアウォールの確認**
4. **しばらく待ってから再試行**

### エラー: "Timeout"

音楽生成に時間がかかりすぎています。

#### 解決手順

1. **しばらく待ってから再試行**
2. **ネットワーク接続の確認**
3. **Google AI APIの状態確認**

## 一般的なトラブルシューティング

### アプリが起動しない

1. **依存関係の更新**
   ```bash
   flutter pub get
   ```

2. **キャッシュのクリア**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **環境変数の確認**
   - `dart_env/dev.env`ファイルが存在するか確認
   - 必要な環境変数が設定されているか確認

### 音楽生成が失敗する

1. **APIキーの確認**
   - 設定画面でAPIキーの状態を確認
   - 正しいAPIキーが設定されているか確認

2. **ネットワーク接続の確認**
   - インターネットに接続されているか確認
   - ファイアウォールの設定を確認

3. **ログの確認**
   - コンソールに表示されるエラーメッセージを確認
   - エラーの詳細を確認

### 音楽が再生されない

1. **音声ファイルの確認**
   - 生成された音楽ファイルが正しく保存されているか確認
   - ファイルサイズが0でないか確認

2. **音声プレーヤーの確認**
   - デバイスの音量設定を確認
   - 他のアプリで音声が再生されるか確認

## サポート

問題が解決しない場合は、以下の情報を添えてサポートチームに連絡してください：

1. **エラーメッセージの全文**
2. **使用しているデバイスとOS**
3. **アプリのバージョン**
4. **実行した手順の詳細**
5. **スクリーンショット**（可能な場合）

## 参考資料

- [Google AI Studio](https://ai.google.dev/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Google AI Lyria RealTime Documentation](https://ai.google.dev/gemini-api/docs/music-generation?hl=ja) 