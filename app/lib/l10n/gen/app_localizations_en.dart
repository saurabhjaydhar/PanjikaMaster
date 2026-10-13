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

  @override
  String get labelTithi => 'Tithi';

  @override
  String get labelPaksha => 'Paksha';

  @override
  String get sectionSunMoon => 'Sun and moon';

  @override
  String get sectionObservances => 'Festivals and vratas';

  @override
  String get dayTitle => 'Day';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String coordinates(String lat, String lon) {
    return '$lat° N, $lon° E';
  }

  @override
  String footerDetail(String coordinates, String packs, String status) {
    return '$coordinates · data: $packs · $status';
  }

  @override
  String get sectionUpcoming => 'Coming up';

  @override
  String get sectionToday => 'Today';

  @override
  String get openDay => 'Open the full day';

  @override
  String get calendarModeBengali => 'Bengali month';

  @override
  String get calendarModeGregorian => 'Gregorian month';

  @override
  String monthTitle(String month, String year) {
    return '$month $year';
  }

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get previousYear => 'Previous year';

  @override
  String get nextYear => 'Next year';

  @override
  String get chooseMonth => 'Choose a month';

  @override
  String get legendTitle => 'What the marks mean';

  @override
  String get legendFestival => 'Festival (colour by category)';

  @override
  String get legendSelected => 'Selected day';

  @override
  String legendEither(String first, String second) {
    return '$first / $second';
  }

  @override
  String selectedDay(String date) {
    return 'Selected: $date';
  }

  @override
  String get actionView => 'View';

  @override
  String get cityPickerTitle => 'Choose a city';

  @override
  String get citySearchHint => 'Type a city name';

  @override
  String get sectionRecent => 'Recent';

  @override
  String get sectionWestBengal => 'West Bengal';

  @override
  String get sectionOtherCities => 'Other cities';

  @override
  String sunriseAt(String time) {
    return 'Sunrise $time';
  }

  @override
  String cityRowSemantics(String city, String district, String sunrise) {
    return '$city, $district, $sunrise';
  }

  @override
  String get currentCity => 'Current city';

  @override
  String get noCityMatches => 'No city matches that name';

  @override
  String get cityChanged =>
      'Sunrise and Rahu Kaal times changed; tithi and festival dates stay the same';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingNamesBoth => 'Names in both scripts';

  @override
  String get settingTradition => 'Panjika tradition';

  @override
  String get settingCity => 'City';

  @override
  String get settingTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingTextSize => 'Text size';

  @override
  String get textSizePreview => 'Text will look like this';

  @override
  String get settingTimeFormat => 'Time format';

  @override
  String timeFormatHours(String hours) {
    return '$hours-hour';
  }

  @override
  String get settingNumerals => 'Numerals';

  @override
  String get numeralsAuto => 'Follow language';

  @override
  String numeralsBengali(String digits) {
    return 'Bengali ($digits)';
  }

  @override
  String numeralsLatin(String digits) {
    return 'Latin ($digits)';
  }

  @override
  String get sectionData => 'Data';

  @override
  String get checkDataNow => 'Check for new data';

  @override
  String get installedData => 'Downloaded data';

  @override
  String dataRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get sectionOther => 'Other';

  @override
  String get licences => 'Licences';

  @override
  String get traditionConfirm =>
      'Changing the tradition can change some festival dates. Reminders will be rescheduled.';

  @override
  String get actionChange => 'Change';

  @override
  String get actionKeep => 'Keep';

  @override
  String get moreTitle => 'More';

  @override
  String get menuReminders => 'Reminders';

  @override
  String get menuSearch => 'Search';

  @override
  String get menuCity => 'City';

  @override
  String get menuGlossary => 'Glossary';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuSources => 'Sources & verification';

  @override
  String get menuReport => 'Report an error';

  @override
  String get menuRemoveAds => 'Remove ads';

  @override
  String get menuAbout => 'About';

  @override
  String get menuPrivacy => 'Privacy';

  @override
  String get aboutTagline =>
      'The Bengali panjika of tithis, festivals and auspicious times, in Bengali and English.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDataHeading => 'Where the data comes from';

  @override
  String get aboutDataBody =>
      'Positions of the Sun and Moon are computed from NASA JPL\'s DE440s ephemeris with the Skyfield software. The computation is done ahead of time; the phone only reads that data and never guesses.';

  @override
  String get aboutProvenance =>
      'Every value is shown with its panjika tradition, city, time zone and verification status.';

  @override
  String bothLanguages(String bn, String en) {
    return '$bn · $en';
  }

  @override
  String onboardingStep(String step, String total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingChooseLanguage => 'Choose your language';

  @override
  String onboardingLanguagePreview(String tithi) {
    return 'For example: $tithi';
  }

  @override
  String get onboardingChangeLater => 'You can change this later.';

  @override
  String get actionContinue => 'Continue';

  @override
  String get onboardingTraditionTitle => 'Which panjika do you follow?';

  @override
  String get onboardingTraditionNote =>
      'The two can put a festival on different days. You can change this in Settings.';

  @override
  String get onboardingCityTitle => 'Which is your city?';

  @override
  String get onboardingCityNote =>
      'Sunrise, sunset and Rahu Kaal depend on your city. Tithis and festival dates don\'t.';

  @override
  String get onboardingRemindersTitle => 'Would you like reminders?';

  @override
  String get onboardingRemindersBody =>
      'The app can remind you before festivals, Ekadashi, Purnima and Amavasya. You\'ll choose which ones under Reminders. Your phone will ask for permission when the first reminder is set.';

  @override
  String get onboardingRemindersYes => 'Yes, remind me';

  @override
  String get onboardingRemindersNo => 'Not now';

  @override
  String cityListProvenance(
    String tradition,
    String timeZone,
    String packs,
    String status,
  ) {
    return '$tradition · today\'s sunrise in each city, $timeZone · data: $packs · $status';
  }
}
