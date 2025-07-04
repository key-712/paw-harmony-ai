import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../import/utility.dart';

/// レビューページを開きます
Future<void> openReview() async {
  Platform.isIOS
      ? await launchUrl(Uri.parse(ExternalPageList.iosAppReviewLink))
      : await launchUrl(Uri.parse(ExternalPageList.androidAppLink));
}
