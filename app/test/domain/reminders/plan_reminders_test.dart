// T-506: reminder planning — festival timings in IST, recurring tithi reminders with
// "tithi begins", the 60-day horizon, the 64 cap, stable ids, multi-day festivals on
// their first day, and a config that survives bad JSON. Synthetic observances and
// tithis only; no calendar data.
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/domain/entities/name_ref.dart';
import 'package:panjika/domain/entities/panjika.dart';
import 'package:panjika/domain/reminders/plan_reminders.dart';
import 'package:panjika/domain/reminders/reminder_config.dart';

ObservanceDate _o(String id, CivilDate date, {int dayIndex = 0}) =>
    ObservanceDate(
      observance: Observance(
        id: id,
        name: NameRef('নাম $id', 'Name $id'),
        category: ObservanceCategory.puja,
        tier: 1,
        description: const NameRef('ক', 'a'),
      ),
      date: date,
      dayIndex: dayIndex,
      status: VerificationStatus.computed,
      packId: 'p',
    );

class _Copy implements ReminderCopy {
  @override
  String title(ObservanceDate o, ReminderTiming timing) =>
      '${o.observance.id}:${timing.name}';

  @override
  String body(ObservanceDate o, DateTime? tithiStart) =>
      tithiStart == null ? 'date' : 'tithi ${tithiStart.toIso8601String()}';
}

const _d = CivilDate(2030, 3, 10); // synthetic
final _now = DateTime.utc(2030, 3, 1);

List<PlannedReminder> plan(
  ReminderConfig config,
  List<ObservanceDate> observances, {
  List<Transition> tithis = const [],
  DateTime? now,
}) => planReminders(
  config: config,
  observances: observances,
  tithis: tithis,
  now: now ?? _now,
  copy: _Copy(),
);

void main() {
  test(
    'festival: the evening before at 20:00 IST, the morning at 06:00 IST',
    () {
      final config = const ReminderConfig().withFestival('kali', const [
        ReminderTime(ReminderTiming.dayBefore, 20 * 60),
        ReminderTime(ReminderTiming.morningOf, 6 * 60),
      ]);
      final got = plan(config, [_o('kali', _d)]);
      expect(got.map((r) => r.at), [
        DateTime.utc(2030, 3, 9, 14, 30), // 20:00 IST on the 9th
        DateTime.utc(2030, 3, 10, 0, 30), // 06:00 IST on the 10th
      ]);
      expect(got.first.title, 'kali:dayBefore');
      expect(got.first.channel, ReminderChannel.festival);
      expect(got.first.route, '/festival/kali?date=2030-03-10');
    },
  );

  test('only configured observances, only first days, only the future', () {
    final config = const ReminderConfig().withFestival(
      'puja',
      ReminderConfig.festivalDefault,
    );
    final got = plan(config, [
      _o('other', _d),
      _o('puja', _d),
      _o('puja', _d.addDays(1), dayIndex: 1),
      _o('puja', const CivilDate(2030, 2, 20)), // before now
    ]);
    expect(got, hasLength(1));
    expect(got.single.at, DateTime.utc(2030, 3, 9, 14, 30));
  });

  test('nothing past the 60-day horizon', () {
    final config = const ReminderConfig().withFestival(
      'x',
      ReminderConfig.festivalDefault,
    );
    final inside = _o('x', CivilDate.ofInstant(_now).addDays(59));
    final outside = _o('x', CivilDate.ofInstant(_now).addDays(70));
    expect(plan(config, [inside, outside]), hasLength(1));
  });

  test('recurring Ekadashi: the body says when the tithi begins', () {
    final start = DateTime.utc(
      2030,
      3,
      9,
      15,
      44,
    ); // 21:14 IST the evening before
    final ekadashi = Transition(
      kind: TransitionKind.tithi,
      idx: 10,
      startUtc: start,
      endUtc: start.add(const Duration(hours: 23)),
      packId: 'p',
    );
    final config = const ReminderConfig().withRecurring(
      RecurringKind.ekadashi,
      const [
        ReminderTime(ReminderTiming.dayBefore, 20 * 60),
        ReminderTime(ReminderTiming.tithiStart),
      ],
    );
    final got = plan(config, [_o('ekadashi', _d)], tithis: [ekadashi]);
    expect(got.map((r) => r.at), [DateTime.utc(2030, 3, 9, 14, 30), start]);
    expect(got.first.body, 'tithi ${start.toIso8601String()}');
    expect(got.first.channel, ReminderChannel.tithi);
    expect(got.last.title, 'ekadashi:tithiStart');
  });

  test('at most 64, the earliest first', () {
    final config = const ReminderConfig().withFestival(
      'f',
      ReminderConfig.festivalDefault,
    );
    final many = [
      for (var i = 50; i >= 1; i--)
        _o('f', CivilDate.ofInstant(_now).addDays(i)),
    ];
    final both = config.withFestival('f', const [
      ReminderTime(ReminderTiming.dayBefore, 20 * 60),
      ReminderTime(ReminderTiming.morningOf, 6 * 60),
    ]);
    final got = plan(both, many);
    expect(got, hasLength(cap));
    for (var i = 1; i < got.length; i++) {
      expect(got[i].at.isAfter(got[i - 1].at), isTrue);
    }
  });

  test('ids are stable and differ by timing', () {
    final config = const ReminderConfig().withFestival('kali', const [
      ReminderTime(ReminderTiming.dayBefore, 20 * 60),
      ReminderTime(ReminderTiming.morningOf, 6 * 60),
    ]);
    final a = plan(config, [_o('kali', _d)]);
    final b = plan(config, [_o('kali', _d)]);
    expect(a.map((r) => r.id), b.map((r) => r.id));
    expect(a.first.id, isNot(a.last.id));
    expect(reminderId('x'), reminderId('x'));
    expect(reminderId('x'), inInclusiveRange(0, 0x7fffffff));
  });

  test('config round-trips and survives bad JSON', () {
    final config = const ReminderConfig()
        .withFestival('kali', ReminderConfig.festivalDefault)
        .withRecurring(RecurringKind.purnima, ReminderConfig.recurringDefault);
    final back = ReminderConfig.decode(config.encode());
    expect(back.festivals['kali'], ReminderConfig.festivalDefault);
    expect(
      back.recurring[RecurringKind.purnima],
      ReminderConfig.recurringDefault,
    );
    expect(ReminderConfig.decode('not json').isEmpty, isTrue);
    expect(
      ReminderConfig.decode('{"festivals": {"x": [{"timing": "never"}]}}')
          .isEmpty,
      isTrue,
    );
    expect(config.withFestival('kali', null).festivals, isEmpty);
  });
}
