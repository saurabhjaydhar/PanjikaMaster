import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// App name in the task switcher and app bar. Placeholder until Q11.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা পঞ্জিকা'**
  String get appTitle;

  /// Bottom navigation tab: today's panjika. Max ~8 characters.
  ///
  /// In bn, this message translates to:
  /// **'আজ'**
  String get navToday;

  /// Bottom navigation tab: month calendar. Max ~8 characters.
  ///
  /// In bn, this message translates to:
  /// **'পঞ্জিকা'**
  String get navCalendar;

  /// Bottom navigation tab: festival list. Max ~8 characters.
  ///
  /// In bn, this message translates to:
  /// **'পার্বণ'**
  String get navFestivals;

  /// Bottom navigation tab: more options. Max ~8 characters.
  ///
  /// In bn, this message translates to:
  /// **'আরও'**
  String get navMore;

  /// How long a tithi/nakshatra/period lasts, e.g. 'দুপুর ২:৩২ পর্যন্ত'. The time is already formatted.
  ///
  /// In bn, this message translates to:
  /// **'{time} পর্যন্ত'**
  String untilTime(String time);

  /// The next tithi after the current one ends, e.g. 'তারপর অষ্টমী'.
  ///
  /// In bn, this message translates to:
  /// **'তারপর {name}'**
  String thenName(String name);

  /// A time after midnight that still belongs to this panjika day (spec §12.4).
  ///
  /// In bn, this message translates to:
  /// **'{time} (পরদিন)'**
  String nextDayTime(String time);

  /// Days until an observance. count picks the form; countText is count formatted with the user's numerals.
  ///
  /// In bn, this message translates to:
  /// **'{count, plural, =0{আজ} =1{আগামীকাল} other{{countText} দিন বাকি}}'**
  String countdownDays(int count, String countText);

  /// Label shown with every panjika time (Indian Standard Time). Same in both languages.
  ///
  /// In bn, this message translates to:
  /// **'IST'**
  String get timeZoneLabel;

  /// Diagonal watermark on sample (fixture) data, debug builds only. Same in both languages on purpose.
  ///
  /// In bn, this message translates to:
  /// **'নমুনা · SAMPLE'**
  String get sampleWatermark;

  /// Settings row label for choosing the app language.
  ///
  /// In bn, this message translates to:
  /// **'ভাষা'**
  String get languageSetting;

  /// Marks an option that is not available yet.
  ///
  /// In bn, this message translates to:
  /// **'শীঘ্রই আসছে'**
  String get comingSoon;

  /// Row label on Today/Day: the lunar mansion (nakshatra).
  ///
  /// In bn, this message translates to:
  /// **'নক্ষত্র'**
  String get labelNakshatra;

  /// Row label: the yoga (sum of Sun and Moon longitudes).
  ///
  /// In bn, this message translates to:
  /// **'যোগ'**
  String get labelYoga;

  /// Row label: the karana (half-tithi).
  ///
  /// In bn, this message translates to:
  /// **'করণ'**
  String get labelKarana;

  /// Timing strip label: sunrise for the selected city.
  ///
  /// In bn, this message translates to:
  /// **'সূর্যোদয়'**
  String get labelSunrise;

  /// Timing strip label: sunset.
  ///
  /// In bn, this message translates to:
  /// **'সূর্যাস্ত'**
  String get labelSunset;

  /// Timing strip label: moonrise.
  ///
  /// In bn, this message translates to:
  /// **'চন্দ্রোদয়'**
  String get labelMoonrise;

  /// Timing strip label: moonset.
  ///
  /// In bn, this message translates to:
  /// **'চন্দ্রাস্ত'**
  String get labelMoonset;

  /// Shown instead of a time when there is no moonrise/moonset that day (spec §16).
  ///
  /// In bn, this message translates to:
  /// **'নেই'**
  String get timeNone;

  /// Shown on Today when no data covers today (US-01). Never show numbers in this state.
  ///
  /// In bn, this message translates to:
  /// **'আজকের তথ্য পাওয়া যায়নি'**
  String get todayDataMissing;

  /// Button: try loading the data again.
  ///
  /// In bn, this message translates to:
  /// **'আবার চেষ্টা করুন'**
  String get retry;

  /// Footer on every date screen (spec §6.8, FR-DAY-04).
  ///
  /// In bn, this message translates to:
  /// **'{tradition} · {city} · {timeZone}'**
  String provenance(String tradition, String city, String timeZone);

  /// Screen-reader sentence for the tithi seal (spec §13.7).
  ///
  /// In bn, this message translates to:
  /// **'তিথি {tithi}, {until}, {then}'**
  String tithiSealSemantics(String tithi, String until, String then);

  /// A name followed by how long it lasts, e.g. 'মূলা · বিকেল ৪:১০ পর্যন্ত'.
  ///
  /// In bn, this message translates to:
  /// **'{name} · {until}'**
  String nameWithUntil(String name, String until);

  /// Tag on the period row that is running right now (not colour alone, spec §12.5).
  ///
  /// In bn, this message translates to:
  /// **'এখন'**
  String get labelNow;

  /// Screen-reader prefix for today's calendar cell.
  ///
  /// In bn, this message translates to:
  /// **'আজ'**
  String get labelToday;

  /// Screen-reader label of a period row. active is yes or no.
  ///
  /// In bn, this message translates to:
  /// **'{name}, {range}{active, select, yes{, এখন চলছে} other{}}'**
  String periodSemantics(String name, String range, String active);

  /// Section title for auspicious periods.
  ///
  /// In bn, this message translates to:
  /// **'শুভ সময়'**
  String get periodShubh;

  /// Section title for inauspicious periods (Rahu Kaal etc.).
  ///
  /// In bn, this message translates to:
  /// **'অশুভ সময়'**
  String get periodAshubh;

  /// Verification label: fixture data in debug builds.
  ///
  /// In bn, this message translates to:
  /// **'নমুনা তথ্য'**
  String get verificationSample;

  /// Verification label: computed but not checked against the reference panjika.
  ///
  /// In bn, this message translates to:
  /// **'গণনা করা, এখনও মেলানো হয়নি'**
  String get verificationComputed;

  /// Verification label: matches the reference panjika.
  ///
  /// In bn, this message translates to:
  /// **'পঞ্জিকার সঙ্গে মেলানো'**
  String get verificationReferenceMatched;

  /// Verification label: reviewed by the expert.
  ///
  /// In bn, this message translates to:
  /// **'বিশেষজ্ঞ যাচাই করেছেন'**
  String get verificationExpertReviewed;

  /// Screen-reader label of a calendar day without festivals. Layout only.
  ///
  /// In bn, this message translates to:
  /// **'{bengaliDate}, {gregorianDate}, {tithi}'**
  String calendarCellSemantics(
    String bengaliDate,
    String gregorianDate,
    String tithi,
  );

  /// Screen-reader label of a calendar day with a festival. Layout only.
  ///
  /// In bn, this message translates to:
  /// **'{bengaliDate}, {gregorianDate}, {tithi}, {festival}'**
  String calendarCellWithFestival(
    String bengaliDate,
    String gregorianDate,
    String tithi,
    String festival,
  );

  /// Screen-reader label for today's calendar cell.
  ///
  /// In bn, this message translates to:
  /// **'আজ, {label}'**
  String todayPrefix(String label);

  /// Screen-reader label of the city chip.
  ///
  /// In bn, this message translates to:
  /// **'শহর: {city}। বদলাতে ট্যাপ করুন'**
  String cityChipSemantics(String city);

  /// Title of the glossary sheet and screen (FR-SET-07).
  ///
  /// In bn, this message translates to:
  /// **'শব্দকোষ'**
  String get glossaryTitle;

  /// Tooltip of the (i) button next to a panjika term.
  ///
  /// In bn, this message translates to:
  /// **'অর্থ দেখুন'**
  String get glossaryOpen;

  /// Screen-reader label of loading placeholders.
  ///
  /// In bn, this message translates to:
  /// **'লোড হচ্ছে'**
  String get loading;

  /// The Bengali language, always written in Bengali (language switch). Same in both languages on purpose.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা'**
  String get languageNameBengali;

  /// The English language, always written in English (language switch). Same in both languages on purpose.
  ///
  /// In bn, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// A term with a name, e.g. 'ক্ষয় তিথি: অষ্টমী'. Layout only.
  ///
  /// In bn, this message translates to:
  /// **'{term}: {name}'**
  String termWithName(String term, String name);

  /// System state (spec §11.9).
  ///
  /// In bn, this message translates to:
  /// **'এই সময়ের তথ্য ডাউনলোড করা নেই।'**
  String get stateNotDownloaded;

  /// System state (spec §11.9).
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট সংযোগ নেই। সংযোগ পেলে তথ্য ডাউনলোড হবে।'**
  String get stateOffline;

  /// System state (spec §11.9).
  ///
  /// In bn, this message translates to:
  /// **'তথ্য হালনাগাদ প্রয়োজন।'**
  String get stateStale;

  /// System state (spec §11.9).
  ///
  /// In bn, this message translates to:
  /// **'তথ্য যাচাই করা যায়নি, তাই দেখানো হচ্ছে না।'**
  String get stateSignatureFailed;

  /// System state for tier 2/3 festivals (spec §11.9).
  ///
  /// In bn, this message translates to:
  /// **'এই তারিখ এখনও পঞ্জিকা মিলিয়ে দেখা হয়নি।'**
  String get stateUnverified;

  /// Shown when the device date is outside every pack (spec §16).
  ///
  /// In bn, this message translates to:
  /// **'ফোনের তারিখ ঠিক আছে কিনা দেখুন'**
  String get stateCheckClock;

  /// Button: download data.
  ///
  /// In bn, this message translates to:
  /// **'ডাউনলোড করুন'**
  String get actionDownload;

  /// Button: update data.
  ///
  /// In bn, this message translates to:
  /// **'হালনাগাদ করুন'**
  String get actionUpdate;

  /// A download size; size is formatted with the user's numerals, e.g. ৩.১.
  ///
  /// In bn, this message translates to:
  /// **'{size} এমবি'**
  String sizeMegabytes(String size);

  /// Asked before downloading a pack of 2 MB or more (spec §18).
  ///
  /// In bn, this message translates to:
  /// **'নতুন তথ্য পাওয়া যাচ্ছে ({size})। এখন ডাউনলোড করবেন?'**
  String downloadPrompt(String size);

  /// Button: decide later.
  ///
  /// In bn, this message translates to:
  /// **'পরে'**
  String get actionLater;

  /// Button that hides a notice from the server.
  ///
  /// In bn, this message translates to:
  /// **'বুঝেছি'**
  String get noticeDismiss;

  /// Shown when a pack download or import fails.
  ///
  /// In bn, this message translates to:
  /// **'তথ্য ডাউনলোড করা যায়নি। পরে আবার চেষ্টা করা হবে।'**
  String get updateFailed;

  /// The data server needs a newer app version (min_app_version).
  ///
  /// In bn, this message translates to:
  /// **'নতুন তথ্যের জন্য অ্যাপটি হালনাগাদ করুন।'**
  String get appUpdateRequired;

  /// Row label: tithi.
  ///
  /// In bn, this message translates to:
  /// **'তিথি'**
  String get labelTithi;

  /// Row label: paksha (fortnight).
  ///
  /// In bn, this message translates to:
  /// **'পক্ষ'**
  String get labelPaksha;

  /// Day detail section title.
  ///
  /// In bn, this message translates to:
  /// **'সূর্য ও চন্দ্র'**
  String get sectionSunMoon;

  /// Day detail section title.
  ///
  /// In bn, this message translates to:
  /// **'উৎসব ও ব্রত'**
  String get sectionObservances;

  /// Title of the Day detail screen.
  ///
  /// In bn, this message translates to:
  /// **'দিনের পঞ্জিকা'**
  String get dayTitle;

  /// Button / screen-reader label: go to the previous day.
  ///
  /// In bn, this message translates to:
  /// **'আগের দিন'**
  String get previousDay;

  /// Button / screen-reader label: go to the next day.
  ///
  /// In bn, this message translates to:
  /// **'পরের দিন'**
  String get nextDay;

  /// A city's latitude (north) and longitude (east), numbers already formatted.
  ///
  /// In bn, this message translates to:
  /// **'{lat}° উ, {lon}° পূ'**
  String coordinates(String lat, String lon);

  /// Second provenance line on Day detail: coordinates, data packs, verification status.
  ///
  /// In bn, this message translates to:
  /// **'{coordinates} · তথ্য: {packs} · {status}'**
  String footerDetail(String coordinates, String packs, String status);

  /// Today: section with the next festivals.
  ///
  /// In bn, this message translates to:
  /// **'আসছে'**
  String get sectionUpcoming;

  /// Today: section with today's festivals.
  ///
  /// In bn, this message translates to:
  /// **'আজ'**
  String get sectionToday;

  /// Screen-reader hint on the tithi seal: opens Day detail.
  ///
  /// In bn, this message translates to:
  /// **'দিনের পুরো পঞ্জিকা দেখুন'**
  String get openDay;

  /// Calendar mode: months of the Bengali calendar.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা মাস'**
  String get calendarModeBengali;

  /// Calendar mode: Gregorian months.
  ///
  /// In bn, this message translates to:
  /// **'ইংরেজি মাস'**
  String get calendarModeGregorian;

  /// Calendar title, e.g. আশ্বিন ১৪৩৩. Layout only.
  ///
  /// In bn, this message translates to:
  /// **'{month} {year}'**
  String monthTitle(String month, String year);

  /// Button: previous month.
  ///
  /// In bn, this message translates to:
  /// **'আগের মাস'**
  String get previousMonth;

  /// Button: next month.
  ///
  /// In bn, this message translates to:
  /// **'পরের মাস'**
  String get nextMonth;

  /// Button in the month chooser.
  ///
  /// In bn, this message translates to:
  /// **'আগের বছর'**
  String get previousYear;

  /// Button in the month chooser.
  ///
  /// In bn, this message translates to:
  /// **'পরের বছর'**
  String get nextYear;

  /// Title of the jump-to-month sheet; also the hint on the calendar title.
  ///
  /// In bn, this message translates to:
  /// **'মাস বেছে নিন'**
  String get chooseMonth;

  /// Title of the calendar legend sheet.
  ///
  /// In bn, this message translates to:
  /// **'চিহ্নের অর্থ'**
  String get legendTitle;

  /// Legend: the coloured bar under a day.
  ///
  /// In bn, this message translates to:
  /// **'উৎসব (রং বিভাগ অনুযায়ী)'**
  String get legendFestival;

  /// Legend: the filled day.
  ///
  /// In bn, this message translates to:
  /// **'নির্বাচিত দিন'**
  String get legendSelected;

  /// Two names for one mark, e.g. both Ekadashis. Layout only.
  ///
  /// In bn, this message translates to:
  /// **'{first} / {second}'**
  String legendEither(String first, String second);

  /// Calendar strip under the grid.
  ///
  /// In bn, this message translates to:
  /// **'নির্বাচিত: {date}'**
  String selectedDay(String date);

  /// Button: open the day.
  ///
  /// In bn, this message translates to:
  /// **'দেখুন'**
  String get actionView;

  /// Title of the city picker.
  ///
  /// In bn, this message translates to:
  /// **'শহর বেছে নিন'**
  String get cityPickerTitle;

  /// Hint in the city search field (Bengali or English).
  ///
  /// In bn, this message translates to:
  /// **'শহরের নাম লিখুন'**
  String get citySearchHint;

  /// City picker section: recently chosen cities.
  ///
  /// In bn, this message translates to:
  /// **'সাম্প্রতিক'**
  String get sectionRecent;

  /// City picker section: cities in West Bengal.
  ///
  /// In bn, this message translates to:
  /// **'পশ্চিমবঙ্গ'**
  String get sectionWestBengal;

  /// City picker section: cities outside West Bengal.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য শহর'**
  String get sectionOtherCities;

  /// Today's sunrise in a city row.
  ///
  /// In bn, this message translates to:
  /// **'সূর্যোদয় {time}'**
  String sunriseAt(String time);

  /// Screen-reader label of a city row. Layout only.
  ///
  /// In bn, this message translates to:
  /// **'{city}, {district}, {sunrise}'**
  String cityRowSemantics(String city, String district, String sunrise);

  /// Screen-reader state of the chosen city's row.
  ///
  /// In bn, this message translates to:
  /// **'বর্তমান শহর'**
  String get currentCity;

  /// City search with no results.
  ///
  /// In bn, this message translates to:
  /// **'এই নামে কোনো শহর পাওয়া যায়নি'**
  String get noCityMatches;

  /// Toast after changing the city (FR-LOC-05).
  ///
  /// In bn, this message translates to:
  /// **'সূর্যোদয় ও রাহুকাল বদলেছে; তিথি ও উৎসবের তারিখ একই'**
  String get cityChanged;

  /// Title of the Settings screen.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস'**
  String get settingsTitle;

  /// Setting: show panchanga and festival names in the other script too (FR-SET-06).
  ///
  /// In bn, this message translates to:
  /// **'নাম দুই লিপিতে'**
  String get settingNamesBoth;

  /// Setting: which panjika tradition (school) to follow.
  ///
  /// In bn, this message translates to:
  /// **'পঞ্জিকার মত'**
  String get settingTradition;

  /// Setting: the chosen city.
  ///
  /// In bn, this message translates to:
  /// **'শহর'**
  String get settingCity;

  /// Setting: light, dark or follow the phone.
  ///
  /// In bn, this message translates to:
  /// **'থিম'**
  String get settingTheme;

  /// Theme option: follow the phone.
  ///
  /// In bn, this message translates to:
  /// **'স্বয়ংক্রিয়'**
  String get themeSystem;

  /// Theme option.
  ///
  /// In bn, this message translates to:
  /// **'হালকা'**
  String get themeLight;

  /// Theme option.
  ///
  /// In bn, this message translates to:
  /// **'গাঢ়'**
  String get themeDark;

  /// Setting: text size, on top of the phone's own setting.
  ///
  /// In bn, this message translates to:
  /// **'লেখার আকার'**
  String get settingTextSize;

  /// Preview line under the text size slider.
  ///
  /// In bn, this message translates to:
  /// **'লেখা এই আকারে দেখাবে'**
  String get textSizePreview;

  /// Setting: 12- or 24-hour times.
  ///
  /// In bn, this message translates to:
  /// **'সময়ের ধরন'**
  String get settingTimeFormat;

  /// A time format option; hours is 12 or 24 in the user's numerals.
  ///
  /// In bn, this message translates to:
  /// **'{hours} ঘণ্টা'**
  String timeFormatHours(String hours);

  /// Setting: Bengali or Latin digits (FR-L10N-04).
  ///
  /// In bn, this message translates to:
  /// **'সংখ্যা'**
  String get settingNumerals;

  /// Numerals option: Bengali digits in Bengali, Latin in English.
  ///
  /// In bn, this message translates to:
  /// **'ভাষা অনুযায়ী'**
  String get numeralsAuto;

  /// Numerals option; digits shows Bengali digits as an example.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা ({digits})'**
  String numeralsBengali(String digits);

  /// Numerals option; digits shows Latin digits as an example.
  ///
  /// In bn, this message translates to:
  /// **'ইংরেজি ({digits})'**
  String numeralsLatin(String digits);

  /// Settings section about the data packs.
  ///
  /// In bn, this message translates to:
  /// **'তথ্য'**
  String get sectionData;

  /// Settings row: check the server for new packs now.
  ///
  /// In bn, this message translates to:
  /// **'নতুন তথ্য আছে কিনা দেখুন'**
  String get checkDataNow;

  /// Settings row: the dates the installed data covers.
  ///
  /// In bn, this message translates to:
  /// **'ডাউনলোড করা তথ্য'**
  String get installedData;

  /// A date range. Layout only.
  ///
  /// In bn, this message translates to:
  /// **'{from} – {to}'**
  String dataRange(String from, String to);

  /// Settings section with licences etc.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য'**
  String get sectionOther;

  /// Opens the open-source licences.
  ///
  /// In bn, this message translates to:
  /// **'লাইসেন্স'**
  String get licences;

  /// Confirm sheet before changing the tradition (spec §11.15).
  ///
  /// In bn, this message translates to:
  /// **'পঞ্জিকার মত বদলালে কিছু উৎসবের তারিখ বদলাতে পারে। অনুস্মারক নতুন করে সাজানো হবে।'**
  String get traditionConfirm;

  /// Button: confirm a change.
  ///
  /// In bn, this message translates to:
  /// **'বদলান'**
  String get actionChange;

  /// Button: keep the current choice.
  ///
  /// In bn, this message translates to:
  /// **'থাক'**
  String get actionKeep;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
