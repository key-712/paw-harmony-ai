import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../l10n/app_localizations.dart';
import '../import/utility.dart';

/// Slackにお問合せメッセージを送信する
Future<void> sendToSlack({
  required BuildContext context,
  required String subject,
  required String content,
}) async {
  final localizations = AppLocalizations.of(context)!;

  final payload = <String, dynamic>{
    'text':
        '確認！\nアプリ名: ${localizations.productName}\n件名: $subject\n内容: $content',
  };
  final response = await http.post(
    Uri.parse(Env.slackWebhookUrl),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(payload),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to send message to Slack');
  }
}
