import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_keys.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/loc_extensions.dart';
import '../../core/localization/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      tooltip: context.tr(AppKeys.language),
      icon: const Icon(Icons.language),
      onSelected: (locale) {
        context.read<LocaleProvider>().setLocale(locale);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AppLocalizations.supportedLocales[0],
          child: Text(context.tr(AppKeys.languageEn)),
        ),
        PopupMenuItem(
          value: AppLocalizations.supportedLocales[1],
          child: Text(context.tr(AppKeys.languageAr)),
        ),
      ],
    );
  }
}
