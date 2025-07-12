# プロジェクトルール

## プロジェクト概要

本リポジトリは、Flutter を使用したモバイルアプリケーションのテンプレートです。
iOS・Android 両プラットフォームに対応したモバイルアプリ開発の基盤として使用できます。

## 技術スタック

### フレームワーク・ライブラリ

- **Flutter**: stable バージョン
- **状態管理**: Riverpod（hooks_riverpod）と Flutter Hooks（flutter_hooks）の組み合わせ
- **ルーティング**: GoRouter
- **国際化**: flutter_localizations
- **データ永続化**: SharedPreferences
- **バックエンド**: Firebase（Firestore, Authentication, Analytics, Crashlytics 等）
- **広告**: Google Mobile Ads
- **課金**: RevenueCat（purchases_flutter）
- **通知**: Firebase Cloud Messaging

### 開発ツール

- **コード生成**: build_runner, freezed, json_serializable
- **リント**: flutter_lints, pedantic_mono
- **アイコン生成**: flutter_launcher_icons
- **スプラッシュ画面**: flutter_native_splash

## ディレクトリルール

### フォルダ名の命名規則

- フォルダ名は単数形にしてください。

```sh
// 👎 NG
dart_defines
lib/types

// 👍 OK
dart_define
lib/type
```

### ファイル名の命名規則

- ファイル名に provider は付けないでください。

```sh
// 👎 NG
layer_1_web_view_contents_provider.dart

// 👍 OK
layer_1_web_view_contents.dart
```

- ファイル名に StateNotifier は付けてください。

```sh
// 👎 NG
layer_1_web_view.dart

// 👍 OK
layer_1_web_view_state_notifier.dart
```

### フォルダ分割のガイドライン

- 1 フォルダに目安として１０ファイル以上存在する場合は、フォルダで分割することを検討してください。

### 省略形の使用

- フォルダ名に省略形は使用して構いません。ただし、一般的に使用されている省略形のみ許容します。

**許容される省略形の例**:

- `lib/` (library)
- `src/` (source)
- `util/` (utility)
- `comp/` (component)
- `prov/` (provider)
- `model/` (model)
- `type/` (type)
- `const/` (constant)
- `ext/` (extension)
- `hook/` (hook)
- `route/` (route)
- `theme/` (theme)
- `l10n/` (localization)
- `gen/` (generated)
- `import/` (import)
- `widgetbook/` (widgetbook)

## コード構造

### ディレクトリ構造

