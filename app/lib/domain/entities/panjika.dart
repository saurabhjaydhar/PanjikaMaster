/// Domain entities (spec §15.4). Plain, immutable and free of Flutter, Drift and I/O.
/// Every datum that reaches the UI carries the pack it came from (CLAUDE.md).
library;

import '../../core/time/civil_date.dart';
import 'name_ref.dart';

/// Weekday with the spec's index convention: 0 = Sunday (spec §15.1).
enum Weekday {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday;

  /// From [DateTime.weekday] / [CivilDate.weekday] (1 = Monday … 7 = Sunday).
  static Weekday fromIso(int isoWeekday) => values[isoWeekday % 7];

  static Weekday of(CivilDate date) => fromIso(date.weekday);
}

enum TransitionKind { tithi, nakshatra, yoga, karana, sankranti }

/// One panchanga element's span (spec §6.5). Instants are UTC.
class Transition {
  const Transition({
    required this.kind,
    required this.idx,
    required this.startUtc,
    required this.endUtc,
    required this.packId,
  });

  final TransitionKind kind;

  /// 0-based (spec §15.1): tithi 0–29, nakshatra/yoga 0–26, karana k 0–59, sankranti 0–11.
  final int idx;
  final DateTime startUtc;
  final DateTime endUtc;
  final String packId;

  bool contains(DateTime instant) =>
      !instant.isBefore(startUtc) && instant.isBefore(endUtc);
}

/// Verification status shown to users (spec §6.8). `stale` is a pack-level state,
/// modelled by [DataCoverage], not a row status.
enum VerificationStatus {
  computed('computed'),
  referenceMatched('reference_matched'),
  expertReviewed('expert_reviewed'),
  sample('sample');

  const VerificationStatus(this.dbValue);

  final String dbValue;

  static VerificationStatus parse(String value) => values.firstWhere(
    (s) => s.dbValue == value,
    orElse: () => throw FormatException(value),
  );
}

class BengaliDate {
  const BengaliDate({
    required this.day,
    required this.monthIdx,
    required this.year,
    required this.packId,
  });

  final int day;

  /// 0 = বৈশাখ.
  final int monthIdx;
  final int year;
  final String packId;
}

class SunMoonTimes {
  const SunMoonTimes({
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.packId,
  });

  final DateTime sunrise;
  final DateTime sunset;

  /// null when there is no moonrise / moonset that day (spec §16).
  final DateTime? moonrise;
  final DateTime? moonset;
  final String packId;
}

class LunarMonth {
  const LunarMonth({
    required this.monthIdx,
    required this.isAdhik,
    required this.startUtc,
    required this.endUtc,
    required this.packId,
  });

  final int monthIdx;

  /// মলমাস: no festivals are placed in it (spec §6.5.7).
  final bool isAdhik;
  final DateTime startUtc;
  final DateTime endUtc;
  final String packId;
}

class City {
  const City({
    required this.id,
    required this.name,
    required this.district,
    required this.lat,
    required this.lon,
    required this.timeZone,
    required this.popular,
    this.state = '',
    this.aliases = const [],
  });

  final String id;
  final NameRef name;
  final NameRef district;

  /// As stored in the pack (e.g. `West Bengal`); groups the city picker.
  final String state;

  /// Other spellings in either script, for search (spec §13.6).
  final List<String> aliases;
  final double lat;
  final double lon;
  final String timeZone;
  final bool popular;
}

enum ObservanceCategory { puja, vrata, tithi, utsav, jayanti }

class Observance {
  const Observance({
    required this.id,
    required this.name,
    required this.category,
    required this.tier,
    required this.description,
  });

  final String id;
  final NameRef name;
  final ObservanceCategory category;
  final int tier;
  final NameRef description;
}

class ObservanceDate {
  const ObservanceDate({
    required this.observance,
    required this.date,
    required this.dayIndex,
    required this.status,
    required this.packId,
    this.reviewedBy,
    this.reviewedOn,
    this.note,
  });

  final Observance observance;
  final CivilDate date;
  final int dayIndex;
  final VerificationStatus status;
  final String packId;
  final String? reviewedBy;
  final CivilDate? reviewedOn;
  final NameRef? note;
}

/// A timed window of an observance on a date, e.g. Sandhi Puja or nishita
/// (observance_windows, spec §6.6).
class ObservanceWindow {
  const ObservanceWindow({
    required this.observanceId,
    required this.date,
    required this.kind,
    required this.start,
    required this.end,
    required this.packId,
  });

  final String observanceId;
  final CivilDate date;

  /// `sandhi_puja`, `nishita`, `tithi_span`, … (the pipeline's window kinds).
  final String kind;
  final DateTime start;
  final DateTime end;
  final String packId;
}

enum PeriodKind { shubh, ashubh }

enum PeriodBasis { day, night }

/// Which division of day or night a named period occupies on a weekday (spec §6.5.8–9).
class PeriodRule {
  const PeriodRule({
    required this.periodId,
    required this.kind,
    required this.weekday,
    required this.basis,
    required this.divisions,
    required this.part,
  }) : assert(part >= 1 && part <= divisions);

  /// Index into `names(kind='period')`.
  final int periodId;
  final PeriodKind kind;
  final Weekday weekday;
  final PeriodBasis basis;
  final int divisions;

  /// 1-based, as in the spec's table.
  final int part;
}

/// A computed period on one day, e.g. Rahu Kaal 7:32–9:00.
class TimePeriod {
  const TimePeriod({
    required this.periodId,
    required this.kind,
    required this.startUtc,
    required this.endUtc,
  });

  final int periodId;
  final PeriodKind kind;
  final DateTime startUtc;
  final DateTime endUtc;

  bool isActiveAt(DateTime instant) =>
      !instant.isBefore(startUtc) && instant.isBefore(endUtc);
}

/// Where a displayed datum came from (spec §6.8, US-02).
class Provenance {
  const Provenance({
    required this.tradition,
    required this.city,
    required this.packIds,
    required this.isSample,
    this.timeZoneLabel = 'IST',
    this.latitude,
    this.longitude,
  });

  final NameRef tradition;
  final NameRef city;

  /// The city's coordinates, for the Day detail footer (FR-DAY-04).
  final double? latitude;
  final double? longitude;
  final List<String> packIds;

  /// True if any contributing pack is a fixture: the UI must show the watermark.
  final bool isSample;

  /// Panjika times are always shown in IST (spec §5.3).
  final String timeZoneLabel;
}

/// Whether data exists for a tradition and city (spec §15.4, §11.9).
sealed class DataCoverage {
  const DataCoverage();
}

final class Covered extends DataCoverage {
  const Covered(this.from, this.to);

  final CivilDate from;
  final CivilDate to;

  bool includes(CivilDate date) =>
      date.compareTo(from) >= 0 && date.compareTo(to) <= 0;
}

/// No installed pack covers the date, but a known one does: offer the download.
final class NotDownloaded extends DataCoverage {
  const NotDownloaded();
}

/// Covered, but the manifest has newer versions of [packIds]: the data is still shown,
/// with the amber "needs an update" banner (spec §6.8, §11.9).
final class Stale extends DataCoverage {
  const Stale(this.covered, this.packIds);

  final Covered covered;
  final List<String> packIds;
}

/// No pack the app knows of covers the date, so the phone's clock is probably wrong:
/// "ফোনের তারিখ ঠিক আছে কিনা দেখুন" (spec §16).
final class ClockSuspect extends DataCoverage {
  const ClockSuspect();
}
