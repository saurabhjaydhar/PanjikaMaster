import '../../core/time/civil_date.dart';
import '../entities/name_ref.dart';
import '../entities/panjika.dart';
import 'interfaces.dart';
import 'karana.dart';
import 'period_calculator.dart';

/// Looks up a display name in both scripts: `names(kind, idx)` from the pack.
typedef NameLookup = NameRef Function(String kind, int idx);

/// Raw parts of one panjika day (sunrise → next sunrise), as read from the packs.
/// Instants are UTC.
class DayInputs {
  const DayInputs({
    required this.date,
    required this.previousSunrise,
    required this.sun,
    required this.nextSunrise,
    required this.bengaliDate,
    required this.transitions,
    required this.periodRules,
    required this.names,
    required this.provenance,
    this.observances = const [],
  });

  /// The civil date (IST) whose sunrise starts this panjika day.
  final CivilDate date;

  /// Sunrise of the previous day: needed to tell whether today's udaya tithi also
  /// touched yesterday's sunrise (vriddhi).
  final DateTime previousSunrise;
  final SunMoonTimes sun;
  final DateTime nextSunrise;
  final BengaliDate bengaliDate;

  /// Transitions of every kind overlapping [previousSunrise, nextSunrise], any order.
  final List<Transition> transitions;

  /// Standard (§6.5.8) plus any validated Bengal-period rules (§6.5.9).
  final List<PeriodRule> periodRules;
  final NameLookup names;
  final Provenance provenance;

  /// Observances dated to [date], in display order.
  final List<ObservanceDate> observances;
}

/// One element within the panjika day, with its display name.
class DaySpan {
  const DaySpan({
    required this.kind,
    required this.idx,
    required this.name,
    required this.startUtc,
    required this.endUtc,
  });

  final TransitionKind kind;
  final int idx;
  final NameRef name;
  final DateTime startUtc;
  final DateTime endUtc;

  bool contains(DateTime instant) =>
      !instant.isBefore(startUtc) && instant.isBefore(endUtc);

  /// Share elapsed at [instant], 0–1 (the tithi ring).
  double progressAt(DateTime instant) {
    final total = endUtc.difference(startUtc).inMicroseconds;
    if (total <= 0) return 0;
    return (instant.difference(startUtc).inMicroseconds / total).clamp(
      0.0,
      1.0,
    );
  }
}

/// A tithi as it relates to this panjika day (spec §6.5.7).
class TithiOnDay {
  const TithiOnDay(this.span, {required this.isKshaya});

  final DaySpan span;

  /// Begins after this sunrise and ends before the next: touches no sunrise. Shown as
  /// a second line, "ক্ষয় তিথি" (spec §16).
  final bool isKshaya;
}

/// The user-facing day (spec §15.4). It cannot exist without [provenance].
class DayPanjika {
  const DayPanjika({
    required this.date,
    required this.weekday,
    required this.bengaliDate,
    required this.bengaliMonth,
    required this.sun,
    required this.nextSunrise,
    required this.udayaTithi,
    required this.isVriddhi,
    required this.tithis,
    required this.spans,
    required this.periods,
    required this.provenance,
    this.observances = const [],
  });

  final CivilDate date;
  final Weekday weekday;
  final BengaliDate bengaliDate;
  final NameRef bengaliMonth;
  final SunMoonTimes sun;
  final DateTime nextSunrise;

  /// The tithi prevailing at sunrise: it names the day (spec §6.5.7).
  final DaySpan udayaTithi;

  /// The udaya tithi also prevails at the previous or the next sunrise, so it names two
  /// days (spec §6.5.7, §16: "বৃদ্ধি তিথি").
  final bool isVriddhi;

  /// Every tithi touching the panjika day, in order, with kshaya flags.
  final List<TithiOnDay> tithis;

  /// Nakshatra, yoga and karana spans touching the panjika day, in order, per kind.
  final Map<TransitionKind, List<DaySpan>> spans;

  /// Rahu Kaal etc. for this day, in time order.
  final List<TimePeriod> periods;
  final Provenance provenance;

  /// Observances on this date, by tier then id (spec §11.4).
  final List<ObservanceDate> observances;

  List<TithiOnDay> get kshayaTithis => [
    for (final t in tithis)
      if (t.isKshaya) t,
  ];

  /// True if [instant] falls after IST midnight, i.e. on the next civil date: shown with
  /// "(পরদিন)" / "(next day)" (spec §16).
  bool isAfterMidnight(DateTime instant) =>
      CivilDate.ofInstant(instant).compareTo(date) > 0;

  bool _inDay(DateTime instant) =>
      !instant.isBefore(sun.sunrise) && instant.isBefore(nextSunrise);

