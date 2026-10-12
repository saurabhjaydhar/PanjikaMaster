import '../../core/time/civil_date.dart';
import 'name_ref.dart';
import 'panjika.dart';

export 'panjika.dart' show Provenance;

/// One panchanga element at a moment: what it is, when it started and ends (UTC).
class ElementSpan {
  const ElementSpan({
    required this.name,
    required this.start,
    required this.end,
    this.next,
  });

  final NameRef name;
  final DateTime start;
  final DateTime end;

  /// What follows when this one ends (used for the tithi: "তারপর অষ্টমী").
  final NameRef? next;

  /// Share of the element elapsed at [now], 0–1 (drives the tithi ring, spec §12.5).
  double progressAt(DateTime now) {
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 0;
    return (now.difference(start).inSeconds / total).clamp(0.0, 1.0);
  }
}

/// Everything the basic Today screen shows (FR-HOME-01..04). Phase 2 replaces the
/// assembly with the full `DayAssembler` (kshaya/vriddhi, periods).
class TodaySnapshot {
  const TodaySnapshot({
    required this.date,
    required this.bnDay,
    required this.bnMonth,
    required this.bnYear,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.provenance,
  });

  final CivilDate date;
  final int bnDay;
  final NameRef bnMonth;
  final int bnYear;
  final ElementSpan tithi;
  final ElementSpan nakshatra;
  final ElementSpan yoga;
  final ElementSpan karana;
  final DateTime sunrise;
  final DateTime sunset;

  /// null = no moonrise / moonset that day (spec §16).
  final DateTime? moonrise;
  final DateTime? moonset;
  final Provenance provenance;
}
