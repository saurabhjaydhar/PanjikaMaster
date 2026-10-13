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

  /// Title of the More tab (spec §10).
  ///
  /// In bn, this message translates to:
  /// **'আরও'**
  String get moreTitle;

  /// More menu: reminders screen (§11.13).
  ///
  /// In bn, this message translates to:
  /// **'অনুস্মারক'**
  String get menuReminders;

  /// More menu: search screen (§11.14).
  ///
  /// In bn, this message translates to:
  /// **'খুঁজুন'**
  String get menuSearch;

  /// More menu: city picker (§11.12).
  ///
  /// In bn, this message translates to:
  /// **'শহর'**
  String get menuCity;

  /// More menu: glossary of panjika terms.
  ///
  /// In bn, this message translates to:
  /// **'শব্দকোষ'**
  String get menuGlossary;

  /// More menu: settings (§11.15).
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস'**
  String get menuSettings;

  /// More menu: how the data is computed and checked (§11.16).
  ///
  /// In bn, this message translates to:
  /// **'তথ্যসূত্র ও যাচাই'**
  String get menuSources;

  /// More menu: report a wrong date or time (§11.17).
  ///
  /// In bn, this message translates to:
  /// **'ভুল জানান'**
  String get menuReport;

  /// More menu: remove-ads purchase (§11.18).
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞাপন সরান'**
  String get menuRemoveAds;

  /// More menu and Settings: the About screen.
  ///
  /// In bn, this message translates to:
  /// **'সম্পর্কে'**
  String get menuAbout;

  /// More menu and Settings: privacy policy.
  ///
  /// In bn, this message translates to:
  /// **'গোপনীয়তা'**
  String get menuPrivacy;

  /// One-line description of the app on the About screen.
  ///
  /// In bn, this message translates to:
  /// **'তিথি, উৎসব ও শুভ সময়ের বাংলা পঞ্জিকা, বাংলা ও ইংরেজিতে।'**
  String get aboutTagline;

  /// App version on the About screen; version is formatted with the user's numerals, e.g. ১.০.০.
  ///
  /// In bn, this message translates to:
  /// **'সংস্করণ {version}'**
  String aboutVersion(String version);

  /// About screen section heading.
  ///
  /// In bn, this message translates to:
  /// **'তথ্য কোথা থেকে আসে'**
  String get aboutDataHeading;

  /// About screen: how the data is made (spec §6, PRD §1).
  ///
  /// In bn, this message translates to:
  /// **'সূর্য ও চাঁদের অবস্থান হিসাব করা হয় NASA JPL-এর DE440s এফেমেরিস থেকে, Skyfield সফটওয়্যার দিয়ে। হিসাব আগে থেকে করা থাকে; ফোন শুধু সেই তথ্য পড়ে, কিছু আন্দাজ করে না।'**
  String get aboutDataBody;

  /// About screen: the provenance promise.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি তথ্যের সঙ্গে তার পঞ্জিকার মত, শহর, সময় অঞ্চল ও যাচাইয়ের অবস্থা দেখানো হয়।'**
  String get aboutProvenance;

  /// Layout pattern: the same text in Bengali then English, on the first onboarding step before a language is chosen.
  ///
  /// In bn, this message translates to:
  /// **'{bn} · {en}'**
  String bothLanguages(String bn, String en);

  /// Screen-reader label of the onboarding progress dots; numbers are formatted with the user's numerals.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ {step}/{total}'**
  String onboardingStep(String step, String total);

  /// Onboarding step 1 heading (spec §11.1).
  ///
  /// In bn, this message translates to:
  /// **'ভাষা বেছে নিন'**
  String get onboardingChooseLanguage;

  /// Preview line under each language option; tithi is a tithi name from the pack's names table (not today's data).
  ///
  /// In bn, this message translates to:
  /// **'যেমন: {tithi}'**
  String onboardingLanguagePreview(String tithi);

  /// Onboarding step 1 note.
  ///
  /// In bn, this message translates to:
  /// **'পরে সেটিংসে বদলানো যাবে।'**
  String get onboardingChangeLater;

  /// Onboarding primary button.
  ///
  /// In bn, this message translates to:
  /// **'এগিয়ে যান'**
  String get actionContinue;

  /// Onboarding step 2 heading (spec §11.1, US-02).
  ///
  /// In bn, this message translates to:
  /// **'কোন পঞ্জিকা মেনে চলেন?'**
  String get onboardingTraditionTitle;

  /// Onboarding step 2 note (spec §11.1).
  ///
  /// In bn, this message translates to:
  /// **'দুই মতে কখনো উৎসবের দিন আলাদা হয়। পরে সেটিংসে বদলাতে পারবেন।'**
  String get onboardingTraditionNote;

  /// Onboarding step 3 heading.
  ///
  /// In bn, this message translates to:
  /// **'আপনার শহর কোনটি?'**
  String get onboardingCityTitle;

  /// Onboarding step 3 note (FR-LOC-05).
  ///
  /// In bn, this message translates to:
  /// **'সূর্যোদয়, সূর্যাস্ত ও রাহুকাল শহর অনুযায়ী বদলায়। তিথি ও উৎসবের দিন বদলায় না।'**
  String get onboardingCityNote;

  /// Onboarding step 4 heading (optional step).
  ///
  /// In bn, this message translates to:
  /// **'অনুস্মারক চান?'**
  String get onboardingRemindersTitle;

  /// Onboarding step 4 explanation; the permission prompt comes later (T-507).
  ///
  /// In bn, this message translates to:
  /// **'উৎসব, একাদশী, পূর্ণিমা ও অমাবস্যার আগে মনে করিয়ে দেওয়া যায়। কোনগুলি চান, তা অনুস্মারক অংশে বেছে নেবেন। প্রথম অনুস্মারক রাখার সময় ফোন অনুমতি চাইবে।'**
  String get onboardingRemindersBody;

  /// Onboarding step 4: opt in to reminders.
  ///
  /// In bn, this message translates to:
  /// **'হ্যাঁ, মনে করিয়ে দিন'**
  String get onboardingRemindersYes;

  /// Onboarding step 4: skip reminders.
  ///
  /// In bn, this message translates to:
  /// **'এখন নয়'**
  String get onboardingRemindersNo;

  /// Provenance footer of the city picker, whose rows show each city's sunrise (CLAUDE.md: no datum without its provenance).
  ///
  /// In bn, this message translates to:
  /// **'{tradition} · প্রতিটি শহরের আজকের সূর্যোদয়, {timeZone} · তথ্য: {packs} · {status}'**
  String cityListProvenance(
    String tradition,
    String timeZone,
    String packs,
    String status,
  );

  /// City picker and onboarding: find the nearest city (FR-LOC-02).
  ///
  /// In bn, this message translates to:
  /// **'আমার অবস্থান ব্যবহার করুন'**
  String get useMyLocation;

  /// Shown on the Use my location button while waiting for a fix.
  ///
  /// In bn, this message translates to:
  /// **'অবস্থান খোঁজা হচ্ছে…'**
  String get locating;

  /// Rationale shown before the system location prompt (§19.1 L18, §19 location row).
  ///
  /// In bn, this message translates to:
  /// **'কাছের শহর খুঁজে দিতে ফোনের আনুমানিক অবস্থান লাগবে। অবস্থান শুধু এই ফোনেই ব্যবহার হয়; মনে রাখা হয় শুধু আপনার বেছে নেওয়া শহর।'**
  String get locationRationale;

  /// Declines an optional action.
  ///
  /// In bn, this message translates to:
  /// **'এখন নয়'**
  String get actionNotNow;

  /// Result of Use my location (FR-LOC-02); distance is formatted with the user's numerals.
  ///
  /// In bn, this message translates to:
  /// **'নিকটতম শহর: {city}, {distance} কিমি'**
  String nearestCity(String city, String distance);

  /// Warning when the nearest city is far (FR-LOC-03); limit is formatted with the user's numerals.
  ///
  /// In bn, this message translates to:
  /// **'এই শহর {limit} কিমির বেশি দূরে, তাই সময় কয়েক মিনিট আলাদা হতে পারে।'**
  String cityFarWarning(String limit);

  /// Confirms the nearest city.
  ///
  /// In bn, this message translates to:
  /// **'এই শহর বেছে নিন'**
  String get actionChooseCity;

  /// After the location permission is denied (FR-LOC-04).
  ///
  /// In bn, this message translates to:
  /// **'অনুমতি ছাড়াও অ্যাপ চলবে। তালিকা থেকে শহর বেছে নিন।'**
  String get locationDenied;

  /// After a permanent denial (FR-LOC-04).
  ///
  /// In bn, this message translates to:
  /// **'অবস্থানের অনুমতি বন্ধ আছে। তালিকা থেকে শহর বেছে নিন, বা সেটিংসে অনুমতি দিন।'**
  String get locationDeniedForever;

  /// Opens the phone's settings page for the app.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস খুলুন'**
  String get actionOpenSettings;

  /// When the phone's location service is off.
  ///
  /// In bn, this message translates to:
  /// **'ফোনের লোকেশন বন্ধ আছে।'**
  String get locationOff;

  /// Opens the phone's location settings.
  ///
  /// In bn, this message translates to:
  /// **'চালু করুন'**
  String get actionTurnOn;

  /// When no location fix could be had.
  ///
  /// In bn, this message translates to:
  /// **'অবস্থান পাওয়া যায়নি। তালিকা থেকে শহর বেছে নিন।'**
  String get locationUnavailable;

  /// Shown for a link or address the app doesn't know (T-411).
  ///
  /// In bn, this message translates to:
  /// **'এই পাতাটি পাওয়া যায়নি।'**
  String get linkNotFound;

  /// A festival link whose id is not in the installed packs (T-411).
  ///
  /// In bn, this message translates to:
  /// **'এই উৎসবের তথ্য এই ফোনে নেই।'**
  String get festivalNotFound;

  /// Button that opens the Today tab.
  ///
  /// In bn, this message translates to:
  /// **'আজকের পঞ্জিকা দেখুন'**
  String get goToToday;

  /// Screen-reader label of the Bengali numerals option; the visible label's sample digits would be read in the wrong voice (FR-L10N-08).
  ///
  /// In bn, this message translates to:
  /// **'বাংলা সংখ্যা'**
  String get numeralsBengaliSemantics;

  /// Screen-reader label of the Latin numerals option.
  ///
  /// In bn, this message translates to:
  /// **'ইংরেজি সংখ্যা'**
  String get numeralsLatinSemantics;

  /// Festivals tab title with the Bengali year (formatted with the user's numerals), spec §11.5.
  ///
  /// In bn, this message translates to:
  /// **'পার্বণ {year}'**
  String festivalsTitle(String year);

  /// Filter chip that shows every category.
  ///
  /// In bn, this message translates to:
  /// **'সব'**
  String get filterAll;

  /// Festivals filter sheet title and button tooltip (FR-FEST-02).
  ///
  /// In bn, this message translates to:
  /// **'বাছাই'**
  String get filterTitle;

  /// Filter sheet section: Bengali month.
  ///
  /// In bn, this message translates to:
  /// **'মাস'**
  String get filterMonth;

  /// Filter sheet section: observance tier.
  ///
  /// In bn, this message translates to:
  /// **'গুরুত্ব'**
  String get filterImportance;

  /// Tier 1 observances (spec §6.6).
  ///
  /// In bn, this message translates to:
  /// **'প্রধান উৎসব'**
  String get tierMajor;

  /// Tier 2 observances.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য পার্বণ ও তিথি'**
  String get tierOther;

  /// Tier 3 observances.
  ///
  /// In bn, this message translates to:
  /// **'জয়ন্তী ও স্মরণীয় দিন'**
  String get tierCivic;

  /// Clears every festival filter.
  ///
  /// In bn, this message translates to:
  /// **'সব দেখান'**
  String get showAll;

  /// Festival list empty after filtering.
  ///
  /// In bn, this message translates to:
  /// **'এই বাছাইয়ে কোনো পার্বণ নেই।'**
  String get noFestivalsMatch;

  /// Festival list note when only part of the Bengali year is installed.
  ///
  /// In bn, this message translates to:
  /// **'এই বছরের কয়েকটি মাসের তথ্য এই ফোনে নেই।'**
  String get festivalYearPartial;

  /// Festival row: Gregorian date, then Bengali date (FR-FEST-01).
  ///
  /// In bn, this message translates to:
  /// **'{gregorian} · {bengali}'**
  String festivalRowDates(String gregorian, String bengali);

  /// Which day of a multi-day festival a row is (FR-FEST-04); day is formatted with the user's numerals.
  ///
  /// In bn, this message translates to:
  /// **'দিন {day}'**
  String festivalDayOf(String day);

  /// Window name (spec §11.6).
  ///
  /// In bn, this message translates to:
  /// **'সন্ধিপূজা'**
  String get windowSandhiPuja;

  /// Explains the Sandhi Puja window; minutes is formatted with the user's numerals (24).
  ///
  /// In bn, this message translates to:
  /// **'অষ্টমীর শেষ {minutes} মিনিট ও নবমীর প্রথম {minutes} মিনিট'**
  String windowSandhiPujaHint(String minutes);

  /// Window name: the midnight muhurta.
  ///
  /// In bn, this message translates to:
  /// **'নিশীথ'**
  String get windowNishita;

  /// Window name.
  ///
  /// In bn, this message translates to:
  /// **'প্রাতঃকাল'**
  String get windowPratah;

  /// Window name.
  ///
  /// In bn, this message translates to:
  /// **'মধ্যাহ্ন'**
  String get windowMadhyahna;

  /// Window name.
  ///
  /// In bn, this message translates to:
  /// **'অপরাহ্ণ'**
  String get windowAparahna;

  /// Window name.
  ///
  /// In bn, this message translates to:
  /// **'প্রদোষ'**
  String get windowPradosha;

  /// The tithi a festival depends on and its span.
  ///
  /// In bn, this message translates to:
  /// **'{name} · {start} থেকে {end}'**
  String festivalTithiSpan(String name, String start, String end);

  /// Verification card: when the date was checked; date in the UI language.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই: {date}'**
  String checkedOn(String date);

  /// Festival detail: turn on a reminder (FR-FEST-03).
  ///
  /// In bn, this message translates to:
  /// **'মনে করিয়ে দিন'**
  String get reminderOff;

  /// Festival detail: the reminder is on; tap to turn it off.
  ///
  /// In bn, this message translates to:
  /// **'অনুস্মারক চালু আছে'**
  String get reminderOn;

  /// Screen-reader label of the multi-day selector (FR-FEST-04).
  ///
  /// In bn, this message translates to:
  /// **'দিনগুলি'**
  String get festivalDaysLabel;

  /// Reminder title the evening before (FR-REM-04).
  ///
  /// In bn, this message translates to:
  /// **'আগামীকাল {name}'**
  String reminderTomorrow(String name);

  /// Reminder title on the morning of the day.
  ///
  /// In bn, this message translates to:
  /// **'আজ {name}'**
  String reminderToday(String name);

  /// Reminder title at tithi start.
  ///
  /// In bn, this message translates to:
  /// **'{name} শুরু হলো'**
  String reminderTithiBegun(String name);

  /// Reminder detail: when the tithi begins, e.g. 'তিথি শুরু রাত ৯:১৪'.
  ///
  /// In bn, this message translates to:
  /// **'তিথি শুরু {time}'**
  String reminderTithiBegins(String time);

  /// Reminder body: the detail, then its provenance (tradition, IST).
  ///
  /// In bn, this message translates to:
  /// **'{detail} · {tradition} · {timeZone}'**
  String reminderBody(String detail, String tradition, String timeZone);

  /// Android notification channel name (spec §17).
  ///
  /// In bn, this message translates to:
  /// **'উৎসব অনুস্মারক'**
  String get channelFestival;

  /// Android notification channel description.
  ///
  /// In bn, this message translates to:
  /// **'আপনার বেছে নেওয়া পার্বণের আগে মনে করিয়ে দেয়।'**
  String get channelFestivalDescription;

  /// Android notification channel name (spec §17).
  ///
  /// In bn, this message translates to:
  /// **'তিথি অনুস্মারক'**
  String get channelTithi;

  /// Android notification channel description.
  ///
  /// In bn, this message translates to:
  /// **'একাদশী, পূর্ণিমা ও অমাবস্যার অনুস্মারক।'**
  String get channelTithiDescription;

  /// Inline help after the notification permission is refused (US-03, T-507).
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞপ্তির অনুমতি নেই, তাই অনুস্মারক দেখানো যাবে না। ফোনের সেটিংসে এই অ্যাপের বিজ্ঞপ্তি চালু করুন।'**
  String get notificationsOff;

  /// Reminders screen section (spec §11.13).
  ///
  /// In bn, this message translates to:
  /// **'নিয়মিত'**
  String get sectionRecurring;

  /// Reminders screen section: festival reminders.
  ///
  /// In bn, this message translates to:
  /// **'উৎসব'**
  String get sectionFestivalReminders;

  /// Recurring reminder row (FR-REM-02).
  ///
  /// In bn, this message translates to:
  /// **'একাদশী'**
  String get recurringEkadashi;

  /// Recurring reminder row.
  ///
  /// In bn, this message translates to:
  /// **'পূর্ণিমা'**
  String get recurringPurnima;

  /// Recurring reminder row.
  ///
  /// In bn, this message translates to:
  /// **'অমাবস্যা'**
  String get recurringAmavasya;

  /// Reminder timing summary; time in the user's format, e.g. 'রাত ৮:০০'.
  ///
  /// In bn, this message translates to:
  /// **'আগের দিন {time}'**
  String timingDayBefore(String time);

  /// Reminder timing summary.
  ///
  /// In bn, this message translates to:
  /// **'সেদিন {time}'**
  String timingMorningOf(String time);

  /// Reminder timing (only where exact alarms are allowed, spec §17).
  ///
  /// In bn, this message translates to:
  /// **'তিথি শুরুর সময়'**
  String get timingTithiStart;

  /// Two reminder timings together.
  ///
  /// In bn, this message translates to:
  /// **'{first} ও {second}'**
  String timingBoth(String first, String second);

  /// Opens the festival list to choose one (spec §11.13).
  ///
  /// In bn, this message translates to:
  /// **'উৎসব যোগ করুন'**
  String get addFestivalReminder;

  /// Reminders empty state (spec §11.13).
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো অনুস্মারক নেই। একাদশী বা কোনো উৎসবের জন্য চালু করুন।'**
  String get remindersEmpty;

  /// Reminder timing sheet title.
  ///
  /// In bn, this message translates to:
  /// **'কখন মনে করাবে?'**
  String get timingSheetTitle;

  /// Timing option.
  ///
  /// In bn, this message translates to:
  /// **'আগের দিন'**
  String get timingDayBeforeOption;

  /// Timing option.
  ///
  /// In bn, this message translates to:
  /// **'সেদিন সকালে'**
  String get timingMorningOption;

  /// Button tooltip that opens the time picker.
  ///
  /// In bn, this message translates to:
  /// **'সময় বদলান'**
  String get changeTime;

  /// Share card and message provenance line (spec §11.8), e.g. 'বিশুদ্ধ সিদ্ধান্ত মতে'.
  ///
  /// In bn, this message translates to:
  /// **'{tradition} মতে'**
  String shareProvenance(String tradition);

  /// Provenance for shared times (day card): tradition, city and time zone.
  ///
  /// In bn, this message translates to:
  /// **'{tradition} মতে · {city} · {timeZone}'**
  String shareProvenanceWithPlace(
    String tradition,
    String city,
    String timeZone,
  );

  /// Share message line for a festival.
  ///
  /// In bn, this message translates to:
  /// **'{name}: {date}'**
  String shareFestivalMessage(String name, String date);

  /// Share message line for a day: its date and tithi with end time.
  ///
  /// In bn, this message translates to:
  /// **'{date} · {tithi}'**
  String shareDayMessage(String date, String tithi);

  /// Share button and tooltip (FR-DAY-06, FR-FEST-03).
  ///
  /// In bn, this message translates to:
  /// **'শেয়ার করুন'**
  String get shareAction;

  /// Share sheet title (spec §11.8).
  ///
  /// In bn, this message translates to:
  /// **'শেয়ার কার্ড'**
  String get shareSheetTitle;

  /// Share language option: Bengali and English together; shown with the other language's word beside it.
  ///
  /// In bn, this message translates to:
  /// **'দুই ভাষায়'**
  String get shareInBoth;

  /// Glossary section: panchanga terms (FR-SET-07).
  ///
  /// In bn, this message translates to:
  /// **'পঞ্জিকার শব্দ'**
  String get sectionTerms;

  /// Glossary section: Rahu Kaal, Barabela etc.
  ///
  /// In bn, this message translates to:
  /// **'দিনের নানা সময়'**
  String get sectionPeriods;

  /// Glossary search field hint.
  ///
  /// In bn, this message translates to:
  /// **'শব্দ খুঁজুন'**
  String get glossarySearchHint;

  /// Glossary search with no results.
  ///
  /// In bn, this message translates to:
  /// **'এই নামে কোনো শব্দ পাওয়া যায়নি'**
  String get noGlossaryMatches;

  /// Search field hint (spec §11.14).
  ///
  /// In bn, this message translates to:
  /// **'তারিখ বা উৎসবের নাম'**
  String get searchHint;

  /// Search examples line: kinds of input, not data (spec §11.14).
  ///
  /// In bn, this message translates to:
  /// **'উদাহরণ: ২৫ আশ্বিন ১৪৩৩ · ১২/১০/২০২৬ · কালীপূজা'**
  String get searchExamples;

  /// Search results section header.
  ///
  /// In bn, this message translates to:
  /// **'ফলাফল'**
  String get searchResults;

  /// A date result: the Bengali date and the Gregorian date it is.
  ///
  /// In bn, this message translates to:
  /// **'{bengali} = {gregorian}'**
  String searchDateEquals(String bengali, String gregorian);

  /// A date result outside the installed packs (spec §11.9); no conversion is shown.
  ///
  /// In bn, this message translates to:
  /// **'{date}: এই তারিখের তথ্য এই ফোনে নেই'**
  String searchDateNotInstalled(String date);

  /// Search with no results (spec §11.14).
  ///
  /// In bn, this message translates to:
  /// **'কিছু পাওয়া যায়নি। বানান বা তারিখের ধরন দেখে নিন।'**
  String get searchNoResults;

  /// Sources screen: section about the tradition (§11.16).
  ///
  /// In bn, this message translates to:
  /// **'পঞ্জিকার মত'**
  String get sourcesTraditionHeading;

  /// Sources screen: which tradition the data follows (FR-SET-02). The tradition name comes from the pack.
  ///
  /// In bn, this message translates to:
  /// **'এই অ্যাপের সব তারিখ ও সময় {tradition} মতে, যা সেটিংসে বেছে নেওয়া আছে।'**
  String sourcesTraditionBody(String tradition);

  /// Sources screen: heading of the numbered steps (§11.16).
  ///
  /// In bn, this message translates to:
  /// **'আমরা কীভাবে হিসাব করি'**
  String get sourcesHowHeading;

  /// Sources screen, step 1 title.
  ///
  /// In bn, this message translates to:
  /// **'জ্যোতির্বিজ্ঞানের হিসাব (NASA JPL)'**
  String get sourcesStep1Title;

  /// Sources screen, step 1 explanation. Keep in line with aboutDataBody.
  ///
  /// In bn, this message translates to:
  /// **'সূর্য ও চাঁদের অবস্থান NASA JPL-এর DE440s তালিকা থেকে, Skyfield সফটওয়্যারে আগেই হিসাব করা থাকে।'**
  String get sourcesStep1Body;

  /// Sources screen, step 2 title.
  ///
  /// In bn, this message translates to:
  /// **'রাষ্ট্রীয় পঞ্চাঙ্গের সঙ্গে মিলানো'**
  String get sourcesStep2Title;

  /// Sources screen, step 2 explanation.
  ///
  /// In bn, this message translates to:
  /// **'তিথি, নক্ষত্র ও অন্যান্য সময় ভারত সরকারের জাতীয় পঞ্চাঙ্গের সঙ্গে মিলিয়ে দেখা হয়।'**
  String get sourcesStep2Body;

  /// Sources screen, step 3 title.
  ///
  /// In bn, this message translates to:
  /// **'মুদ্রিত পঞ্জিকার সঙ্গে মিলানো'**
  String get sourcesStep3Title;

  /// Sources screen, step 3 explanation.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা তারিখ ও উৎসবের দিন মুদ্রিত পঞ্জিকার সঙ্গে মিলিয়ে দেখা হয়।'**
  String get sourcesStep3Body;

  /// Sources screen, step 4 title.
  ///
  /// In bn, this message translates to:
  /// **'প্রধান উৎসব বিশেষজ্ঞের যাচাই'**
  String get sourcesStep4Title;

  /// Sources screen, step 4 explanation.
  ///
  /// In bn, this message translates to:
  /// **'প্রধান উৎসবের নিয়ম একজন পঞ্জিকা-বিশেষজ্ঞ দেখে নেন।'**
  String get sourcesStep4Body;

  /// Sources screen: note under the steps.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি তথ্য কোন ধাপ পর্যন্ত যাচাই হয়েছে, তা পাশের চিহ্নে দেখা যায়।'**
  String get sourcesStepsNote;

  /// Sources screen: heading of the verification marks legend (§12.5).
  ///
  /// In bn, this message translates to:
  /// **'চিহ্নের অর্থ'**
  String get sourcesMarksHeading;

  /// Sources screen: heading of the installed packs list.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনের তথ্য'**
  String get sourcesPhoneHeading;

  /// Kind of data pack: tithi, nakshatra, sunrise and other daily data.
  ///
  /// In bn, this message translates to:
  /// **'পঞ্চাঙ্গের তথ্য'**
  String get packKindGlobal;

  /// Kind of data pack: cities and their sunrise times.
  ///
  /// In bn, this message translates to:
  /// **'শহরের তথ্য'**
  String get packKindCities;

  /// Kind of data pack: festivals and observances.
  ///
  /// In bn, this message translates to:
  /// **'উৎসবের তথ্য'**
  String get packKindObservances;

  /// Sources screen: an installed pack and its version. Layout only.
  ///
  /// In bn, this message translates to:
  /// **'{kind} · সংস্করণ {version}'**
  String sourcesPackTitle(String kind, String version);

  /// Sources screen: a pack's tradition and the dates it covers. Layout only.
  ///
  /// In bn, this message translates to:
  /// **'{tradition} · {range}'**
  String sourcesPackScope(String tradition, String range);

  /// Sources screen: the date a pack was last checked against the references.
  ///
  /// In bn, this message translates to:
  /// **'শেষ যাচাই: {date}'**
  String sourcesValidatedOn(String date);

  /// Sources screen: a pack that has not been validated yet.
  ///
  /// In bn, this message translates to:
  /// **'এখনও মিলিয়ে দেখা হয়নি'**
  String get sourcesNotValidated;

  /// Sources screen: no packs installed.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনে এখনও কোনো তথ্য নেই।'**
  String get sourcesNoPacks;

  /// Sources screen: link to the explainer (§11.16).
  ///
  /// In bn, this message translates to:
  /// **'দুই মত কেন আলাদা?'**
  String get sourcesWhyLink;

  /// Explainer 'Why do the two schools differ?' (§11.16, §5.2), paragraph 1 of 3. About 150 words in total; plain language.
  ///
  /// In bn, this message translates to:
  /// **'পশ্চিমবঙ্গে পঞ্জিকার দুটি মত চালু আছে। বিশুদ্ধ সিদ্ধান্ত (দৃক) মত সূর্য ও চাঁদের আধুনিক জ্যোতির্বিজ্ঞানসম্মত অবস্থান থেকে হিসাব করে; ভারত সরকারের জাতীয় পঞ্চাঙ্গও এই পদ্ধতিতে তৈরি। সূর্যসিদ্ধান্ত মত, যা গুপ্তপ্রেস ও আরও কয়েকটি পঞ্জিকা মেনে চলে, প্রাচীন সূর্যসিদ্ধান্ত গ্রন্থের হিসাব আর রঘুনন্দনের বিধান অনুসরণ করে।'**
  String get schoolsPara1;

  /// Explainer, paragraph 2 of 3.
  ///
  /// In bn, this message translates to:
  /// **'দুই হিসাবে সূর্য ও চাঁদের অবস্থান সামান্য আলাদা আসে, তাই একই তিথি দুই মতে ভিন্ন সময়ে শেষ হয় — কখনো কয়েক মিনিট, কখনো আরও বেশি তফাতে। সূর্যোদয়ের সময় যে তিথি চলে, সেটাই সেদিনের তিথি। তাই তিথি সূর্যোদয়ের কাছাকাছি শেষ হলে দুই মতে একই সকালের তিথি আলাদা হতে পারে, আর তাতে কোনো উৎসব এক দিন আগে বা পরে পড়ে।'**
  String get schoolsPara2;

  /// Explainer, paragraph 3 of 3.
  ///
  /// In bn, this message translates to:
  /// **'এর কোনোটিই ভুল নয়; দুটিই দীর্ঘদিনের প্রচলিত গণনারীতি। এই অ্যাপ প্রতিটি তারিখের সঙ্গে জানায় সেটি কোন মতে। এখন অ্যাপে বিশুদ্ধ সিদ্ধান্ত মত আছে, সূর্যসিদ্ধান্ত মত পরে আসবে। আপনার পরিবার যে পঞ্জিকা মানে, তার সঙ্গে মিলিয়ে নিন।'**
  String get schoolsPara3;
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
