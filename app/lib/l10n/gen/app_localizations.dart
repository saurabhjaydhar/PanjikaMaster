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
