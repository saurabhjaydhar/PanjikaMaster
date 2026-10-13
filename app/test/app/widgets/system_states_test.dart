// T-310: every system state (spec §11.9, §16) in both languages, with and without its
// action; goldens for the banner and note (bn/en × light/dark × 100/200 %).
// Update goldens intentionally with: flutter test --update-goldens test/app/widgets
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/widgets/system_states.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/data/db/app_database.dart';

import '../../helpers/fonts.dart';
import '../../helpers/harness.dart';

/// (message, action label or null) per state; the copy of spec §11.9.
const copy = {
  AppLanguage.bn: {
    SystemState.notDownloaded: (
      'এই সময়ের তথ্য ডাউনলোড করা নেই।',
      'ডাউনলোড করুন',
    ),
    SystemState.offline: (
      'ইন্টারনেট সংযোগ নেই। সংযোগ পেলে তথ্য ডাউনলোড হবে।',
      null,
    ),
    SystemState.stale: ('তথ্য হালনাগাদ প্রয়োজন।', 'হালনাগাদ করুন'),
    SystemState.signatureFailed: (
      'তথ্য যাচাই করা যায়নি, তাই দেখানো হচ্ছে না।',
      'আবার চেষ্টা করুন',
    ),
    SystemState.unverified: ('এই তারিখ এখনও পঞ্জিকা মিলিয়ে দেখা হয়নি।', null),
    SystemState.checkClock: ('ফোনের তারিখ ঠিক আছে কিনা দেখুন', null),
  },
  AppLanguage.en: {
    SystemState.notDownloaded: (
      "Data for these dates isn't downloaded yet.",
      'Download',
    ),
    SystemState.offline: (
      "You're offline. The data will download when you're connected.",
      null,
    ),
    SystemState.stale: ('This data needs an update.', 'Update'),
    SystemState.signatureFailed: (
      "We couldn't verify this data, so it isn't shown.",
      'Try again',
    ),
    SystemState.unverified: (
      "This date hasn't been checked against the panjika yet.",
      null,
    ),
    SystemState.checkClock: ("Please check your phone's date", null),
  },
};

void main() {
  setUpAll(loadAppFonts);
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  for (final language in AppLanguage.values) {
    for (final state in SystemState.values) {
      testWidgets('${language.name}: ${state.name}', (tester) async {
        var tapped = 0;
        final (message, action) = copy[language]![state]!;
        await pumpComponent(
          tester,
          SystemStateMessage(state, onAction: () => tapped++),
          db: db,
          language: language,
        );
        expect(find.text(message), findsOneWidget);
        if (action == null) {
          expect(find.byType(FilledButton), findsNothing);
        } else {
          await tester.tap(find.text(action));
          expect(tapped, 1);
        }
        // Without a handler there is never a button.
        await pumpComponent(
          tester,
          SystemStateMessage(state),
          db: db,
          language: language,
        );
        expect(find.byType(FilledButton), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('stale banner: shown above content, update only with a handler', (
    tester,
  ) async {
    var updated = false;
    await pumpComponent(
      tester,
      StaleBanner(onUpdate: () => updated = true),
      db: db,
      language: AppLanguage.en,
    );
    await tester.tap(find.text('Update'));
    expect(updated, isTrue);
    await pumpComponent(
      tester,
      const StaleBanner(),
      db: db,
      language: AppLanguage.en,
    );
    expect(find.text('Update'), findsNothing);
    expect(find.text('This data needs an update.'), findsOneWidget);
  });

  for (final language in AppLanguage.values) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'states_${language.name}_${brightness.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await pumpComponent(
            tester,
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  StaleBanner(onUpdate: () {}),
                  const SizedBox(height: 16),
                  const UnverifiedNote(),
                  const SizedBox(height: 16),
                  SystemStateMessage(SystemState.checkClock, onAction: () {}),
                ],
              ),
            ),
            db: db,
            language: language,
            brightness: brightness,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 900 : 560),
          );
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/$id.png'),
          );
        });
      }
    }
  }
}