```
lib/
├── app.dart                  # メインAppウィジェット
├── main.dart                 # エントリーポイント
├── app_state_notifier.dart   # アプリ状態管理
├── screen/                   # UI画面
│   ├── base_screen.dart      # ベース画面
│   ├── home/                 # ホーム関連画面
│   ├── setting/              # 設定関連画面
│   └── walk_through/         # オンボーディング画面
├── provider/                 # Riverpodステートプロバイダー
│   ├── ad_provider.dart      # 広告関連
│   ├── app_lifecycle_state_notifier.dart # アプリライフサイクル
│   ├── cloud_messaging_provider.dart # プッシュ通知
│   ├── firebase_analytics_provider.dart # 分析
│   ├── go_router_provider.dart # ルーティング
│   ├── loading_state_notifier.dart # ローディング状態
│   ├── locale_provider.dart  # 言語設定
│   ├── purchase_state_notifier.dart # 課金
│   ├── push_notification_state_notifier.dart # 通知設定
│   ├── rating_state_notifier.dart # 評価
│   ├── shared_preferences_provider.dart # データ永続化
│   └── walk_through_state_notifier.dart # オンボーディング
├── model/                    # データモデル
│   ├── app_error.dart        # エラーモデル
│   ├── app_info.dart         # アプリ情報
│   ├── push_notification_setting.dart # 通知設定
│   ├── result.dart           # 結果型
│   └── token.dart            # トークン
├── utility/                  # ユーティリティ関数
│   ├── const/                # 定数定義
│   ├── extension/            # 拡張メソッド
│   ├── logger/               # ログ機能
│   ├── product/              # プロダクト関連
│   ├── validator/            # バリデーション
│   ├── app_tracking_transparency.dart # トラッキング
│   ├── color_utility.dart    # 色ユーティリティ
│   ├── date.dart             # 日付処理
│   ├── file_converter.dart   # ファイル変換
│   ├── format_log_parameters.dart # ログパラメータ
│   ├── handle_cloud_message.dart # クラウドメッセージ
│   ├── is_not_production.dart # 環境判定
│   ├── layout.dart           # レイアウト
│   ├── media_query.dart      # メディアクエリ
│   ├── open_review.dart      # レビュー
│   ├── open_url.dart         # URL起動
│   ├── platform.dart         # プラットフォーム
│   ├── show_local_push_notification.dart # ローカル通知
│   ├── slack.dart            # Slack連携
│   ├── space.dart            # スペース
│   ├── update_checker.dart   # アップデートチェック
│   └── walk_through_contents.dart # オンボーディング内容
├── component/                # 再利用可能なUIコンポーネント
│   ├── button/               # ボタンコンポーネント
│   │   ├── primary_button.dart      # 主要なアクション用ボタン
│   │   ├── secondary_button.dart    # 二次的なアクション用ボタン
│   │   ├── cancel_button.dart       # キャンセルアクション用ボタン
│   │   ├── dialog_primary_button.dart    # ダイアログ内の主要アクション用ボタン
│   │   └── dialog_secondary_button.dart  # ダイアログ内の二次的アクション用ボタン
│   ├── card/                 # カードコンポーネント
│   ├── dialog/               # ダイアログコンポーネント
│   ├── dropdown/             # ドロップダウンコンポーネント
│   ├── form/                 # フォームコンポーネント
│   ├── header/               # ヘッダーコンポーネント
│   ├── layout/               # レイアウトコンポーネント
│   ├── loading/              # ローディングコンポーネント
│   ├── snackbar/             # スナックバーコンポーネント
│   │   ├── snackbar.dart           # 成功メッセージ用スナックバー
│   │   └── alert_snackbar.dart     # エラーメッセージ用スナックバー
│   ├── switch/               # スイッチコンポーネント
│   ├── text/                 # テキストコンポーネント
│   └── widget/               # その他ウィジェット
├── theme/                    # アプリテーマ
│   ├── app_colors.dart       # カラー定義
│   ├── app_text_theme.dart   # テキストテーマ
│   ├── app_theme.dart        # アプリテーマ
│   ├── button_styles.dart    # ボタンスタイル
│   └── font_size.dart        # フォントサイズ
├── type/                     # 型定義
│   ├── log/                  # ログ関連型
│   ├── ad_state.dart         # 広告状態
│   ├── base_state.dart       # 基本状態
│   ├── purchase_state.dart   # 課金状態
│   ├── push_notification_state.dart # 通知状態
│   └── walk_through_state.dart # オンボーディング状態
├── hook/                     # カスタムフック
│   ├── use_ad_initialization.dart # 広告初期化
│   ├── use_handle_page_controller.dart # ページコントローラー
│   ├── use_handle_transit.dart # 画面遷移
│   ├── use_loading_state_transition.dart # ローディング状態遷移
│   ├── use_network_check.dart # ネットワークチェック
│   ├── use_push_notification_setting.dart # 通知設定
│   └── use_push_notification_token.dart # 通知トークン
├── route/                    # ルーティング定義
│   ├── route.dart            # ルート定義
│   └── route.g.dart          # 生成されたルートコード
├── l10n/                     # 国際化
│   ├── app_en.arb            # 英語翻訳
│   └── app_ja.arb            # 日本語翻訳
├── gen/                      # 生成されたコード
├── import/                   # バレルファイル（インポート用）
│   ├── component.dart        # コンポーネント
│   ├── domain.dart           # ドメイン
│   ├── gen.dart              # 生成コード
│   ├── hook.dart             # フック
│   ├── model.dart            # モデル
│   ├── provider.dart         # プロバイダー
│   ├── root.dart             # ルート
│   ├── route.dart            # ルート
│   ├── screen.dart           # 画面
│   ├── theme.dart            # テーマ
│   ├── type.dart             # 型
│   ├── utility.dart          # ユーティリティ
│   └── widgetbook.dart       # Widgetbook
└── widgetbook/               # Widgetbook設定
    ├── components.dart       # コンポーネント
    └── main.dart             # メイン
```

## コーディング規約

### 一般的なルール

1. **インポート順序**:

   - Dart の標準ライブラリ
   - サードパーティライブラリ
   - プロジェクト内の相対インポート（import/ディレクトリ経由）

2. **命名規則**:

   - クラス名: `PascalCase`（例: CustomButton, UserProfile）
   - 変数・メソッド名: `camelCase`（例: userName, fetchData）
   - ファイル名: `snake_case`（例: custom_button.dart）
   - ディレクトリ名: `snake_case`（例: component, screen, setting）
   - プライベートメンバー: `_`プレフィックス

