// T-214: motion (spec §12.8) with the system's reduced-motion setting on and off: the
// ring fill, the tithi-name cross-fade, once-per-day filling on Today, and haptics.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/widgets/calendar_day_cell.dart';
import 'package:panjika/app/widgets/language_switch.dart';
import 'package:panjika/app/widgets/panjika_widgets.dart';
import 'package:panjika/app/widgets/tithi_seal.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/domain/entities/name_ref.dart';
import 'package:panjika/features/today/today_providers.dart';

import '../../helpers/fakes.dart';
import '../../helpers/harness.dart';

// Test inputs, not calendar data.
const first = NameRef('প্রথম', 'First');
const second = NameRef('দ্বিতীয়', 'Second');

void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
  });
  tearDown(() => db.close());

  void reduceMotion(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  double shown(WidgetTester tester) =>
      tester.state<TithiRingState>(find.byType(TithiRing)).displayedProgress;

  Widget seal(NameRef name, {double progress = 0.6, bool animate = true}) =>
      Center(
        child: TithiSeal(
          name: name,
          nameText: name.bn,
          until: '-', // l10n-ok: test input
          then: '-', // l10n-ok: test input
          progress: progress,
          animateFill: animate,
        ),
      );

  group('tithi ring', () {
    testWidgets('fills from empty in 500 ms, then follows the clock silently', (
      tester,
    ) async {
      await pumpComponent(tester, seal(first), db: db);
      // pumpComponent settles; start again to watch the fill.
      await tester.pumpWidget(const SizedBox());
      await pumpComponentNoSettle(tester, seal(first), db: db);
      expect(shown(tester), 0);
      await tester.pump(const Duration(milliseconds: 250));
      expect(shown(tester), allOf(greaterThan(0), lessThan(0.6)));
      await tester.pump(const Duration(milliseconds: 260));
      expect(shown(tester), closeTo(0.6, 1e-9));

      await pumpComponentNoSettle(tester, seal(first, progress: 0.7), db: db);
      expect(shown(tester), closeTo(0.7, 1e-9), reason: 'no second animation');
    });

    testWidgets('reduced motion: full at once', (tester) async {
      reduceMotion(tester);
      await pumpComponentNoSettle(tester, seal(first), db: db);
      expect(shown(tester), closeTo(0.6, 1e-9));
    });

    testWidgets('without animateFill: full at once', (tester) async {
      await pumpComponentNoSettle(tester, seal(first, animate: false), db: db);
      expect(shown(tester), closeTo(0.6, 1e-9));
    });
  });

  group('tithi name', () {
    testWidgets('old and new names cross-fade over 250 ms', (tester) async {
      await pumpComponent(tester, seal(first), db: db);
      await pumpComponentNoSettle(tester, seal(second), db: db);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('প্রথম'), findsOneWidget);
      expect(find.text('দ্বিতীয়'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('প্রথম'), findsNothing);
    });

    testWidgets('reduced motion: the new name replaces the old at once', (
      tester,
    ) async {
      reduceMotion(tester);
      await pumpComponent(tester, seal(first), db: db);
      await pumpComponentNoSettle(tester, seal(second), db: db);
      await tester.pump();
      expect(find.text('প্রথম'), findsNothing);
      expect(find.text('দ্বিতীয়'), findsOneWidget);
    });
  });

  testWidgets('Today fills the ring once per panjika day', (tester) async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        deviceLocalesProvider.overrideWithValue(const [Locale('bn')]),
        settingsSourceProvider.overrideWithValue(
          MemorySettings({SettingKey.onboardingDone: '1'}),
        ),
        appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
      ],
    );
    Widget app() => UncontrolledProviderScope(
      container: container,
      child: const PanjikaApp(),
    );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(
      container.read(ringFilledForProvider),
      const CivilDate(2026, 10, 12),
    );

    // Open Today again (a fresh widget tree, same app state): no second fill.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();
    final ring = tester.widget<TithiRing>(find.byType(TithiRing));
    expect(ring.animateFill, isFalse);
    expect(shown(tester), closeTo(ring.progress, 1e-9));

    // Before the test ends, so the clock's timer is cancelled with the tree gone.
    await tester.pumpWidget(const SizedBox());
    container.dispose();
  });

  testWidgets('selection haptics on day cells and the language switch', (
    tester,
  ) async {
    final haptics = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpComponent(
      tester,
      Column(
        children: [
          CalendarDayCell(
            primaryDay: 1,
            secondaryDay: 1,
            semanticsLabel: '-', // l10n-ok: test input
            onTap: () {},
          ),
          const LanguageSwitch(),
        ],
      ),
      db: db,
    );
    await tester.tap(find.byType(CalendarDayCell));
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(haptics, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.selectionClick',
    ]);
  });
}
