import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../import/theme.dart';
import '../import/utility.dart';
import '../import/widgetbook.dart';

/// Widgetbookのエントリポイント(Widgetbook起動時の処理)
void main() {
  runApp(const ProviderScope(child: WidgetbookApp()));
}

/// Widgetbookで、最初に起動されるウィジェット(アプリ)
@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  /// Widgetbookで、最初に起動されるウィジェット(アプリ)
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: AppTheme.light(MediaType.sp).data,
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: AppTheme.dark(MediaType.sp).data,
            ),
          ],
        ),
        DeviceFrameAddon(
          devices: Devices.all,
        ),
      ],
      appBuilder: (context, child) => child,
    );
  }
}
