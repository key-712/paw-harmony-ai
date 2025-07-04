import 'package:url_launcher/url_launcher.dart';

/// 外部ブラウザでURLを開きます。
/// 例外が発生した場合はダイアログを表示します。
Future<void> openExternalBrowser({
  required String url,
}) async {
  await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
}
