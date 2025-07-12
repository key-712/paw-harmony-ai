# 多言語対応ルール

このドキュメントは、プロジェクトにおける多言語対応のルールを定めたものです。

## 1. 基本方針

- **対応言語**: 現在の対応言語は日本語と英語です。
- **デフォルト言語**: 英語をデフォルト言語（フォールバック言語）とします。
- **翻訳ファイル形式**: arb（Application Resource Bundle）形式を使用します。

## 2. ファイル構成

- **翻訳ファイル**: `lib/l10n/` ディレクトリに配置します。
  - `app_en.arb`: 英語の翻訳ファイル（テンプレート）
  - `app_ja.arb`: 日本語の翻訳ファイル
- **設定ファイル**: `l10n.yaml` で多言語対応の設定を管理します。

## 3. 翻訳キーの命名規則

- **形式**: `camelCase` を使用します。
- **命名**: 翻訳対象のテキストの内容が推測できる、具体的で分かりやすい名前を付けます。
  - 例: `welcomeMessage`, `networkError`
- **プレフィックス**: 画面や機能ごとにプレフィックスを付けることを推奨します。
  - 例: `recommendAppNameMinesweeper`, `rateDogReaction`

## 4. 翻訳作業フロー

1. **テキストの追加・変更**:
   - UI上に新しいテキストを追加、または既存のテキストを変更する場合は、まず `lib/l10n/app_en.arb` に英語のテキストと対応するキーを追加・更新します。
   - この際、他の翻訳者にも分かりやすいように、`@key` のdescriptionを追加することを推奨します。
     ```json
     "key": "value",
     "@key": {
       "description": "A description of what this key is used for."
     }
     ```

2. **日本語への翻訳**:
   - `app_en.arb` に追加・更新したキーと値を `app_ja.arb` にコピーし、値を日本語に翻訳します。
   - 日本語翻訳時も同様にdescriptionを追加します。

3. **コード生成**:
   - ターミナルで以下のコマンドを実行し、`app_localizations.dart` を自動生成・更新します。
     ```bash
     fvm flutter gen-l10n
     ```

4. **コードでの使用**:
   - **インポート**: `AppLocalizations` は以下のパスでインポートします。
     ```dart
     import '../l10n/app_localizations.dart';
     ```
   - **使用**: `BuildContext` を介して `AppLocalizations` を利用します。
     ```dart
     // 推奨される使用方法
     final l10n = AppLocalizations.of(context)!;
     Text(l10n.welcomeMessage)
     ```
   - **注意**: `AppLocalizations.of(context)!` の `!` を必ず付けて使用してください。
   - `AppLocalizations.of(context)!` が長くなるため、頻繁に利用するクラスでは以下のように変数に格納することを推奨します。
     ```dart
     final l10n = AppLocalizations.of(context)!;
     Text(l10n.welcomeMessage)
     ```

## 5. 翻訳品質管理

### 5.1 翻訳チェックリスト

- [ ] すべてのキーが両言語で存在する
- [ ] 翻訳が自然で分かりやすい
- [ ] 敬語の使い方が統一されている
- [ ] 専門用語の翻訳が統一されている
- [ ] 文字数制限を考慮している
- [ ] 文化的な配慮がされている

### 5.2 翻訳レビュープロセス

1. **初回翻訳**: 開発者が英語から日本語に翻訳
2. **レビュー**: ネイティブスピーカーによる翻訳レビュー
3. **修正**: レビュー結果に基づく翻訳修正
4. **最終確認**: 最終的な翻訳品質の確認

## 6. パラメータの使用

### 6.1 基本的なパラメータ

動的な値をテキストに埋め込む場合は、プレースホルダーを使用します。

```json
// .arb ファイル
"welcomeMessage": "Welcome {userName}!"
```

```dart
// Dartコード
final l10n = AppLocalizations.of(context)!;
l10n.welcomeMessage('John')
```

### 6.2 複数パラメータ

複数のパラメータがある場合は、順序を明確にします。

```json
"slackMessage": "Confirmation!\nAppName: {appName}\nSubject: {subject}\nContent: {content}"
```

### 6.3 数値フォーマット

数値のフォーマットは、ロケールに応じて適切に表示します。

```json
"minutes": "{minutes} min",
"hours": "{hours}h"
```

## 7. 日付・時刻の翻訳

### 7.1 日付フォーマット

```json
"formattedDate": "{month} {date}"
```

### 7.2 曜日の翻訳

```json
"sunday": "Sun",
"monday": "Mon",
// ...
```

## 8. エラーメッセージの翻訳

