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

  /// Placeholder body for a tab whose screen is not built yet (Phase 1 only).
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
