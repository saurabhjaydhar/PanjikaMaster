// T-508: reschedule triggers — app start and return, city change, language change
// (texts and channel names follow), pack import; reboot is the plugin's boot receiver
// (checked in the manifest); time-zone changes can't move absolute instants; and
// overlapping triggers fold into one extra run. Data: the sample pack.
import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/notifications/notification_scheduler.dart';
import 'package:panjika/data/packs/pack_updater.dart';
import 'package:panjika/domain/reminders/plan_reminders.dart';
import 'package:panjika/domain/reminders/reminder_config.dart';
import 'package:panjika/features/reminders/reminder_service.dart';
import 'package:panjika/features/reminders/reminder_triggers.dart';

import '../../helpers/fakes.dart';

final _kali = const ReminderConfig()
    .withFestival('kali_puja', ReminderConfig.festivalDefault)
    .encode();

void main() {
  late AppDatabase db;
  late FakeNotificationScheduler scheduler;
  late MemorySettings settings;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    scheduler = FakeNotificationScheduler();
    settings = MemorySettings({
      SettingKey.onboardingDone: '1',
      SettingKey.locale: 'bn',
      SettingKey.reminders: _kali,
    });
  });
  tearDown(() => db.close());

  List<Override> overrides([NotificationScheduler? s]) => [
    appDatabaseProvider.overrideWithValue(db),
    settingsSourceProvider.overrideWithValue(settings),
    deviceLocalesProvider.overrideWithValue([const Locale('bn')]),
    appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
    clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
    notificationSchedulerProvider.overrideWithValue(s ?? scheduler),
  ];

  test('each trigger reschedules; an update without imports does not', () {
    var runs = 0;
    final t = ReminderTriggers(() async => runs++)
      ..appStarted()
      ..appResumed()
      ..cityChanged()
      ..languageChanged()
      ..updated(
        const UpdateDone(imported: ['p'], waitingForUser: [], notices: []),
      );
    expect(runs, 5);
    t
      ..updated(const UpdateDone(imported: [], waitingForUser: [], notices: []))
      ..updated(const UpdateFailed('offline'))
      ..updated(null);
    expect(runs, 5);
  });

  test('a city or language change replans, in the new language', () async {
    final c = ProviderContainer(overrides: overrides());
    addTearDown(c.dispose);
    c.read(reminderTriggersProvider);
    final service = c.read(reminderServiceProvider);

    await c.read(cityIdProvider.notifier).set('howrah');
    await service.reschedule();
    expect(scheduler.plans, isNotEmpty);
    expect(scheduler.last.single.title, 'আগামীকাল কালীপূজা');

    await c.read(appLanguageProvider.notifier).select(AppLanguage.en);
    await service.reschedule();
    expect(scheduler.last.single.title, 'Kali Puja tomorrow');
    expect(
      scheduler.channels[ReminderChannel.festival]!.name,
      'Festival reminders',
    );
  });

  testWidgets('the app reschedules when it starts', (tester) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(overrides: overrides(), child: const PanjikaApp()),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(scheduler.plans, isNotEmpty);
    expect(scheduler.last.single.route, '/festival/kali_puja?date=2026-11-08');
  });

  test('overlapping triggers fold into one more run', () async {
    final gate = Completer<void>();
    var calls = 0;
    final slow = _SlowScheduler(() async {
      calls++;
      if (calls == 1) await gate.future;
    });
    final c = ProviderContainer(overrides: overrides(slow));
    addTearDown(c.dispose);
    final service = c.read(reminderServiceProvider);
    final first = service.reschedule();
    for (var i = 0; i < 5; i++) {
      unawaited(service.reschedule());
    }
    gate.complete();
    await first;
    expect(calls, 2);
  });

  test('reboot: the boot receiver restores scheduled reminders', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    expect(manifest, contains('ScheduledNotificationBootReceiver'));
    expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
  });

  test('time-zone changes cannot move a reminder: instants are absolute', () {
    final at = istInstant(const CivilDate(2026, 11, 7), 20 * 60);
    expect(at, DateTime.utc(2026, 11, 7, 14, 30));
    expect(at.isUtc, isTrue);
  });
}

class _SlowScheduler implements NotificationScheduler {
  _SlowScheduler(this._onCall);

  final Future<void> Function() _onCall;

  @override
  Future<void> replaceAll(
    List<PlannedReminder> plan, {
    required Map<ReminderChannel, ChannelText> channels,
  }) => _onCall();
}
