// T-112: Today's data assembles from the (sample) pack tables.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/repositories/today_repository.dart';
import 'package:panjika/domain/engine/karana.dart';

void main() {
  late AppDatabase db;
  late TodayRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    repo = TodayRepository(db);
  });
  tearDown(() => db.close());

  // 10:30 IST on the PRD wireframes' sample day.
  final sampleNow = DateTime.utc(2026, 10, 12, 5, 0);

  test('assembles the sample day', () async {
    final s = (await repo.load(
      now: sampleNow,
      tradition: 'drik_bishuddha',
      cityId: 'kolkata',
    ))!;
    expect(s.date, const CivilDate(2026, 10, 12));
    expect(
      (s.bnDay, s.bnMonth.bn, s.bnMonth.en, s.bnYear),
      (25, 'আশ্বিন', 'Ashwin', 1433),
    );
    expect(s.provenance.city.en, 'Kolkata');
    expect(s.provenance.tradition.bn, 'বিশুদ্ধ সিদ্ধান্ত (দৃক)');
    expect(
      s.provenance.isSample,
      isTrue,
      reason: 'sample packs must trigger the watermark',
    );
    expect(
      s.provenance.packIds,
      containsAll(['sample-global-drik', 'sample-cities']),
    );
    expect(s.sunrise.isBefore(s.sunset), isTrue);
  });

  test(
    'each element contains the moment and the tithi knows what follows',
    () async {
      final s = (await repo.load(
        now: sampleNow,
        tradition: 'drik_bishuddha',
        cityId: 'kolkata',
      ))!;
      for (final e in [s.tithi, s.nakshatra, s.yoga, s.karana]) {
        expect(!e.start.isAfter(sampleNow) && e.end.isAfter(sampleNow), isTrue);
      }
      expect(s.tithi.next, isNotNull);
      expect(s.tithi.progressAt(sampleNow), inInclusiveRange(0.0, 1.0));
    },
  );

  test('missing data gives null, never a guess (FR-HOME-09)', () async {
    expect(
      await repo.load(
        now: DateTime.utc(2030),
        tradition: 'drik_bishuddha',
        cityId: 'kolkata',
      ),
      isNull,
    );
    expect(
      await repo.load(
        now: sampleNow,
        tradition: 'drik_bishuddha',
        cityId: 'atlantis',
      ),
      isNull,
    );
    expect(
      await repo.load(
        now: sampleNow,
        tradition: 'surya_siddhanta',
        cityId: 'kolkata',
      ),
      isNull,
    );
  });

  test('karana index mapping (spec §6.5.4)', () {
    expect(karanaNameIndex(0), 10); // Kimstughna
    expect(karanaNameIndex(1), 0); // Bava
    expect(karanaNameIndex(7), 6); // Vishti
    expect(karanaNameIndex(8), 0); // Bava again
    expect(karanaNameIndex(56), 6); // last movable: (56 - 1) % 7
    expect(karanaNameIndex(57), 7); // Shakuni
    expect(karanaNameIndex(58), 8); // Chatushpada
    expect(karanaNameIndex(59), 9); // Naga
    expect(() => karanaNameIndex(60), throwsRangeError);
  });
}
