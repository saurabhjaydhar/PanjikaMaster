// T-208: domain entities follow the spec's conventions (§15.1, §15.4, §6.8).
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/domain/entities/name_ref.dart';
import 'package:panjika/domain/entities/panjika.dart';

void main() {
  test('Weekday index: 0 = Sunday (spec §15.1)', () {
    expect(Weekday.sunday.index, 0);
    expect(Weekday.saturday.index, 6);
    expect(Weekday.of(const CivilDate(2026, 10, 12)), Weekday.monday);
    expect(Weekday.of(const CivilDate(2026, 10, 18)), Weekday.sunday);
    expect(Weekday.fromIso(7), Weekday.sunday);
    expect(Weekday.fromIso(1), Weekday.monday);
  });

  test('verification statuses map to the database values (spec §6.8)', () {
    for (final s in VerificationStatus.values) {
      expect(VerificationStatus.parse(s.dbValue), s);
    }
    expect(
      VerificationStatus.parse('reference_matched'),
      VerificationStatus.referenceMatched,
    );
    expect(() => VerificationStatus.parse('stale'), throwsFormatException);
  });

  test('a transition contains its start but not its end', () {
    final t = Transition(
      kind: TransitionKind.tithi,
      idx: 6,
      startUtc: DateTime.utc(2026, 10, 12),
      endUtc: DateTime.utc(2026, 10, 13),
      packId: 'p',
    );
    expect(t.contains(DateTime.utc(2026, 10, 12)), isTrue);
    expect(t.contains(DateTime.utc(2026, 10, 12, 23, 59)), isTrue);
    expect(t.contains(DateTime.utc(2026, 10, 13)), isFalse);
  });

  test('data coverage is exhaustive and Covered checks its range', () {
    const covered = Covered(CivilDate(2026, 4, 14), CivilDate(2029, 4, 13));
    expect(covered.includes(const CivilDate(2026, 10, 12)), isTrue);
    expect(covered.includes(const CivilDate(2030, 1, 1)), isFalse);
    String describe(DataCoverage c) => switch (c) {
      Covered() => 'covered',
      NotDownloaded() => 'not downloaded',
      Stale(:final packIds) => 'stale: ${packIds.join()}',
      ClockSuspect() => 'check the clock',
    };
    expect(describe(const Stale(covered, ['g'])), 'stale: g');
    expect(describe(const NotDownloaded()), 'not downloaded');
    expect(describe(const ClockSuspect()), 'check the clock');
  });

  test('a period rule part must lie within its divisions', () {
    expect(
      () => PeriodRule(
        periodId: 0,
        kind: PeriodKind.ashubh,
        weekday: Weekday.monday,
        basis: PeriodBasis.day,
        divisions: 8,
        part: 9,
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('provenance always labels times IST', () {
    expect(
      const Provenance(
        tradition: NameRefFixture.drik,
        city: NameRefFixture.kolkata,
        packIds: ['p'],
        isSample: false,
      ).timeZoneLabel,
      'IST',
    );
  });
}

abstract final class NameRefFixture {
  static const drik = NameRef(
    'বিশুদ্ধ সিদ্ধান্ত (দৃক)',
    'Bishuddha Siddhanta (Drik)',
  );
  static const kolkata = NameRef('কলকাতা', 'Kolkata');
}