3. **コメント**:

   - クラスドキュメント: 各クラスの直前に `/// クラスの説明` 形式
   - コンストラクタドキュメント: コンストラクタの直前に同様のドキュメントコメント
   - プロパティドキュメント: 各プロパティの直前に説明コメント
   - メソッドドキュメント: 必要に応じてメソッドの直前に説明コメント
   - コード内コメント: 複雑なロジックには `// コメント` 形式

4. **ファイル構造**:
   - 1 ファイルにつき 1 つの主要クラス
   - 関連する小さなクラスや enum は同じファイルに配置可能

### Flutter に関するルール

1. **ウィジェット構造**:

   - 複雑なウィジェットは小さなウィジェットに分割
   - StatelessWidget を優先し、必要な場合のみ StatefulWidget を使用
   - HookConsumerWidget を基底クラスとして使用
   - Riverpod を使用した状態管理を推奨

2. **レイアウト**:

   - ハードコードされた数値の代わりに`utility/space.dart`の定数を使用
   - レスポンシブデザインには`utility/media_query.dart`を使用

3. **コンポーネント命名パターン**:
   - 画面: 〇〇 Screen（例: HomeScreen, SettingsScreen）
   - コンポーネント: 機能を表す名前（例: CustomButton, LoadingDialog）
   - ヘッダー: 〇〇 Header（例: BaseHeader, BackIconHeader）

### 状態管理

1. **Riverpod + Flutter Hooks**:

   - 主要な状態管理に Riverpod と Flutter Hooks を組み合わせて使用
   - グローバル状態は Provider で管理（例: appThemeProvider, userStateProvider）
   - ローカル状態は useState や useTextEditingController などの Hooks で管理

2. **状態の分離パターン**:

   - 読み取り専用の状態: `ref.watch(provider)`
   - 状態の更新: `ref.watch(provider.notifier)`
   - コンポーネント内状態管理:
     - 一時的な状態（検索結果など）は useState で管理
     - フォーム状態は TextEditingController で管理

3. **プロバイダーの種類**:
   - 複雑な状態には`StateNotifier`を使用
   - 単純な状態には`Provider`を使用
   - 非同期データの取得には`FutureProvider`または`StreamProvider`を使用

### エラーハンドリング

1. **例外処理**:

   - API エラーは適切なエラーハンドリングを使用
   - 認証エラーは専用のハンドリングを使用
   - ネットワークエラーは`use_network_check.dart`を使用

2. **ログ記録**:
   - `debugPrint`の使用は禁止します。ログ出力には必ず`utility/logger/logger.dart`で定義されている`logger`インスタンスを使用してください。
   - 開発環境では詳細なログを記録し、本番環境では最小限のログを記録してください。
   - ログパラメータは`utility/format_log_parameters.dart`でフォーマットしてください。

### テスト

1. **単体テスト**:

   - ビジネスロジックとユーティリティ関数には単体テストを作成
   - テストファイルは対応するソースファイルと同じディレクトリ構造に配置
   - テストファイル名は`*_test.dart`の形式

2. **モック**:
   - 外部依存関係のモックには`mockito`または`mocktail`を使用
   - テスト用のモックデータは`test/mock_data/`ディレクトリに配置

## 開発ワークフロー

1. **ブランチ戦略**:

   - 新機能開発: `feature/*`
   - バグ修正: `fix/*`
   - リファクタリング: `refactor/*`
   - 開発環境: `develop`
   - ステージング環境: `staging`
   - 本番環境: `main`

2. **コードレビュー**:

   - PR を作成する前に`flutter analyze`を実行してリントエラーを修正
   - PR には適切なレビュアーを指定
   - PR テンプレートに従って必要な情報を記入

3. **CI/CD**:
   - PR ごとに自動テストとリントチェックが実行される
   - ステージング環境へのデプロイは`staging`ブランチへのマージ後に実行
   - 本番環境へのデプロイは`main`ブランチへのマージ後に実行

## 重要な概念

1. **アプリライフサイクル**:

   - `AppLifecycleStateProvider`: アプリのライフサイクル状態の管理
   - `MediaQueryStateNotifier`: 画面サイズと向きの管理

2. **認証システム**:

   - Firebase Authentication を使用
   - Google Sign-In によるソーシャルログイン対応

3. **プッシュ通知**:

   - `CloudMessagingProvider`: プッシュ通知の管理
   - `PushNotificationStateNotifier`: 通知設定の状態管理
   - `handleCloudMessage`: 受信メッセージの処理

