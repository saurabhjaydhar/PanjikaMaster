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
}
