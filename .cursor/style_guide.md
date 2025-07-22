# スタイルガイド

## 原則

`analysis_options.yaml`で厳し目の静的解析ルールを設定しており、警告が出ないようにコーディングすることが最優先

## コンマ

### ))のように、括弧が連続する場合は間にコンマを入れて改行させる

```dart
// 👎 NG
Container(color: Colors.white, child: const Text('テスト'));

// 👍 OK
Container(
  color: Colors.white,
  child: const Text('テスト'),
);
```

### EdgeInsets クラスを使う際、プロパティが一つの場合は 1 行にし、それ以外は改行させる

```dart
// 👎 NG
Padding(
  padding: EdgeInsets.only(
    left: 15,
  ),
);
// 👍 OK
Padding(
  padding: EdgeInsets.only(left: 15),
);

// 👎 NG
Padding(
  padding: EdgeInsets.only(left: 15, top: 10),
);
// 👍 OK
Padding(
  padding: EdgeInsets.only(
    left: 15,
    top: 10,
  ),
);
```

### if 文の中身が１行で短い場合は、 1 行にまとめる。(例外あり)

```dart
// 👎 NG
if (!isAuth) {
  return;
}
// 👍 OK
if (!isAuth) return;

// 👎 NG ※1行にまとめると、1行の文字数制限に引っかかる場合は、例外
if (!isAuth) layer1Paths = Layer1WebViewContents.values.map((content) => content.path).toList();
// 👍 OK
if (!isAuth) {
  layer1Paths = Layer1WebViewContents.values.map((content) => content.path).toList();
}
```

## 余白

## SizedBox ではなく hSpace、wSpace というコンポーネントを使う

```dart
// 👎 NG
const SizedBox(height: 16),
// 👍 OK
hSpace(16),

// 👎 NG
const SizedBox(width: 16),
// 👍 OK
wSpace(16),
```

## カラーの使用

### Opacity

`withOpacity`は使わず、`ColorUtility`クラスのメソッドを使用してください。

```dart
// 👎 NG
Colors.black.withOpacity(0.5)

// 👍 OK
ColorUtility.black50,
```

### 基本カラー

colors.dart で提供されているものを使用することを推奨します。

```dart
// 👎 NG
background: Color(0xFFFFFFFF),// 直接カラーコードを書かない
// 👍 OK
background: Colors.white,
```

### カスタムカラー

colors.dart で提供されていないカラーを使用する場合、
ライトモードとダークモードの両方に対応できるように `app_colors.dart` で定義した色を使用する。

```dart
// 👎 NG
color: ColorName.primary,
// 👍 OK
color: theme.appColors.text,
```

### マテリアルコンポーネントのカラー

マテリアルコンポーネントのカラー設定はライトモードとダークモードの両方に対応できるように `app_theme.dart` で ThemeData を定義する。

```dart
// 👎 NG
Scaffold(
  backgroundColor: Colors.white,
// 👍 OK
final themeData = ThemeData.light().copyWith(
  scaffoldBackgroundColor: appColors.background,
...
final themeData = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: appColors.background,
```

## 関数

1 行で済む return 文はアロー関数を使用

## JavaScript 実行周り

try~catch 文を使用する(iOS の場合に単純に JS を実行するとエラーが出るため)

```dart
// 👎 NG
await widget.controller.runJavaScript(await UserSync.getUserSyncScript() ?? '');

// 👍 OK
try {
  await widget.controller.runJavaScript(await UserSync.getUserSyncScript() ?? '');
} on Exception catch (e) {
  logger.e(e);
}
```

## import

相対パスで記述。統一させないと同じファイルを二重でインポートしてしまう

```dart
// 👎 NG
import 'package:{repository_name}/utility/logger.dart';

// 👍 OK
import 'log/log.dart';
```

## 変数名

外部クラスやファイルからアクセスさせない場合は先頭にアンダースコアを付与し、プライベート変数にする。

```dart
// 👎 NG
final hoge = true;

// 👍 OK
final _hoge = true;
```

## 余白は極力 margin ではなく padding で対応

混在させるとレイアウトの可読性が低下する恐れがある

## 命名規則

- ディレクトリ名は[ディレクトリ構成](/README.md)を参考にする
- ファイル名は複数・単数使い分け
- スネークケース
- リスト形式で一覧を表示させるファイルの場合は`XX_list.dart`のようにし、具体度を上げる

## コンポーネント

- 原則、`lib/components` 配下に作成する
- 作成時には関数ではなくクラスで作成する
- Widgetbook に載せるため、UseCase も作成する

```dart
// 👎 NG
Widget ctaButton({
  （省略）
})
// 👍 OK
class CtaButton extends ConsumerWidget {
（省略）
}
// 👍 OK
@widgetbook.UseCase(
（省略）
)
```

## ローディング表示

ローディング表示には`CircularProgressIndicator()`を直接使用せず、`Loading()`コンポーネントを使用してください。

```dart
// 👎 NG
Center(
  child: CircularProgressIndicator(),
)

// 👍 OK
const Loading()
```
