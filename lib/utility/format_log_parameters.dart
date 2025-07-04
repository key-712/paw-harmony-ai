import '../import/utility.dart';

/// FirebaseAnalyticsのイベントのパラメータをフォーマットします
Map<String, Object> formatLogParameters({
  required Map<String, dynamic> json,
}) {
  final result = <String, Object>{};
  json.forEach((key, value) {
    if (value is String) {
      result[key] =
          value.length <= FirebaseAnalyticsLimits.lengthOfEventParameterValue
              ? value
              : value.substring(
                  0,
                  FirebaseAnalyticsLimits.lengthOfEventParameterValue,
                );
    } else if (value is bool) {
      result[key] = value.toString();
    } else {
      result[key] = value as Object;
    }
  });
  return result;
}