### 8.1 エラーメッセージの構造

エラーメッセージは以下の構造で統一します：

1. **エラーの種類**: 何が起きたかを簡潔に説明
2. **原因**: なぜ起きたかの説明
3. **解決方法**: ユーザーが取るべき行動

```json
"networkErrorContent": "Could not connect to the network.\nPlease check your connection."
```

### 8.2 エラーメッセージの分類

- **ネットワークエラー**: 接続に関する問題
- **認証エラー**: ログイン・認証に関する問題
- **サーバーエラー**: サーバー側の問題
- **クライアントエラー**: ユーザー入力に関する問題

## 9. 注意事項

### 9.1 翻訳漏れの防止

- `app_en.arb` にキーを追加したら、必ずすべての対応言語の `.arb` ファイル（現在は `app_ja.arb`）にも同じキーを追加し、翻訳を行ってください。
- 翻訳が未完了の場合は、空文字ではなく、一旦英語のテキストを入れておくなどして、表示が崩れないようにしてください。

### 9.2 文字数制限

- 日本語は英語に比べて文字数が多くなる傾向があります。
- UIレイアウトを考慮して、適切な文字数制限を設けてください。

### 9.3 文化的配慮

- 文化的な違いを考慮した翻訳を行ってください。
- 敬語の使い方や表現の丁寧さを統一してください。

### 9.4 一貫性の維持

- 同じ概念を表す単語は、一貫した翻訳を使用してください。
- 専門用語やUI用語の翻訳は統一してください。

## 10. ツールとリソース

### 10.1 推奨ツール

- **翻訳メモリ**: 過去の翻訳を再利用
- **用語集**: 専門用語の統一
- **翻訳チェッカー**: 翻訳品質の確認

### 10.2 参考リソース

- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-internationalization/internationalization)
- [Material Design Localization](https://material.io/design/usability/accessibility.html#language)

## 11. 品質保証

### 11.1 自動チェック

- 翻訳ファイルの構文チェック
- キーの存在確認
- パラメータの整合性確認

### 11.2 手動チェック

- ネイティブスピーカーによるレビュー
- 実際のアプリでの表示確認
- ユーザビリティテスト

## 12. 継続的改善

### 12.1 フィードバック収集

- ユーザーからの翻訳に関するフィードバックを収集
- 改善点の特定と対応

### 12.2 定期的な見直し

- 翻訳品質の定期的な評価
- 翻訳ルールの更新
- 新しい言語への対応検討

## 13. コーディング規約

### 13.1 インポート規約

- `AppLocalizations` のインポートは以下のパスを使用してください：
  ```dart
  import '../l10n/app_localizations.dart';
  ```
- 相対パスを使用し、`package:flutter_gen/gen_l10n/app_localizations.dart` は使用しないでください。

### 13.2 使用方法規約

- `AppLocalizations.of(context)!` の `!` を必ず付けて使用してください。
- **変数名の統一**: `AppLocalizations.of(context)!` を変数に格納する場合は、必ず `final l10n` として定義してください。
- 頻繁に使用する場合は変数に格納してください：
  ```dart
  final l10n = AppLocalizations.of(context)!;
  ```
- **禁止事項**:
  - `final localizations` は使用しないでください
  - `final l10n = AppLocalizations.of(context)`（`!`なし）は使用しないでください
  - 直接 `AppLocalizations.of(context)!.keyName` の使用は避けてください（短い使用の場合は除く）

### 13.3 統一ルール

#### 13.3.1 変数名の統一
- `AppLocalizations.of(context)!` を変数に格納する場合は、必ず `final l10n` を使用してください
- 例：
  ```dart
  // ✅ 正しい使用方法
  final l10n = AppLocalizations.of(context)!;
  
  // ❌ 間違った使用方法
  final localizations = AppLocalizations.of(context)!;
  final l10n = AppLocalizations.of(context);
  ```

#### 13.3.2 使用パターンの統一
- 複数回使用する場合は必ず変数に格納してください
- 1回だけの使用の場合は直接使用も可能です
- 例：
  ```dart
  // ✅ 複数回使用する場合
  final l10n = AppLocalizations.of(context)!;
  Text(l10n.welcomeMessage)
  Text(l10n.errorMessage)
  
  // ✅ 1回だけの使用の場合
  Text(AppLocalizations.of(context)!.welcomeMessage)
  ```

### 13.3 エラーハンドリング

- `AppLocalizations.of(context)` が `null` を返す可能性がある場合は、適切なフォールバック値を設定してください。
- ただし、通常の使用では `!` を使用してnullチェックをスキップしてください。
