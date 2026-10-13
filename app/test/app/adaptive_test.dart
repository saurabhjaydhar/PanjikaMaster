// T-408: adaptive layout — on a 600 dp (medium) screen content is centred at most
// 640 dp wide and calendar cells grow; on a landscape phone Today scrolls, calendar
// cells stay ≥ 48 dp and the selected day sits beside the grid. Goldens per screen
// at 600 × 960 and 800 × 360, bn and en. Data: the watermarked sample pack.
// Update goldens intentionally with: flutter test --update-goldens test/app/adaptive_test.dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/theme/app_theme.dart';
import 'package:panjika/app/theme/tokens.dart';
import 'package:panjika/app/widgets/calendar_day_cell.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/fonts.dart';

const _medium = Size(600, 960);
const _landscape = Size(800, 360);

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
  });
  tearDown(() => db.close());

  Future<void> open(
    WidgetTester tester,
    String location, {
    required Size size,
    String language = 'bn',
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          deviceLocalesProvider.overrideWithValue([Locale(language)]),
          settingsSourceProvider.overrideWithValue(
            MemorySettings({
              SettingKey.onboardingDone: '1',
              SettingKey.theme: ThemeMode.light.name,
            }),
          ),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    if (location != '/today') {
      GoRouter.of(tester.element(find.byType(TodayScreen))).go(location);
      await tester.pumpAndSettle();
    }
  }

  test('content inset: margins on phones, centred 640 dp beyond', () {
    expect(contentInset(360), Space.screenCompact);
    expect(contentInset(600), Space.screenWide);
    expect(contentInset(1000), (1000 - Space.maxContentWidth) / 2);
  });

  testWidgets('600 dp: calendar centred, cells grow', (tester) async {
    await open(tester, '/calendar', size: _medium);
    final cells = find.byType(CalendarDayCell);
    final width = tester.getSize(cells.first).width;
    expect(width, greaterThan(80), reason: 'about 640 / 7');
    final left = tester.getTopLeft(cells.first).dx;
    expect(left, greaterThan(0));
  });

  testWidgets('landscape: cells stay ≥ 48 dp, the strip moves beside the grid', (
    tester,
  ) async {
    await open(tester, '/calendar', size: _landscape);
    final cell = tester.getSize(find.byType(CalendarDayCell).first);
    expect(cell.width, greaterThanOrEqualTo(48));
    expect(cell.height, greaterThanOrEqualTo(48));
    final grid = tester.getTopRight(find.byType(CalendarDayCell).first);
    final strip = tester.getTopLeft(find.text('দেখুন'));
    expect(strip.dx, greaterThan(grid.dx), reason: 'strip to the right');
  });

  const screens = {
    'today': '/today',
    'calendar': '/calendar',
    'day': '/day/2026-10-12',
    'more': '/more',
    'settings': '/settings',
  };
  for (final MapEntry(key: name, value: location) in screens.entries) {
    for (final (form, size) in [('600', _medium), ('landscape', _landscape)]) {
      for (final language in ['bn', 'en']) {
        final id = 'adaptive_${name}_${form}_$language';
        testWidgets('golden $id', (tester) async {
          await open(tester, location, size: size, language: language);
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(PanjikaApp),
            matchesGoldenFile('goldens/$id.png'),
          );
        });
      }
    }
  }
}
