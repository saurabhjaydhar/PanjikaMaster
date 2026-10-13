// T-111: the four-tab shell — labels in both languages, navigation, back handling,
// language switch keeping the current tab, and 200 % text.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/features/calendar/calendar_screen.dart';
import 'package:panjika/features/festivals/festivals_screen.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/fonts.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  double textScale = 1.0,
}) async {
  final container = ProviderContainer(
    overrides: [
      deviceLocalesProvider.overrideWithValue(const [Locale('bn')]),
      settingsSourceProvider.overrideWithValue(MemorySettings()),
      appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
    ],
  );
  addTearDown(container.dispose);
  tester.view
    ..physicalSize = const Size(360, 640) * 3
    ..devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const PanjikaApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

NavigationBar navBar(WidgetTester tester) =>
    tester.widget(find.byType(NavigationBar));

void main() {
  setUpAll(loadAppFonts);

  testWidgets('opens on Today with four labelled tabs in Bengali', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(navBar(tester).selectedIndex, 0);
    for (final label in ['আজ', 'পঞ্জিকা', 'পার্বণ', 'আরও']) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('tapping a tab navigates to it', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('পার্বণ'));
    await tester.pumpAndSettle();
    expect(find.byType(FestivalsScreen), findsOneWidget);
    expect(navBar(tester).selectedIndex, 2);
  });

  testWidgets('switching language keeps the current tab', (tester) async {
    final container = await pumpApp(tester);
    await tester.tap(find.text('পঞ্জিকা'));
    await tester.pumpAndSettle();

    await container.read(appLanguageProvider.notifier).select(AppLanguage.en);
    await tester.pumpAndSettle();

    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(navBar(tester).selectedIndex, 1);
    for (final label in ['Today', 'Calendar', 'Festivals', 'More']) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('system back: another tab → Today; Today → app closes', (
    tester,
  ) async {
    await pumpApp(tester);
    final closeRequests = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.pop') closeRequests.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.tap(find.text('পার্বণ'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute(); // system back on Festivals
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(navBar(tester).selectedIndex, 0);
    expect(
      closeRequests,
      isEmpty,
      reason: 'back from another tab must not close the app',
    );

    await tester.binding.handlePopRoute(); // system back on Today
    await tester.pumpAndSettle();
    expect(closeRequests, hasLength(1), reason: 'back on Today leaves the app');
  });

  testWidgets('200 % text on a 360 dp phone: no overflow, labels still shown', (
    tester,
  ) async {
    await pumpApp(tester, textScale: 2.0);
    expect(tester.takeException(), isNull);
    for (final label in ['আজ', 'পঞ্জিকা', 'পার্বণ', 'আরও']) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('every tab renders in English at 200 % without overflow', (
    tester,
  ) async {
    final container = await pumpApp(tester, textScale: 2.0);
    await container.read(appLanguageProvider.notifier).select(AppLanguage.en);
    await tester.pumpAndSettle();
    for (final label in ['Calendar', 'Festivals', 'More', 'Today']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: label);
    }
  });
}