  /// The element of [kind] at [now] if now is within this panjika day, else the one at
  /// sunrise (what Day detail shows for other dates).
  DaySpan currentOf(TransitionKind kind, DateTime now) {
    final list = kind == TransitionKind.tithi
        ? [for (final t in tithis) t.span]
        : spans[kind]!;
    final at = _inDay(now.toUtc()) ? now.toUtc() : sun.sunrise;
    return list.firstWhere((s) => s.contains(at), orElse: () => list.first);
  }

  /// The span that follows [span] within this day, if any ("তারপর অষ্টমী").
  DaySpan? nextAfter(DaySpan span) {
    final list = span.kind == TransitionKind.tithi
        ? [for (final t in tithis) t.span]
        : spans[span.kind]!;
    final i = list.indexOf(span);
    return (i >= 0 && i + 1 < list.length) ? list[i + 1] : null;
  }

  /// The period active at [now], if any (FR-HOME-07 highlight).
  TimePeriod? activePeriod(DateTime now) {
    for (final p in periods) {
      if (p.isActiveAt(now.toUtc())) return p;
    }
    return null;
  }
}

abstract interface class DayAssembler {
  DayPanjika assemble(DayInputs inputs);
}

/// Builds a [DayPanjika] from raw parts. Pure and synchronous; independent of the
/// device time zone because every instant is UTC (spec §15.4, §16).
class StandardDayAssembler implements DayAssembler {
  const StandardDayAssembler({this.periods = const DivisionPeriodCalculator()});

  final PeriodCalculator periods;

  @override
  DayPanjika assemble(DayInputs inputs) {
    final sunrise = inputs.sun.sunrise.toUtc();
    final next = inputs.nextSunrise.toUtc();
    final previous = inputs.previousSunrise.toUtc();
    if (!previous.isBefore(sunrise) || !sunrise.isBefore(next)) {
      throw ArgumentError('expected previous sunrise < sunrise < next sunrise');
    }

    // Karana k (0–59) maps onto 11 names; other kinds use their index directly.
    NameRef nameOf(Transition t) => t.kind == TransitionKind.karana
        ? inputs.names('karana', karanaNameIndex(t.idx))
        : inputs.names(t.kind.name, t.idx);
    DaySpan span(Transition t) => DaySpan(
      kind: t.kind,
      idx: t.idx,
      name: nameOf(t),
      startUtc: t.startUtc.toUtc(),
      endUtc: t.endUtc.toUtc(),
    );

    List<DaySpan> touching(TransitionKind kind) => [
      for (final t in inputs.transitions)
        if (t.kind == kind &&
            t.endUtc.isAfter(sunrise) &&
            t.startUtc.isBefore(next))
          span(t),
    ]..sort((a, b) => a.startUtc.compareTo(b.startUtc));

    final tithiSpans = touching(TransitionKind.tithi);
    final udaya = tithiSpans.where((s) => s.contains(sunrise));
    if (udaya.isEmpty) {
      throw StateError(
        'no tithi covers sunrise on ${inputs.date}: transitions incomplete',
      );
    }
    final udayaTithi = udaya.single;
    final tithis = [
      for (final s in tithiSpans)
        TithiOnDay(
          s,
          isKshaya: s.startUtc.isAfter(sunrise) && !s.endUtc.isAfter(next),
        ),
    ];
    // Spans the previous sunrise (named yesterday too) or the next one (named tomorrow).
    final isVriddhi =
        !udayaTithi.startUtc.isAfter(previous) ||
        udayaTithi.endUtc.isAfter(next);

    final weekday = Weekday.of(inputs.date);
    return DayPanjika(
      date: inputs.date,
      weekday: weekday,
      bengaliDate: inputs.bengaliDate,
      bengaliMonth: inputs.names('solar_month', inputs.bengaliDate.monthIdx),
      sun: inputs.sun,
      nextSunrise: next,
      udayaTithi: udayaTithi,
      isVriddhi: isVriddhi,
      tithis: tithis,
      spans: {
        for (final k in [
          TransitionKind.nakshatra,
          TransitionKind.yoga,
          TransitionKind.karana,
        ])
          k: touching(k),
      },
      periods: [
        ...periods.periodsFor(
          sunriseUtc: sunrise,
          sunsetUtc: inputs.sun.sunset.toUtc(),
          nextSunriseUtc: next,
          weekday: weekday,
          rules: inputs.periodRules,
        ),
      ]..sort((a, b) => a.startUtc.compareTo(b.startUtc)),
      provenance: inputs.provenance,
      observances: List.unmodifiable(inputs.observances),
    );
  }
}
