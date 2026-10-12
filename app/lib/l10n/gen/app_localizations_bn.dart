// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'বাংলা পঞ্জিকা';

  @override
  String get navToday => 'আজ';

  @override
  String get navCalendar => 'পঞ্জিকা';

  @override
  String get navFestivals => 'পার্বণ';

  @override
  String get navMore => 'আরও';

  @override
  String untilTime(String time) {
    return '$time পর্যন্ত';
  }

  @override
  String thenName(String name) {
    return 'তারপর $name';
  }

  @override
  String nextDayTime(String time) {
    return '$time (পরদিন)';
  }

  @override
  String countdownDays(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText দিন বাকি',
      one: 'আগামীকাল',
      zero: 'আজ',
    );
    return '$_temp0';
  }

  @override
  String get timeZoneLabel => 'IST';

  @override
  String get sampleWatermark => 'নমুনা · SAMPLE';

  @override
  String get languageSetting => 'ভাষা';

  @override
  String get comingSoon => 'শীঘ্রই আসছে';
}
