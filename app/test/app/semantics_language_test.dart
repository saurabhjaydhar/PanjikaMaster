// T-412: screen-reader labels per language (FR-L10N-08, §13.7). In an English UI,
// with names in both scripts on, no Bengali text reaches TalkBack untagged (it would
// be read with an English voice): every Bengali character in a label, value, hint or
// tooltip sits inside a Bengali LocaleStringAttribute, or is excluded. The other way
// round, the few English words a Bengali UI shows on purpose (the language switch)
// are tagged English.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/onboarding/onboarding_screen.dart';

import '../helpers/fakes.dart';

final _bengali = RegExp('[ঀ-৿]');

/// Every untagged run of Bengali script in the semantics tree, with where it is.
List<String> untaggedBengali(WidgetTester tester) {
  final problems = <String>[];
  void check(AttributedString s, String what) {
    final tagged = [
      for (final a in s.attributes)
        if (a is LocaleStringAttribute && a.locale.languageCode == 'bn')
          a.range,
    ];
    for (final m in _bengali.allMatches(s.string)) {
      final covered = tagged.any((r) => m.start >= r.start && m.end <= r.end);
      if (!covered) {
        problems.add('$what: "${s.string}"');
        return;
      }
    }
  }

  void visit(SemanticsNode node) {
    final d = node.getSemanticsData();
    check(d.attributedLabel, 'label');
    check(d.attributedValue, 'value');
    check(d.attributedHint, 'hint');
    if (_bengali.hasMatch(d.tooltip)) problems.add('tooltip: "${d.tooltip}"');
    node.visitChildren((c) {
      visit(c);
      return true;
    });
  }

  for (final view in tester.binding.renderViews) {
    visit(view.owner!.semanticsOwner!.rootSemanticsNode!);
  }
  return problems;
}

void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
  });
  tearDown(() => db.close());

  Future<void> open(
    WidgetTester tester, {
    String language = 'en',
    bool onboarded = true,
  }) async {
    tester.view
      ..physicalSize = const Size(360, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          deviceLocalesProvider.overrideWithValue([Locale(language)]),
          settingsSourceProvider.overrideWithValue(
            MemorySettings({
              if (onboarded) SettingKey.onboardingDone: '1',
              SettingKey.namesBothScripts: '1',
            }),
          ),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> go(WidgetTester tester, String location) async {
    GoRouter.of(tester.element(find.byType(Navigator).first)).go(location);
    await tester.pumpAndSettle();
  }

  for (final location in [
    '/today',
    '/calendar',
    '/day/2026-10-20',
    '/more',
    '/settings',
    '/about',
    '/city',
    '/festival/mahalaya',
  ]) {
    testWidgets(
      'English UI, both scripts: $location reads no untagged Bengali',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await open(tester);
        await go(tester, location);
        expect(untaggedBengali(tester), isEmpty);
        semantics.dispose();
      },
    );
  }

  testWidgets('English UI: the glossary sheet reads no untagged Bengali', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await open(tester);
    await go(tester, '/day/2026-10-20');
    await tester.tap(find.byTooltip('What does this mean?').first);
    await tester.pumpAndSettle();
    expect(untaggedBengali(tester), isEmpty);
    semantics.dispose();
  });

  testWidgets('onboarding: each step in English reads no untagged Bengali', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await open(tester, onboarded: false);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    for (var step = 0; step < 4; step++) {
      expect(untaggedBengali(tester), isEmpty, reason: 'step ${step + 1}');
      if (step < 3) {
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
      }
    }
    semantics.dispose();
  });

  testWidgets(
    'Bengali UI: "English" in the language switch is tagged English',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await open(tester, language: 'bn');
      await go(tester, '/more');
      final data = tester.getSemantics(find.text('English')).getSemanticsData();
      expect(
        data.attributedLabel.attributes.whereType<LocaleStringAttribute>().map(
          (a) => a.locale.languageCode,
        ),
        contains('en'),
      );
      semantics.dispose();
    },
  );

  testWidgets('both scripts on: the second line is not read at all', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await open(tester);
    await go(tester, '/settings');
    // The names preview shows the Bengali second line, but no label carries it.
    expect(find.text('শুক্লা সপ্তমী'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('শুক্লা সপ্তমী')), findsNothing);
    semantics.dispose();
  });
}
