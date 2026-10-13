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

  @override
  String get useMyLocation => 'Use my location';

  @override
  String get locating => 'Finding your location…';

  @override
  String get locationRationale =>
      'To find the nearest city, the app needs your phone\'s approximate location. It is used only on this phone; only the city you choose is remembered.';

  @override
  String get actionNotNow => 'Not now';

  @override
  String nearestCity(String city, String distance) {
    return 'Nearest city: $city, $distance km';
  }

  @override
  String cityFarWarning(String limit) {
    return 'This city is more than $limit km away, so times may differ by a few minutes.';
  }

  @override
  String get actionChooseCity => 'Choose this city';

  @override
  String get locationDenied =>
      'The app works without it. Choose your city from the list.';

  @override
  String get locationDeniedForever =>
      'Location permission is off. Choose your city from the list, or allow it in settings.';

  @override
  String get actionOpenSettings => 'Open settings';

  @override
  String get locationOff => 'Location is turned off on this phone.';

  @override
  String get actionTurnOn => 'Turn on';

  @override
  String get locationUnavailable =>
      'Couldn\'t find your location. Choose your city from the list.';

  @override
  String get linkNotFound => 'This page couldn\'t be found.';

  @override
  String get festivalNotFound =>
      'This festival isn\'t in the data on this phone.';

  @override
  String get goToToday => 'Go to Today';

  @override
  String get numeralsBengaliSemantics => 'Bengali numerals';

  @override
  String get numeralsLatinSemantics => 'Latin numerals';

  @override
  String festivalsTitle(String year) {
    return 'Festivals $year';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterTitle => 'Filter';

  @override
  String get filterMonth => 'Month';

  @override
  String get filterImportance => 'Importance';

  @override
  String get tierMajor => 'Major festivals';

  @override
  String get tierOther => 'Other observances';

  @override
  String get tierCivic => 'Anniversaries and civic days';

  @override
  String get showAll => 'Show all';

  @override
  String get noFestivalsMatch => 'No observances match these filters.';

  @override
  String get festivalYearPartial =>
      'Some months of this year aren\'t downloaded.';

  @override
  String festivalRowDates(String gregorian, String bengali) {
    return '$gregorian · $bengali';
  }

  @override
  String festivalDayOf(String day) {
    return 'Day $day';
  }

  @override
  String get windowSandhiPuja => 'Sandhi Puja';

  @override
  String windowSandhiPujaHint(String minutes) {
    return 'The last $minutes minutes of Ashtami and the first $minutes of Navami';
  }

  @override
  String get windowNishita => 'Nishita (midnight)';

  @override
  String get windowPratah => 'Pratah (early morning)';

  @override
  String get windowMadhyahna => 'Madhyahna (midday)';

  @override
  String get windowAparahna => 'Aparahna (afternoon)';

  @override
  String get windowPradosha => 'Pradosha (dusk)';

  @override
  String festivalTithiSpan(String name, String start, String end) {
    return '$name · $start to $end';
  }

  @override
  String checkedOn(String date) {
    return 'Checked: $date';
  }

  @override
  String get reminderOff => 'Remind me';

  @override
  String get reminderOn => 'Reminder on';

  @override
  String get festivalDaysLabel => 'Days';

  @override
  String reminderTomorrow(String name) {
    return '$name tomorrow';
  }

  @override
  String reminderToday(String name) {
    return '$name today';
  }

  @override
  String reminderTithiBegun(String name) {
    return '$name has begun';
  }

  @override
  String reminderTithiBegins(String time) {
    return 'Tithi begins $time';
  }

  @override
  String reminderBody(String detail, String tradition, String timeZone) {
    return '$detail · $tradition · $timeZone';
  }

  @override
  String get channelFestival => 'Festival reminders';

  @override
  String get channelFestivalDescription =>
      'Reminders before the festivals you chose.';

  @override
  String get channelTithi => 'Tithi reminders';

  @override
  String get channelTithiDescription =>
      'Ekadashi, Purnima and Amavasya reminders.';

  @override
  String get notificationsOff =>
      'Notifications are off, so reminders can\'t be shown. Turn on notifications for this app in your phone\'s settings.';

  @override
  String get sectionRecurring => 'Recurring';

  @override
  String get sectionFestivalReminders => 'Festivals';

  @override
  String get recurringEkadashi => 'Ekadashi';

  @override
  String get recurringPurnima => 'Purnima';

  @override
  String get recurringAmavasya => 'Amavasya';

  @override
  String timingDayBefore(String time) {
    return 'The day before, $time';
  }

  @override
  String timingMorningOf(String time) {
    return 'On the day, $time';
  }

  @override
  String get timingTithiStart => 'When the tithi begins';

  @override
  String timingBoth(String first, String second) {
    return '$first and $second';
  }

  @override
  String get addFestivalReminder => 'Add a festival';

  @override
  String get remindersEmpty =>
      'No reminders yet. Turn one on for Ekadashi or a festival.';

  @override
  String get timingSheetTitle => 'When should we remind you?';

  @override
  String get timingDayBeforeOption => 'The day before';

  @override
  String get timingMorningOption => 'On the morning of the day';

  @override
  String get changeTime => 'Change the time';
}
