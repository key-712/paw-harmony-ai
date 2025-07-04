import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';

/// ログをとるクラス
final logger = Logger(
  printer: PrettyPrinter(
    colors: false,
    errorMethodCount: 15,
  ),
  output: LogOutput(),
);

/// ログの出力先を管理するクラス
class LogOutput extends ConsoleOutput {
  @override
  void output(OutputEvent event) {
    super.output(event);
    if (event.level == Level.error || event.level == Level.fatal) {
      event.lines.forEach(FirebaseCrashlytics.instance.log);
      throw AssertionError('View stack trace by logger output.');
    }
  }
}
