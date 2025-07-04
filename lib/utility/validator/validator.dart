import 'package:email_validator/email_validator.dart';

import '../../l10n/app_localizations.dart';

/// メールアドレスのバリデーション
String? validateEmail({
  required String? value,
  required AppLocalizations localizations,
}) {
  if (value == null || value.isEmpty) {
    return localizations.emailRequired;
  }
  if (!EmailValidator.validate(value)) {
    return localizations.emailInvalid;
  }
  if (value.length > 64) {
    return localizations.emailTooLong;
  }
  return null;
}

/// パスワードのバリデーション
String? validatePassword({
  required String? value,
  required AppLocalizations localizations,
}) {
  if (value == null || value.isEmpty) {
    return localizations.passwordRequired;
  }
  if (value.length < 6) {
    return localizations.passwordTooShort;
  }
  if (value.length > 40) {
    return localizations.passwordTooLong;
  }
  final regex = RegExp(r'^[a-zA-Z0-9_.-]+$');
  if (!regex.hasMatch(value)) {
    return localizations.passwordInvalidCharacters;
  }
  return null;
}
