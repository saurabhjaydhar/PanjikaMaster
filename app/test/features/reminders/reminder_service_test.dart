// T-506: the reminder service plans from the installed packs and hands the plan to
// the scheduler, with texts and channel names in the UI language and the provenance
// in every body. Data: the sample pack (Kali Puja on 8 Nov 2026, sample).
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/notifications/notification_scheduler.dart';
import 'package:panjika/domain/reminders/plan_reminders.dart';
import 'package:panjika/domain/reminders/reminder_config.dart';
import 'package:panjika/features/reminders/reminder_prefs.dart';
import 'package:panjika/features/reminders/reminder_service.dart';

import '../../helpers/fakes.dart';

void main() {
  late AppDatabase db;
  late FakeNotificationScheduler scheduler;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    scheduler = FakeNotificationScheduler();
  });
  tearDown(() => db.close());

  ProviderContainer container({String language = 'bn'}) {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsSourceProvider.overrideWithValue(
          MemorySettings({SettingKey.locale: language}),
        ),
        deviceLocalesProvider.overrideWithValue([Locale(language)]),
        appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
        notificationSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('a festival reminder in Bengali, with its provenance', () async {
    final c = container();
    await c.read(reminderConfigProvider.notifier).toggleFestival('kali_puja');
    await c.read(reminderServiceProvider).reschedule();
    final r = scheduler.last.single;
    expect(r.at, DateTime.utc(2026, 11, 7, 14, 30)); // 20:00 IST the day before
    expect(r.title, 'আগামীকাল কালীপূজা');
    expect(r.body, contains('বিশুদ্ধ সিদ্ধান্ত (দৃক) · IST'));
    expect(r.route, '/festival/kali_puja?date=2026-11-08');
    expect(
      scheduler.channels[ReminderChannel.festival]!.name,
      'উৎসব অনুস্মারক',
    );
  });

  test('English UI: English texts and channel names', () async {
    final c = container(language: 'en');
    await c.read(reminderConfigProvider.notifier).toggleFestival('kali_puja');
    await c.read(reminderServiceProvider).reschedule();
    expect(scheduler.last.single.title, 'Kali Puja tomorrow');
    expect(scheduler.channels[ReminderChannel.tithi]!.name, 'Tithi reminders');
  });

  test('nothing configured clears every scheduled reminder', () async {
    final c = container();
    await c.read(reminderServiceProvider).reschedule();
    expect(scheduler.plans.single, isEmpty);
  });

  test('turning a festival off reschedules without it', () async {
    final c = container();
    final prefs = c.read(reminderConfigProvider.notifier);
    await prefs.toggleFestival('kali_puja');
    await prefs.setRecurring(
      RecurringKind.ekadashi,
      ReminderConfig.recurringDefault,
    );
    await prefs.toggleFestival('kali_puja');
    await c.read(reminderServiceProvider).reschedule();
    // The sample pack has no Ekadashi observance, so nothing is left to remind of.
    expect(scheduler.last, isEmpty);
    expect(c.read(reminderConfigProvider).recurring, isNotEmpty);
  });
}
