import '../../core/time/civil_date.dart';

/// What the user says is wrong (spec §11.17).
enum ReportKind {
  tithiTime('tithi_time'),
  festivalDay('festival_day'),
  bengaliDate('bengali_date'),
  other('other');

  const ReportKind(this.wire);

  /// Language-neutral, so the team reads every report the same way.
  final String wire;
}

/// An error report (FR-SET-03, US-07). It carries only the fields of the §15.3
/// contract — `{date, city_id, tradition, pack_versions, message, app_version}` — and
/// never a name, phone number, e-mail or device identifier.
class ErrorReport {
  const ErrorReport({
    required this.date,
    required this.cityId,
    required this.tradition,
    required this.packVersions,
    required this.kind,
    required this.panjikaSays,
    this.panjikaName,
    required this.appVersion,
  });

  final CivilDate date;
  final String cityId;
  final String tradition;

  /// Manifest id (without the version suffix) → installed version.
  final Map<String, int> packVersions;
  final ReportKind kind;

  /// What the user's printed panjika says, in their words.
  final String panjikaSays;

  /// Which printed panjika, if the user names it.
  final String? panjikaName;
  final String appVersion;

  /// The kind, the panjika's name and the user's text go into `message`, the one
  /// free-text field the contract has.
  String get message {
    final name = panjikaName?.trim() ?? '';
    return [
      'kind: ${kind.wire}',
      if (name.isNotEmpty) 'panjika: $name',
      '',
      panjikaSays.trim(),
    ].join('\n');
  }

  Map<String, Object> toJson() => {
    'date': date.toIso(),
    'city_id': cityId,
    'tradition': tradition,
    'pack_versions': packVersions,
    'message': message,
    'app_version': appVersion,
  };
}
