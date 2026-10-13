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

  @override
  String get labelNakshatra => 'নক্ষত্র';

  @override
  String get labelYoga => 'যোগ';

  @override
  String get labelKarana => 'করণ';

  @override
  String get labelSunrise => 'সূর্যোদয়';

  @override
  String get labelSunset => 'সূর্যাস্ত';

  @override
  String get labelMoonrise => 'চন্দ্রোদয়';

  @override
  String get labelMoonset => 'চন্দ্রাস্ত';

  @override
  String get timeNone => 'নেই';

  @override
  String get todayDataMissing => 'আজকের তথ্য পাওয়া যায়নি';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String provenance(String tradition, String city, String timeZone) {
    return '$tradition · $city · $timeZone';
  }

  @override
  String tithiSealSemantics(String tithi, String until, String then) {
    return 'তিথি $tithi, $until, $then';
  }

  @override
  String nameWithUntil(String name, String until) {
    return '$name · $until';
  }

  @override
  String get labelNow => 'এখন';

  @override
  String get labelToday => 'আজ';

  @override
  String periodSemantics(String name, String range, String active) {
    String _temp0 = intl.Intl.selectLogic(active, {
      'yes': ', এখন চলছে',
      'other': '',
    });
    return '$name, $range$_temp0';
  }

  @override
  String get periodShubh => 'শুভ সময়';

  @override
  String get periodAshubh => 'অশুভ সময়';

  @override
  String get verificationSample => 'নমুনা তথ্য';

  @override
  String get verificationComputed => 'গণনা করা, এখনও মেলানো হয়নি';

  @override
  String get verificationReferenceMatched => 'পঞ্জিকার সঙ্গে মেলানো';

  @override
  String get verificationExpertReviewed => 'বিশেষজ্ঞ যাচাই করেছেন';

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
    return 'আজ, $label';
  }

  @override
  String cityChipSemantics(String city) {
    return 'শহর: $city। বদলাতে ট্যাপ করুন';
  }

  @override
  String get glossaryTitle => 'শব্দকোষ';

  @override
  String get glossaryOpen => 'অর্থ দেখুন';

  @override
  String get loading => 'লোড হচ্ছে';

  @override
  String get languageNameBengali => 'বাংলা';

  @override
  String get languageNameEnglish => 'English';

  @override
  String termWithName(String term, String name) {
    return '$term: $name';
  }

  @override
  String get stateNotDownloaded => 'এই সময়ের তথ্য ডাউনলোড করা নেই।';

  @override
  String get stateOffline =>
      'ইন্টারনেট সংযোগ নেই। সংযোগ পেলে তথ্য ডাউনলোড হবে।';

  @override
  String get stateStale => 'তথ্য হালনাগাদ প্রয়োজন।';

  @override
  String get stateSignatureFailed =>
      'তথ্য যাচাই করা যায়নি, তাই দেখানো হচ্ছে না।';

  @override
  String get stateUnverified => 'এই তারিখ এখনও পঞ্জিকা মিলিয়ে দেখা হয়নি।';

  @override
  String get stateCheckClock => 'ফোনের তারিখ ঠিক আছে কিনা দেখুন';

  @override
  String get actionDownload => 'ডাউনলোড করুন';

  @override
  String get actionUpdate => 'হালনাগাদ করুন';

  @override
  String sizeMegabytes(String size) {
    return '$size এমবি';
  }

  @override
  String downloadPrompt(String size) {
    return 'নতুন তথ্য পাওয়া যাচ্ছে ($size)। এখন ডাউনলোড করবেন?';
  }

  @override
  String get actionLater => 'পরে';

  @override
  String get noticeDismiss => 'বুঝেছি';

  @override
  String get updateFailed =>
      'তথ্য ডাউনলোড করা যায়নি। পরে আবার চেষ্টা করা হবে।';

  @override
  String get appUpdateRequired => 'নতুন তথ্যের জন্য অ্যাপটি হালনাগাদ করুন।';

  @override
  String get labelTithi => 'তিথি';

  @override
  String get labelPaksha => 'পক্ষ';

  @override
  String get sectionSunMoon => 'সূর্য ও চন্দ্র';

  @override
  String get sectionObservances => 'উৎসব ও ব্রত';

  @override
  String get dayTitle => 'দিনের পঞ্জিকা';

  @override
  String get previousDay => 'আগের দিন';

  @override
  String get nextDay => 'পরের দিন';

  @override
  String coordinates(String lat, String lon) {
    return '$lat° উ, $lon° পূ';
  }

  @override
  String footerDetail(String coordinates, String packs, String status) {
    return '$coordinates · তথ্য: $packs · $status';
  }

  @override
  String get sectionUpcoming => 'আসছে';

  @override
  String get sectionToday => 'আজ';

  @override
  String get openDay => 'দিনের পুরো পঞ্জিকা দেখুন';

  @override
  String get calendarModeBengali => 'বাংলা মাস';

  @override
  String get calendarModeGregorian => 'ইংরেজি মাস';

  @override
  String monthTitle(String month, String year) {
    return '$month $year';
  }

  @override
  String get previousMonth => 'আগের মাস';

  @override
  String get nextMonth => 'পরের মাস';

  @override
  String get previousYear => 'আগের বছর';

  @override
  String get nextYear => 'পরের বছর';

  @override
  String get chooseMonth => 'মাস বেছে নিন';

  @override
  String get legendTitle => 'চিহ্নের অর্থ';

  @override
  String get legendFestival => 'উৎসব (রং বিভাগ অনুযায়ী)';

  @override
  String get legendSelected => 'নির্বাচিত দিন';

  @override
  String legendEither(String first, String second) {
    return '$first / $second';
  }

  @override
  String selectedDay(String date) {
    return 'নির্বাচিত: $date';
  }

  @override
  String get actionView => 'দেখুন';

  @override
  String get cityPickerTitle => 'শহর বেছে নিন';

  @override
  String get citySearchHint => 'শহরের নাম লিখুন';

  @override
  String get sectionRecent => 'সাম্প্রতিক';

  @override
  String get sectionWestBengal => 'পশ্চিমবঙ্গ';

  @override
  String get sectionOtherCities => 'অন্যান্য শহর';

  @override
  String sunriseAt(String time) {
    return 'সূর্যোদয় $time';
  }

  @override
  String cityRowSemantics(String city, String district, String sunrise) {
    return '$city, $district, $sunrise';
  }

  @override
  String get currentCity => 'বর্তমান শহর';

  @override
  String get noCityMatches => 'এই নামে কোনো শহর পাওয়া যায়নি';

  @override
  String get cityChanged =>
      'সূর্যোদয় ও রাহুকাল বদলেছে; তিথি ও উৎসবের তারিখ একই';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingNamesBoth => 'নাম দুই লিপিতে';

  @override
  String get settingTradition => 'পঞ্জিকার মত';

  @override
  String get settingCity => 'শহর';

  @override
  String get settingTheme => 'থিম';

  @override
  String get themeSystem => 'স্বয়ংক্রিয়';

  @override
  String get themeLight => 'হালকা';

  @override
  String get themeDark => 'গাঢ়';

  @override
  String get settingTextSize => 'লেখার আকার';

  @override
  String get textSizePreview => 'লেখা এই আকারে দেখাবে';

  @override
  String get settingTimeFormat => 'সময়ের ধরন';

  @override
  String timeFormatHours(String hours) {
    return '$hours ঘণ্টা';
  }

  @override
  String get settingNumerals => 'সংখ্যা';

  @override
  String get numeralsAuto => 'ভাষা অনুযায়ী';

  @override
  String numeralsBengali(String digits) {
    return 'বাংলা ($digits)';
  }

  @override
  String numeralsLatin(String digits) {
    return 'ইংরেজি ($digits)';
  }

  @override
  String get sectionData => 'তথ্য';

  @override
  String get checkDataNow => 'নতুন তথ্য আছে কিনা দেখুন';

  @override
  String get installedData => 'ডাউনলোড করা তথ্য';

  @override
  String dataRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get sectionOther => 'অন্যান্য';

  @override
  String get licences => 'লাইসেন্স';

  @override
  String get traditionConfirm =>
      'পঞ্জিকার মত বদলালে কিছু উৎসবের তারিখ বদলাতে পারে। অনুস্মারক নতুন করে সাজানো হবে।';

  @override
  String get actionChange => 'বদলান';

  @override
  String get actionKeep => 'থাক';

  @override
  String get moreTitle => 'আরও';

  @override
  String get menuReminders => 'অনুস্মারক';

  @override
  String get menuSearch => 'খুঁজুন';

  @override
  String get menuCity => 'শহর';

  @override
  String get menuGlossary => 'শব্দকোষ';

  @override
  String get menuSettings => 'সেটিংস';

  @override
  String get menuSources => 'তথ্যসূত্র ও যাচাই';

  @override
  String get menuReport => 'ভুল জানান';

  @override
  String get menuRemoveAds => 'বিজ্ঞাপন সরান';

  @override
  String get menuAbout => 'সম্পর্কে';

  @override
  String get menuPrivacy => 'গোপনীয়তা';

  @override
  String get aboutTagline =>
      'তিথি, উৎসব ও শুভ সময়ের বাংলা পঞ্জিকা, বাংলা ও ইংরেজিতে।';

  @override
  String aboutVersion(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get aboutDataHeading => 'তথ্য কোথা থেকে আসে';

  @override
  String get aboutDataBody =>
      'সূর্য ও চাঁদের অবস্থান হিসাব করা হয় NASA JPL-এর DE440s এফেমেরিস থেকে, Skyfield সফটওয়্যার দিয়ে। হিসাব আগে থেকে করা থাকে; ফোন শুধু সেই তথ্য পড়ে, কিছু আন্দাজ করে না।';

  @override
  String get aboutProvenance =>
      'প্রতিটি তথ্যের সঙ্গে তার পঞ্জিকার মত, শহর, সময় অঞ্চল ও যাচাইয়ের অবস্থা দেখানো হয়।';

  @override
  String bothLanguages(String bn, String en) {
    return '$bn · $en';
  }

  @override
  String onboardingStep(String step, String total) {
    return 'ধাপ $step/$total';
  }

  @override
  String get onboardingChooseLanguage => 'ভাষা বেছে নিন';

  @override
  String onboardingLanguagePreview(String tithi) {
    return 'যেমন: $tithi';
  }

  @override
  String get onboardingChangeLater => 'পরে সেটিংসে বদলানো যাবে।';

  @override
  String get actionContinue => 'এগিয়ে যান';

  @override
  String get onboardingTraditionTitle => 'কোন পঞ্জিকা মেনে চলেন?';

  @override
  String get onboardingTraditionNote =>
      'দুই মতে কখনো উৎসবের দিন আলাদা হয়। পরে সেটিংসে বদলাতে পারবেন।';

  @override
  String get onboardingCityTitle => 'আপনার শহর কোনটি?';

  @override
  String get onboardingCityNote =>
      'সূর্যোদয়, সূর্যাস্ত ও রাহুকাল শহর অনুযায়ী বদলায়। তিথি ও উৎসবের দিন বদলায় না।';

  @override
  String get onboardingRemindersTitle => 'অনুস্মারক চান?';

  @override
  String get onboardingRemindersBody =>
      'উৎসব, একাদশী, পূর্ণিমা ও অমাবস্যার আগে মনে করিয়ে দেওয়া যায়। কোনগুলি চান, তা অনুস্মারক অংশে বেছে নেবেন। প্রথম অনুস্মারক রাখার সময় ফোন অনুমতি চাইবে।';

  @override
  String get onboardingRemindersYes => 'হ্যাঁ, মনে করিয়ে দিন';

  @override
  String get onboardingRemindersNo => 'এখন নয়';

  @override
  String cityListProvenance(
    String tradition,
    String timeZone,
    String packs,
    String status,
  ) {
    return '$tradition · প্রতিটি শহরের আজকের সূর্যোদয়, $timeZone · তথ্য: $packs · $status';
  }

  @override
  String get useMyLocation => 'আমার অবস্থান ব্যবহার করুন';

  @override
  String get locating => 'অবস্থান খোঁজা হচ্ছে…';

  @override
  String get locationRationale =>
      'কাছের শহর খুঁজে দিতে ফোনের আনুমানিক অবস্থান লাগবে। অবস্থান শুধু এই ফোনেই ব্যবহার হয়; মনে রাখা হয় শুধু আপনার বেছে নেওয়া শহর।';

  @override
  String get actionNotNow => 'এখন নয়';

  @override
  String nearestCity(String city, String distance) {
    return 'নিকটতম শহর: $city, $distance কিমি';
  }

  @override
  String cityFarWarning(String limit) {
    return 'এই শহর $limit কিমির বেশি দূরে, তাই সময় কয়েক মিনিট আলাদা হতে পারে।';
  }

  @override
  String get actionChooseCity => 'এই শহর বেছে নিন';

  @override
  String get locationDenied =>
      'অনুমতি ছাড়াও অ্যাপ চলবে। তালিকা থেকে শহর বেছে নিন।';

  @override
  String get locationDeniedForever =>
      'অবস্থানের অনুমতি বন্ধ আছে। তালিকা থেকে শহর বেছে নিন, বা সেটিংসে অনুমতি দিন।';

  @override
  String get actionOpenSettings => 'সেটিংস খুলুন';

  @override
  String get locationOff => 'ফোনের লোকেশন বন্ধ আছে।';

  @override
  String get actionTurnOn => 'চালু করুন';

  @override
  String get locationUnavailable =>
      'অবস্থান পাওয়া যায়নি। তালিকা থেকে শহর বেছে নিন।';

  @override
  String get linkNotFound => 'এই পাতাটি পাওয়া যায়নি।';

  @override
  String get festivalNotFound => 'এই উৎসবের তথ্য এই ফোনে নেই।';

  @override
  String get goToToday => 'আজকের পঞ্জিকা দেখুন';

  @override
  String get numeralsBengaliSemantics => 'বাংলা সংখ্যা';

  @override
  String get numeralsLatinSemantics => 'ইংরেজি সংখ্যা';

  @override
  String festivalsTitle(String year) {
    return 'পার্বণ $year';
  }

  @override
  String get filterAll => 'সব';

  @override
  String get filterTitle => 'বাছাই';

  @override
  String get filterMonth => 'মাস';

  @override
  String get filterImportance => 'গুরুত্ব';

  @override
  String get tierMajor => 'প্রধান উৎসব';

  @override
  String get tierOther => 'অন্যান্য পার্বণ ও তিথি';

  @override
  String get tierCivic => 'জয়ন্তী ও স্মরণীয় দিন';

  @override
  String get showAll => 'সব দেখান';

  @override
  String get noFestivalsMatch => 'এই বাছাইয়ে কোনো পার্বণ নেই।';

  @override
  String get festivalYearPartial => 'এই বছরের কয়েকটি মাসের তথ্য এই ফোনে নেই।';

  @override
  String festivalRowDates(String gregorian, String bengali) {
    return '$gregorian · $bengali';
  }

  @override
  String festivalDayOf(String day) {
    return 'দিন $day';
  }

  @override
  String get windowSandhiPuja => 'সন্ধিপূজা';

  @override
  String windowSandhiPujaHint(String minutes) {
    return 'অষ্টমীর শেষ $minutes মিনিট ও নবমীর প্রথম $minutes মিনিট';
  }

  @override
  String get windowNishita => 'নিশীথ';

  @override
  String get windowPratah => 'প্রাতঃকাল';

  @override
  String get windowMadhyahna => 'মধ্যাহ্ন';

  @override
  String get windowAparahna => 'অপরাহ্ণ';

  @override
  String get windowPradosha => 'প্রদোষ';

  @override
  String festivalTithiSpan(String name, String start, String end) {
    return '$name · $start থেকে $end';
  }

  @override
  String checkedOn(String date) {
    return 'যাচাই: $date';
  }

  @override
  String get reminderOff => 'মনে করিয়ে দিন';

  @override
  String get reminderOn => 'অনুস্মারক চালু আছে';

  @override
  String get festivalDaysLabel => 'দিনগুলি';

  @override
  String reminderTomorrow(String name) {
    return 'আগামীকাল $name';
  }

  @override
  String reminderToday(String name) {
    return 'আজ $name';
  }

  @override
  String reminderTithiBegun(String name) {
    return '$name শুরু হলো';
  }

  @override
  String reminderTithiBegins(String time) {
    return 'তিথি শুরু $time';
  }

  @override
  String reminderBody(String detail, String tradition, String timeZone) {
    return '$detail · $tradition · $timeZone';
  }

  @override
  String get channelFestival => 'উৎসব অনুস্মারক';

  @override
  String get channelFestivalDescription =>
      'আপনার বেছে নেওয়া পার্বণের আগে মনে করিয়ে দেয়।';

  @override
  String get channelTithi => 'তিথি অনুস্মারক';

  @override
  String get channelTithiDescription =>
      'একাদশী, পূর্ণিমা ও অমাবস্যার অনুস্মারক।';

  @override
  String get notificationsOff =>
      'বিজ্ঞপ্তির অনুমতি নেই, তাই অনুস্মারক দেখানো যাবে না। ফোনের সেটিংসে এই অ্যাপের বিজ্ঞপ্তি চালু করুন।';

  @override
  String get sectionRecurring => 'নিয়মিত';

  @override
  String get sectionFestivalReminders => 'উৎসব';

  @override
  String get recurringEkadashi => 'একাদশী';

  @override
  String get recurringPurnima => 'পূর্ণিমা';

  @override
  String get recurringAmavasya => 'অমাবস্যা';

  @override
  String timingDayBefore(String time) {
    return 'আগের দিন $time';
  }

  @override
  String timingMorningOf(String time) {
    return 'সেদিন $time';
  }

  @override
  String get timingTithiStart => 'তিথি শুরুর সময়';

  @override
  String timingBoth(String first, String second) {
    return '$first ও $second';
  }

  @override
  String get addFestivalReminder => 'উৎসব যোগ করুন';

  @override
  String get remindersEmpty =>
      'এখনো কোনো অনুস্মারক নেই। একাদশী বা কোনো উৎসবের জন্য চালু করুন।';

  @override
  String get timingSheetTitle => 'কখন মনে করাবে?';

  @override
  String get timingDayBeforeOption => 'আগের দিন';

  @override
  String get timingMorningOption => 'সেদিন সকালে';

  @override
  String get changeTime => 'সময় বদলান';

  @override
  String shareProvenance(String tradition) {
    return '$tradition মতে';
  }

  @override
  String shareProvenanceWithPlace(
    String tradition,
    String city,
    String timeZone,
  ) {
    return '$tradition মতে · $city · $timeZone';
  }

  @override
  String shareFestivalMessage(String name, String date) {
    return '$name: $date';
  }

  @override
  String shareDayMessage(String date, String tithi) {
    return '$date · $tithi';
  }

  @override
  String get shareAction => 'শেয়ার করুন';

  @override
  String get shareSheetTitle => 'শেয়ার কার্ড';

  @override
  String get shareInBoth => 'দুই ভাষায়';

  @override
  String get sectionTerms => 'পঞ্জিকার শব্দ';

  @override
  String get sectionPeriods => 'দিনের নানা সময়';

  @override
  String get glossarySearchHint => 'শব্দ খুঁজুন';

  @override
  String get noGlossaryMatches => 'এই নামে কোনো শব্দ পাওয়া যায়নি';

  @override
  String get searchHint => 'তারিখ বা উৎসবের নাম';

  @override
  String get searchExamples => 'উদাহরণ: ২৫ আশ্বিন ১৪৩৩ · ১২/১০/২০২৬ · কালীপূজা';

  @override
  String get searchResults => 'ফলাফল';

  @override
  String searchDateEquals(String bengali, String gregorian) {
    return '$bengali = $gregorian';
  }

  @override
  String searchDateNotInstalled(String date) {
    return '$date: এই তারিখের তথ্য এই ফোনে নেই';
  }

  @override
  String get searchNoResults =>
      'কিছু পাওয়া যায়নি। বানান বা তারিখের ধরন দেখে নিন।';

  @override
  String get sourcesTraditionHeading => 'পঞ্জিকার মত';

  @override
  String sourcesTraditionBody(String tradition) {
    return 'এই অ্যাপের সব তারিখ ও সময় $tradition মতে, যা সেটিংসে বেছে নেওয়া আছে।';
  }

  @override
  String get sourcesHowHeading => 'আমরা কীভাবে হিসাব করি';

  @override
  String get sourcesStep1Title => 'জ্যোতির্বিজ্ঞানের হিসাব (NASA JPL)';

  @override
  String get sourcesStep1Body =>
      'সূর্য ও চাঁদের অবস্থান NASA JPL-এর DE440s তালিকা থেকে, Skyfield সফটওয়্যারে আগেই হিসাব করা থাকে।';

  @override
  String get sourcesStep2Title => 'রাষ্ট্রীয় পঞ্চাঙ্গের সঙ্গে মিলানো';

  @override
  String get sourcesStep2Body =>
      'তিথি, নক্ষত্র ও অন্যান্য সময় ভারত সরকারের জাতীয় পঞ্চাঙ্গের সঙ্গে মিলিয়ে দেখা হয়।';

  @override
  String get sourcesStep3Title => 'মুদ্রিত পঞ্জিকার সঙ্গে মিলানো';

  @override
  String get sourcesStep3Body =>
      'বাংলা তারিখ ও উৎসবের দিন মুদ্রিত পঞ্জিকার সঙ্গে মিলিয়ে দেখা হয়।';

  @override
  String get sourcesStep4Title => 'প্রধান উৎসব বিশেষজ্ঞের যাচাই';

  @override
  String get sourcesStep4Body =>
      'প্রধান উৎসবের নিয়ম একজন পঞ্জিকা-বিশেষজ্ঞ দেখে নেন।';

  @override
  String get sourcesStepsNote =>
      'প্রতিটি তথ্য কোন ধাপ পর্যন্ত যাচাই হয়েছে, তা পাশের চিহ্নে দেখা যায়।';

  @override
  String get sourcesMarksHeading => 'চিহ্নের অর্থ';

  @override
  String get sourcesPhoneHeading => 'এই ফোনের তথ্য';

  @override
  String get packKindGlobal => 'পঞ্চাঙ্গের তথ্য';

  @override
  String get packKindCities => 'শহরের তথ্য';

  @override
  String get packKindObservances => 'উৎসবের তথ্য';

  @override
  String sourcesPackTitle(String kind, String version) {
    return '$kind · সংস্করণ $version';
  }

  @override
  String sourcesPackScope(String tradition, String range) {
    return '$tradition · $range';
  }

  @override
  String sourcesValidatedOn(String date) {
    return 'শেষ যাচাই: $date';
  }

  @override
  String get sourcesNotValidated => 'এখনও মিলিয়ে দেখা হয়নি';

  @override
  String get sourcesNoPacks => 'এই ফোনে এখনও কোনো তথ্য নেই।';

  @override
  String get sourcesWhyLink => 'দুই মত কেন আলাদা?';

  @override
  String get schoolsPara1 =>
      'পশ্চিমবঙ্গে পঞ্জিকার দুটি মত চালু আছে। বিশুদ্ধ সিদ্ধান্ত (দৃক) মত সূর্য ও চাঁদের আধুনিক জ্যোতির্বিজ্ঞানসম্মত অবস্থান থেকে হিসাব করে; ভারত সরকারের জাতীয় পঞ্চাঙ্গও এই পদ্ধতিতে তৈরি। সূর্যসিদ্ধান্ত মত, যা গুপ্তপ্রেস ও আরও কয়েকটি পঞ্জিকা মেনে চলে, প্রাচীন সূর্যসিদ্ধান্ত গ্রন্থের হিসাব আর রঘুনন্দনের বিধান অনুসরণ করে।';

  @override
  String get schoolsPara2 =>
      'দুই হিসাবে সূর্য ও চাঁদের অবস্থান সামান্য আলাদা আসে, তাই একই তিথি দুই মতে ভিন্ন সময়ে শেষ হয় — কখনো কয়েক মিনিট, কখনো আরও বেশি তফাতে। সূর্যোদয়ের সময় যে তিথি চলে, সেটাই সেদিনের তিথি। তাই তিথি সূর্যোদয়ের কাছাকাছি শেষ হলে দুই মতে একই সকালের তিথি আলাদা হতে পারে, আর তাতে কোনো উৎসব এক দিন আগে বা পরে পড়ে।';

  @override
  String get schoolsPara3 =>
      'এর কোনোটিই ভুল নয়; দুটিই দীর্ঘদিনের প্রচলিত গণনারীতি। এই অ্যাপ প্রতিটি তারিখের সঙ্গে জানায় সেটি কোন মতে। এখন অ্যাপে বিশুদ্ধ সিদ্ধান্ত মত আছে, সূর্যসিদ্ধান্ত মত পরে আসবে। আপনার পরিবার যে পঞ্জিকা মানে, তার সঙ্গে মিলিয়ে নিন।';
}