4. **分析統合**:

   - `FirebaseAnalyticsProvider`: ユーザーインタラクションのログ記録
   - `AppTrackingTransparency`: iOS のトラッキング許可管理

5. **課金システム**:
   - RevenueCat を使用したサブスクリプション管理
   - `PurchaseStateNotifier`: 課金状態の管理

## 環境設定

1. **Flutter**:

   - Flutter SDK は stable バージョンを使用
   - コマンド実行時は`flutter`を使用

2. **環境変数**:

   - 環境変数は`dart_env/`ディレクトリ内のファイルで管理
   - 開発環境: `dev.env`
   - ステージング環境: `stg.env`
   - 本番環境: `prod.env`

3. **ビルド設定**:
   - ビルドコマンドは`Makefile`で定義
   - CI/CD パイプラインは`.github/workflows/`ディレクトリで設定

## パフォーマンス最適化

1. **画像最適化**:

   - 画像ファイルは最適化・圧縮してから追加
   - SVG ファイルを優先的に使用
   - `flutter_gen`を使用した画像リソース管理

2. **メモリ管理**:

   - 大きなオブジェクトは使用後に適切に破棄
   - 不要なウィジェットの再構築を避ける

3. **時間関連の処理**:
   - 時間値（ミリ秒など）にはマジックナンバーを使用せず、名前付き定数を定義

## セキュリティ

1. **認証情報**:

   - 認証情報は`SharedPreferences`で安全に保存
   - API キーなどの機密情報はソースコードに直接記述しない

2. **API リクエスト**:
   - API リクエストには適切な認証ヘッダーを追加
   - HTTPS 通信を強制

## アクセシビリティ

1. **セマンティクス**:

   - 重要な UI コンポーネントには適切なセマンティクスラベルを追加
   - コントラスト比を適切に保つ

2. **フォントサイズ**:

   - テキストサイズはデバイスの設定に応じてスケーリング
   - 最小フォントサイズを設定して可読性を確保

3. **国際化**:
   - `AppLocalizations`を使用した多言語対応
   - 日本語と英語の両方に対応

## リリースプロセス

1. **事前準備**:

   - Firebase プロジェクトの作成
   - 証明書の作成（iOS）
   - アプリの作成（App Store Connect, Google Play Console）

2. **ビルド・テスト**:

   - `make run-dev`, `make run-prod`でビルドテスト
   - 各種設定の確認

3. **リリース準備**:

   - アイコン・スプラッシュ画面の設定
   - スクリーンショットの作成
   - アプリ説明文の準備

4. **審査・公開**:
   - ストア審査への提出
   - 審査対応
   - 公開後の設定（AdMob 連携等）

## カスタマイズガイド

### プロジェクト名の変更

1. `pubspec.yaml`の`name`フィールドを変更
2. `lib/l10n/`内の翻訳ファイルのアプリ名を更新
3. アイコンとスプラッシュ画面を新しいアプリ用に変更

### 機能の追加・削除

1. 不要なプロバイダーは`lib/provider/`から削除
2. 不要なコンポーネントは`lib/component/`から削除
3. 新しい機能に応じてプロバイダーとコンポーネントを追加

### テーマのカスタマイズ

1. `lib/theme/app_colors.dart`でカラーパレットを定義
2. `lib/theme/app_theme.dart`でテーマを調整
3. `assets/color/colors.xml`で Android 用カラーを定義

- コード追加、修正を加えたら`fvm flutter analyze`を実行して、エラーがないか確認する。エラーや info,warning があったら、エラーを修正すること。
- `Missing documentation for a public member. Try adding documentation for the member.` の対策を必ず行うこと。
- パブリックメンバーには必ず dartdoc 形式（///）で日本語のドキュメントコメントを記述すること。
- catch 句では必ず例外の型（例: on Exception catch (e)）を明示すること。
- ジェネリクスや型推論が必要な箇所では、型を明示して推論エラーを防ぐこと。
- TODO コメントは必ず「// TODO(担当者名): ...」の Flutter スタイルで記述すること。
- 非同期処理で BuildContext を使用する場合は、context.mounted 等で安全性を必ず確認すること。

## Import ルール

- プロジェクト内のインポートは必ず`import/`ディレクトリ経由で行うこと。
- 相対パスでの直接インポート（例: `import '../model/dog_profile.dart'`）は禁止すること。
- 正しい例: `import '../../import/component.dart';`
- 間違った例: `import '../model/dog_profile.dart';`

