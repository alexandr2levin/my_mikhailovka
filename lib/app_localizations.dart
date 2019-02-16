import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;

}

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      'app_title': 'Моя Михайловка',
      'home_title': "Моя Михайловка ❤️",
      'home_direction_from': "От Пивзавода",
      'home_direction_to': "От Ленина",
    },
  };

  String _localize(String key) {
    return _localizedValues[locale.languageCode][key];
  }

  String get appTitle => _localize("app_title");
  String get homeTitle => _localize("home_title");
  String get homeDirectionFrom => _localize("home_direction_from");
  String get homeDirectionTo => _localize("home_direction_to");

}