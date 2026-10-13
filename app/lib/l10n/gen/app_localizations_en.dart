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

  @override
  String get labelNow => 'Now';

  @override
  String get labelToday => 'Today';

  @override
  String periodSemantics(String name, String range, String active) {
    String _temp0 = intl.Intl.selectLogic(active, {
      'yes': ', happening now',
      'other': '',
    });
    return '$name, $range$_temp0';
  }

  @override
  String get periodShubh => 'Auspicious times';

  @override
  String get periodAshubh => 'Inauspicious times';

  @override
  String get verificationSample => 'Sample data';

  @override
  String get verificationComputed => 'Calculated, not yet checked';

  @override
  String get verificationReferenceMatched => 'Checked against the panjika';

  @override
  String get verificationExpertReviewed => 'Reviewed by an expert';

  @override
  String calendarCellSemantics(
    String bengaliDate,
    String gregorianDate,
    String tithi,
  ) {
    return '$bengaliDate, $gregorianDate, $tithi';
  }

  @override
  String calendarCellWithFestival(
    String bengaliDate,
    String gregorianDate,
    String tithi,
    String festival,
  ) {
    return '$bengaliDate, $gregorianDate, $tithi, $festival';
  }

  @override
  String todayPrefix(String label) {
    return 'Today, $label';
  }

  @override
  String cityChipSemantics(String city) {
    return 'City: $city. Tap to change';
  }

  @override
  String get glossaryTitle => 'Glossary';

  @override
  String get glossaryOpen => 'What does this mean?';

  @override
  String get loading => 'Loading';

  @override
  String get languageNameBengali => 'বাংলা';

  @override
  String get languageNameEnglish => 'English';

  @override
  String termWithName(String term, String name) {
    return '$term: $name';
  }

  @override
  String get stateNotDownloaded =>
      'Data for these dates isn\'t downloaded yet.';

  @override
  String get stateOffline =>
      'You\'re offline. The data will download when you\'re connected.';

  @override
  String get stateStale => 'This data needs an update.';

  @override
  String get stateSignatureFailed =>
      'We couldn\'t verify this data, so it isn\'t shown.';

  @override
  String get stateUnverified =>
      'This date hasn\'t been checked against the panjika yet.';

  @override
  String get stateCheckClock => 'Please check your phone\'s date';

  @override
  String get actionDownload => 'Download';

  @override
  String get actionUpdate => 'Update';

  @override
  String sizeMegabytes(String size) {
    return '$size MB';
  }

  @override
  String downloadPrompt(String size) {
    return 'New data is available ($size). Download now?';
  }

  @override
  String get actionLater => 'Later';

  @override
  String get noticeDismiss => 'Got it';

  @override
  String get updateFailed =>
      'Couldn\'t download the data. We\'ll try again later.';

  @override
  String get appUpdateRequired => 'Update the app to get new data.';
}
