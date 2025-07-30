import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';

/// ログをとるクラス
final logger = Logger(
  printer: PrettyPrinter(colors: false, errorMethodCount: 15),
  output: LogOutput(),
);

/// ログの出力先を管理するクラス
class LogOutput extends ConsoleOutput {
  @override
  void output(OutputEvent event) {
    super.output(event);
    if (event.level == Level.error || event.level == Level.fatal) {
      event.lines.forEach(FirebaseCrashlytics.instance.log);
      // 開発環境でのみアサーションエラーをスロー
      // 本番環境ではクラッシュを防ぐため、アサーションエラーはスローしない
      // kDebugModeは開発環境でのみtrueになる
      assert(
        !const bool.fromEnvironment('dart.vm.product'),
        'View stack trace by logger output.',
      );
    }
  }
}
