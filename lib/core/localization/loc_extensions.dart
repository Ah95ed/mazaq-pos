import 'package:flutter/material.dart';

import 'app_localizations.dart';

extension LocalizationX on BuildContext {
  String tr(String key) => AppLocalizations.of(this).tr(key);
}