## Export ルール

- 新規ファイルを追加した際は、対応する`lib/import/`ディレクトリ内のファイルに export 文を追加すること。
- 例: `lib/component/button/cancel_button.dart`を追加した場合、`lib/import/component.dart`に`export '../component/button/cancel_button.dart';`を追加すること。
- これにより、他のファイルから`import '../../import/component.dart';`でインポートできるようになる。

## テキストウィジェットルール

- テキスト表示には必ず`ThemeText`を使用すること。
- 通常の`Text`ウィジェットの使用は禁止すること。
- 正しい例: `ThemeText(text: '表示するテキスト')`
- 間違った例: `Text('表示するテキスト')`

## AppBar 使用ルール

- 画面（screen）配下では直接`AppBar`を使用せず、`lib/component/header`配下のコンポーネントを使用すること。
- 利用可能なヘッダーコンポーネント：
  - `BaseHeader`: 基本的なヘッダー（戻るボタンなし）
  - `BackIconHeader`: 戻るアイコンとタイトルがあるヘッダー
  - `IconActionsHeader`: アクションボタンがあるヘッダー
  - `TextActionsHeader`: テキストアクションボタンがあるヘッダー
  - `OnlyBackIconHeader`: 戻るアイコンだけのヘッダー
- 正しい例: `appBar: const BackIconHeader(title: '画面タイトル')`
- 間違った例: `appBar: AppBar(title: Text('画面タイトル'))`

## ボタン使用ルール

- `TextButton`や`ElevatedButton`を直接使用せず、`lib/component/button`配下の専用ボタンコンポーネントを使用すること。
- 利用可能なボタンコンポーネント：
  - `PrimaryButton`: 主要なアクション用（例：ログイン、保存、確定）
  - `SecondaryButton`: 二次的なアクション用（例：編集、詳細表示）
  - `CancelButton`: キャンセルアクション用（例：キャンセル、戻る）
  - `DialogPrimaryButton`: ダイアログ内の主要アクション用
  - `DialogSecondaryButton`: ダイアログ内の二次的アクション用
- 正しい例: `PrimaryButton(text: 'ログイン', onPressed: () {})`
- 間違った例: `ElevatedButton(onPressed: () {}, child: Text('ログイン'))`
- 新しいボタンコンポーネントが必要な場合は、既存のパターンに従って`lib/component/button`配下に作成すること。

## スナックバー使用ルール

- `ScaffoldMessenger.of(context).showSnackBar`を直接使用せず、`lib/component/snackbar`配下の専用スナックバーコンポーネントを使用すること。
- 利用可能なスナックバーコンポーネント：
  - `showSnackBar`: 成功メッセージ用（緑色の背景）
  - `showAlertSnackBar`: エラーメッセージ用（赤色の背景）
- 正しい例: `showSnackBar(context: context, theme: theme, text: '保存しました')`
- 間違った例: `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存しました')))`
- 新しいスナックバーコンポーネントが必要な場合は、既存のパターンに従って`lib/component/snackbar`配下に作成すること。

## 画面遷移使用ルール

- `Navigator.of(context).push`や`Navigator.of(context).pushReplacement`を直接使用せず、`lib/route/route.dart`で定義された GoRouter ベースのルートクラスを使用すること。
- 利用可能なルートクラス：
  - `WalkThroughRoute`: ウォークスルー画面
  - `BaseScreenRoute`: ベース画面
  - `PushScreenRoute`: プッシュ通知設定画面
  - `ContactScreenRoute`: お問い合わせ画面
  - `RequestScreenRoute`: ご意見・ご要望画面
  - `RecommendAppScreenRoute`: オススメアプリ画面
  - `LanguageSettingScreenRoute`: 言語設定画面
  - `SettingScreenRoute`: 設定画面
  - `LoginRoute`: ログイン画面
  - `SignUpRoute`: 新規登録画面
  - `PasswordResetRoute`: パスワードリセット画面
  - `HomeRoute`: ホーム画面
  - `DogProfileRoute`: 犬プロフィール画面
  - `MusicPlayerRoute`: 音楽再生画面（パラメータ付き）
  - `MyPageRoute`: マイページ画面
  - `SubscriptionRoute`: サブスクリプション画面
- 正しい例: `const LoginRoute().go(context)` または `const MusicPlayerRoute(musicUrl: url).push<void>(context)`
- 間違った例: `Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()))`
- 新しい画面を追加する場合は、`lib/route/route.dart`にルートクラスを定義すること。
