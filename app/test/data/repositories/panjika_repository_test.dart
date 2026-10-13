// T-211: the Drift repository reads the (sample) packs into domain entities.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/repositories/panjika_repository.dart';
import 'package:panjika/domain/entities/panjika.dart';
import 'package:panjika/domain/entities/terms.dart';

const drik = 'drik_bishuddha';
const sampleDay = CivilDate(2026, 10, 12);

void main() {
  late AppDatabase db;
  late DriftPanjikaRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    repo = DriftPanjikaRepository(db);
  });
  tearDown(() => db.close());

  test(
    'transitions overlap the range, in order, and only for the tradition',
    () async {
      final from = DateTime.utc(2026, 10, 12);
      final to = DateTime.utc(2026, 10, 14);
      final tithis = await repo.transitions(
        drik,
        TransitionKind.tithi,
        from,
        to,
      );
      expect(tithis, isNotEmpty);
      expect(tithis.first.startUtc.isBefore(from), isTrue);
      for (var i = 1; i < tithis.length; i++) {
        expect(tithis[i].startUtc, tithis[i - 1].endUtc, reason: 'no gaps');
      }
      expect(tithis.every((t) => t.packId == 'sample-global-drik'), isTrue);
      expect(
        await repo.transitions(
          'surya_siddhanta',
          TransitionKind.tithi,
          from,
          to,
        ),
        isEmpty,
      );
    },
  );

  test('sun and moon times by day and by range', () async {
    final day = (await repo.sunMoonTimes('kolkata', sampleDay))!;
    expect(day.sunrise.isBefore(day.sunset), isTrue);
    expect(day.packId, 'sample-cities');
    expect(await repo.sunMoonTimes('nowhere', sampleDay), isNull);
    final september = await repo.sunMoonTimesBetween(
      'kolkata',
      const CivilDate(2026, 9, 1),
      const CivilDate(2026, 9, 30),
    );
    expect(september.length, 30);
  });

  test('Bengali dates by day, range and month', () async {
    final bn = (await repo.bengaliDate(drik, sampleDay))!;
    expect((bn.day, bn.year), (25, 1433));
    final month = await repo.bengaliMonthDates(drik, 1433, bn.monthIdx);
    expect(month, contains(sampleDay));
    for (var i = 1; i < month.length; i++) {
      expect(month[i], month[i - 1].addDays(1), reason: 'consecutive');
    }
    final range = await repo.bengaliDatesBetween(drik, month.first, month.last);
    expect(range[month.first]!.day, 1);
    expect(range.values.every((b) => b.monthIdx == bn.monthIdx), isTrue);
  });

  test('lunar months come with their pack', () async {
    final months = await repo.lunarMonths(
      drik,
      DateTime.utc(2026, 9),
      DateTime.utc(2026, 12),
    );
    expect(months, isNotEmpty);
    expect(months.every((m) => m.packId == 'sample-global-drik'), isTrue);
  });

  test('observances map to entities with status and category', () async {
    final list = await repo.observances(drik, sampleDay, sampleDay);
    expect(list.single.observance.id, 'durga_shashthi');
    expect(list.single.observance.name.en, 'Durga Shashthi');
    expect(list.single.observance.category, ObservanceCategory.puja);
    expect(list.single.status, VerificationStatus.sample);
    expect(list.single.date, sampleDay);
  });

  test('coverage is the overlap of the global and city packs', () async {
    final c = await repo.coverage(drik, 'kolkata');
    expect(c, isA<Covered>());
    c as Covered;
    expect(
      (c.from, c.to),
      (const CivilDate(2026, 9, 1), const CivilDate(2026, 12, 31)),
    );
    expect(await repo.coverage(drik, 'nowhere'), isA<NotDownloaded>());
    expect(
      await repo.coverage('surya_siddhanta', 'kolkata'),
      isA<NotDownloaded>(),
    );
  });

  test('names, cities, rules and sample flags', () async {
    final names = await repo.names();
    expect(names.countOf('tithi'), 30);
    expect(names.of('tithi', 14).en, 'Purnima');
    expect(names.tradition(drik).bn, 'বিশুদ্ধ সিদ্ধান্ত (দৃক)');
    expect(() => names.of('tithi', 30), throwsStateError);

    final city = (await repo.city('kolkata'))!;
    expect(
      (city.name.bn, city.name.en, city.timeZone),
      ('কলকাতা', 'Kolkata', 'Asia/Kolkata'),
    );
    expect(await repo.city('nowhere'), isNull);

    expect(
      await repo.enabledPeriodRules(drik),
      isEmpty,
      reason: 'none validated yet',
    );

    expect(await repo.anySample(['sample-cities']), isTrue);
    expect(await repo.anySample(<String>[]), isFalse);
    expect(await repo.anySample(['not-installed']), isFalse);
  });

  test('T-217: every glossary term and period has a name and a gloss in both languages', () async {
    final names = await repo.names();
    final ids = (await db.allNames().get())
        .where((r) => r.kind == 'term')
        .map((r) => r.translit)
        .toList();
    expect(ids, [
      for (final t in Term.values) t.id,
    ], reason: 'Term order = pack order');
    for (final t in Term.values) {
      final name = names.of('term', t.index);
      final gloss = names.glossOf('term', t.index)!;
      expect(
        [name.bn, name.en, gloss.bn, gloss.en],
        everyElement(isNotEmpty),
        reason: t.id,
      );
    }
    for (var i = 0; i < names.countOf('period'); i++) {
      expect(names.glossOf('period', i), isNotNull, reason: 'period $i');
    }
    expect(names.glossOf('tithi', 0), isNull, reason: 'names without glosses');
  });
}
