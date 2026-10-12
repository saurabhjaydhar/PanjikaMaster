// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bangla Panjika';

  @override
  String get navToday => 'Today';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navFestivals => 'Festivals';

  @override
  String get navMore => 'More';

  @override
  String untilTime(String time) {
    return 'until $time';
  }

  @override
  String thenName(String name) {
    return 'then $name';
  }

  @override
  String nextDayTime(String time) {
    return '$time (next day)';
  }

  @override
  String countdownDays(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $countText days',
      one: 'Tomorrow',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get timeZoneLabel => 'IST';

  @override
  String get sampleWatermark => 'নমুনা · SAMPLE';

  @override
  String get languageSetting => 'Language';
}
