# crelve-paw-harmony-ai

## 技術スタック

### Flutter バージョン

stable

### 状態管理

Riverpod（hooks_riverpod）と Flutter Hooks（flutter_hooks）の組み合わせ

### データ永続化

SharedPreferences

### バックエンド

Firebase

### 認証方法

Firebase Authentication

### プラットフォーム

iOS,Android

## 既存のコードベース

### ディレクトリ構造:

lib/
├── component/ # 再利用可能な UI コンポーネント
│ ├── card/ # カード関連のコンポーネント
│ ├── dialog/ # ダイアログ関連のコンポーネント
│ ├── form/ # フォーム関連のコンポーネント
│ └── list/ # リスト関連のコンポーネント
├── screen/ # アプリの画面
│ ├── domain/ # 機能ドメイン別の画面
│ ├── home/ # ホーム関連の画面
│ └── setting/ # 設定関連の画面
├── import/ # インポート集約ファイル
│ ├── component.dart # コンポーネントのエクスポート
│ ├── model.dart # モデルのエクスポート
│ ├── provider.dart # プロバイダーのエクスポート
│ ├── route.dart # ルート関連のエクスポート
│ ├── theme.dart # テーマ関連のエクスポート
│ ├── type.dart # 型定義のエクスポート
│ └── utility.dart # ユーティリティ関数のエクスポート
└── model/ # データモデル

### 命名規則

1. クラス名: PascalCase（例: PointCardListItem, CustomTextFormField）
2. 変数名: camelCase（例: searchController, filteredCards）
3. ファイル名: snake_case（例: point_card_list_item.dart, custom_text_form_field.dart）
4. ディレクトリ名: snake_case（例: component, screen, setting）
5. コンポーネント命名パターン:

- 画面: 〇〇 Screen（例: SearchScreen, ContactScreen）
- コンポーネント: 機能を表す名前（例: PointCardListItem, RatingDialog）
- ヘッダー: 〇〇 Header（例: BaseHeader, BackIconHeader）

### コメント規約

1. クラスドキュメント: 各クラスの直前に /// クラスの説明 形式のドキュメントコメントを記述
2. コンストラクタドキュメント: コンストラクタの直前に同様のドキュメントコメントを記述
3. プロパティドキュメント: 各プロパティの直前に説明コメントを記述
4. メソッドドキュメント: 必要に応じてメソッドの直前に説明コメントを記述
5. コード内コメント: 複雑なロジックや状態管理には // コメント 形式の行コメントを使用

### 状態管理パターン

1. Riverpod + Flutter Hooks: 主要な状態管理に Riverpod と Flutter Hooks を組み合わせて使用

- HookConsumerWidget を基底クラスとして使用
- グローバル状態は Provider で管理（例: appThemeProvider, ratingStateProvider）
- ローカル状態は useState や useTextEditingController などの Hooks で管理

2. 状態の分離パターン:
   - 読み取り専用の状態: ref.watch(provider)
   - 状態の更新: ref.watch(provider.notifier)
3. コンポーネント内状態管理:
   - 一時的な状態（検索結果など）は useState で管理
   - フォーム状態は TextEditingController で管理

### その他の特徴

- 国際化対応: AppLocalizations を使用した多言語対応
- テーマ管理: カスタムテーマシステムによる一貫したデザイン
- ルーティング: GoRouter を使用した画面遷移の管理
- 広告統合: AdBanner コンポーネントによる広告表示
- インポート管理: import ディレクトリによるインポートの集約と管理

## リリースまでにやること

PROGRESS
15. スクショコンテンツの作成
    https://zenn.dev/futtaro/articles/2357ccbba29678
16. 審査対応
17. Push 通知の設定
18. 審査提出
=======================================================
19. AdMob とアプリ紐付け
    公開から約 24 時間後目安
20. アプリの作成(Android)
21. Android アップロード用署名鍵の作成
    make upload-file
    key.jks を android/key.jks へ移動
    https://www.flutter-study.dev/create-app/publish-android

DONE

1. リポジトリの複製
2. リポジトリ内の固有部分置換
3. Firebase プロジェクトの作成
4. 証明書の作成(iOS)
   https://prody03.com/ios_release/
5. アプリの作成(iOS)
6. run-dev,run-prod
7. BigQuery 連携(Prod のみ)
8. AdMob アカウントの作成(Prod のみ)
9. タスクの実行
10. 利用規約、プライバシーポリシーの作成
11. app-ads.txt を設定する
    https://qiita.com/masaibar/items/c378b4f01b707ac2506a
12. APNs 認証キーの追加(Firebase Cloud Messaging Prod のみ)
    https://drive.google.com/file/d/1v4hfDUC0UV1TgBIjSvbdokyvP8wipdja/view?usp=drive_link
    https://console.firebase.google.com/u/0/project/crelve-paw-harmony-ai-prod/settings/cloudmessaging/ios:crelve.paw.harmony.ai.mobile.prod?hl=ja
13. アイコン/ウォークスルー画像のサイズ変更・置換
    assets/image/
    launcher_icon/image/
14. make create-native-splash
