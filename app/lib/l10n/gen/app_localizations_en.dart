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

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get labelNakshatra => 'Nakshatra';

  @override
  String get labelYoga => 'Yoga';

  @override
  String get labelKarana => 'Karana';

  @override
  String get labelSunrise => 'Sunrise';

  @override
  String get labelSunset => 'Sunset';

  @override
  String get labelMoonrise => 'Moonrise';

  @override
  String get labelMoonset => 'Moonset';

  @override
  String get timeNone => 'None';

  @override
  String get todayDataMissing => 'Today\'s data isn\'t available';

  @override
  String get retry => 'Try again';

  @override
  String provenance(String tradition, String city, String timeZone) {
    return '$tradition · $city · $timeZone';
  }

  @override
  String tithiSealSemantics(String tithi, String until, String then) {
    return 'Tithi $tithi, $until, $then';
  }

  @override
  String nameWithUntil(String name, String until) {
    return '$name · $until';
  }
}
