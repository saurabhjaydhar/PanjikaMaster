// T-605: search normaliser and index — the §13.6 cases: both scripts, both numeral
// systems, dd/mm/yyyy, Bengali dates with or without ordinal suffix or year, month
// spelling variants, festival-name variants. Data: the sample pack.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/search/search_key.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/repositories/panjika_repository.dart';
import 'package:panjika/domain/entities/name_table.dart';
import 'package:panjika/domain/search/search_query.dart';
import 'package:panjika/features/search/search_service.dart';

void main() {
  late AppDatabase db;
  late DriftPanjikaRepository repo;
  late NameTable names;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    repo = DriftPanjikaRepository(db);
    names = await repo.names();
  });
  tearDown(() => db.close());

  List<DateQuery> parse(String s) => parseDateQueries(s, names);
  const oct12 = GregorianDate(CivilDate(2026, 10, 12));

  group('dates', () {
    test('dd/mm/yyyy in either digits, with / - or ., and ISO', () {
      for (final s in [
        '12/10/2026',
        '১২/১০/২০২৬',
        '12-10-2026',
        '12.10.2026',
        '2026-10-12',
      ]) {
        expect(parse(s), [oct12], reason: s);
      }
      expect(parse('30/02/2026'), isEmpty, reason: 'no such date');
    });

    test('Gregorian with a month name, in either script', () {
      expect(parse('১২ অক্টোবর ২০২৬'), [oct12]);
      expect(parse('October 12, 2026'), [oct12]);
      expect(parse('12 oct'), [const GregorianDayMonth(12, 10)]);
    });

    test('Bengali dates: with or without suffix or year, either script', () {
      expect(parse('২৫ আশ্বিন ১৪৩৩'), [const BengaliDay(25, 5, 1433)]);
      expect(parse('২৫শে আশ্বিন'), [const BengaliDay(25, 5)]);
      expect(parse('25 Ashwin'), [const BengaliDay(25, 5)]);
      expect(parse('১লা বৈশাখ'), [const BengaliDay(1, 0)]);
    });

    test('month spelling variants (Boishakh / Baishakh / Vaisakh / বৈশাখ)', () {
      for (final m in ['Boishakh', 'Baishakh', 'Vaisakh', 'বৈশাখ', 'boisakh']) {
        expect(parse('1 $m'), [const BengaliDay(1, 0)], reason: m);
      }
      expect(
        parse('3 ash'),
        isEmpty,
        reason: 'ambiguous prefix: Asharh or Ashwin',
      );
    });

    test('a festival name is not a date', () {
      expect(parse('কালীপূজা'), isEmpty);
    });
  });

  test('spelling folds: লক্ষ্মী/লক্ষী, Lakshmi/Laxmi, V/B, Durgā, spaces', () {
    expect(searchKey('লক্ষ্মী'), searchKey('লক্ষী'));
    expect(searchKey('Lakshmi Puja'), searchKey('laxmi puja'));
    expect(searchKey('Vishwakarma'), searchKey('Bishwakarma'));
    expect(searchKey('Durgā'), searchKey('durga'));
    expect(searchKey('কালী পূজা'), searchKey('কালীপূজা'));
    expect(searchKey('Phalgun'), searchKey('Falgun'));
  });

  group('service', () {
    late SearchService search;
    setUp(() {
      search = SearchService(
        repo,
        tradition: 'drik_bishuddha',
        today: () => const CivilDate(2026, 10, 12),
      );
    });

    test('festival names in either script and with variants', () async {
      for (final q in ['কালী পূজা', 'kali puja', 'KALIPUJA']) {
        final hits = await search.search(q);
        expect(
          hits.whereType<FestivalResult>().map(
            (r) => r.observance.observance.id,
          ),
          contains('kali_puja'),
          reason: q,
        );
      }
      final laxmi = await search.search('laxmi');
      expect(
        laxmi.whereType<FestivalResult>().single.observance.observance.id,
        'lakshmi_puja',
      );
    });

    test('a Gregorian date comes with its Bengali date', () async {
      final r = (await search.search('১২/১০/২০২৬'))
          .whereType<DateResult>()
          .single;
      expect(r.date, const CivilDate(2026, 10, 12));
      expect(
        (r.bengaliDate!.day, r.bengaliDate!.monthIdx, r.bengaliDate!.year),
        (25, 5, 1433),
      );
    });

    test('a Bengali date resolves through the packs', () async {
      final r = (await search.search('25 Ashwin'))
          .whereType<DateResult>()
          .single;
      expect(r.date, const CivilDate(2026, 10, 12));
    });

    test('a Bengali date outside the packs is never guessed', () async {
      final r = (await search.search('১ বৈশাখ ১৪৩৩'))
          .whereType<DateResult>()
          .single;
      expect(r.date, isNull);
      expect(r.asked, const BengaliDay(1, 0, 1433));
    });
  });
}
