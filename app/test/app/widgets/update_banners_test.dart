// T-311: notice banner, download prompt and update problems — both languages,
// goldens (bn/en × light/dark × 100/200 %).
// Update goldens intentionally with: flutter test --update-goldens test/app/widgets
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/widgets/update_banners.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/packs/manifest.dart';
import 'package:panjika/domain/entities/name_ref.dart';

import '../../helpers/fonts.dart';
import '../../helpers/harness.dart';

// Test input, not a real notice.
const notice = ManifestNotice(
  id: 'n1',
  level: 'info',
  text: NameRef(
    'নমুনা বিজ্ঞপ্তি: নতুন বছরের তথ্য তৈরি।',
    'Sample notice: the new year\'s data is ready.',
  ),
);

void main() {
  setUpAll(loadAppFonts);
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget page({
    VoidCallback? onDismiss,
    VoidCallback? onDownload,
    VoidCallback? onLater,
  }) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        NoticeBanner(notice, onDismiss: onDismiss ?? () {}),
        const SizedBox(height: 12),
        DownloadPrompt(
          bytes: 3 * 1024 * 1024 + 100 * 1024,
          onDownload: onDownload ?? () {},
          onLater: onLater ?? () {},
        ),
        const SizedBox(height: 12),
        const UpdateProblem('—'), // l10n-ok: test input
      ],
    ),
  );

  testWidgets('Bengali: size in Bengali numerals, actions work', (
    tester,
  ) async {
    var downloads = 0, later = 0, dismissed = 0;
    await pumpComponent(
      tester,
      page(
        onDismiss: () => dismissed++,
        onDownload: () => downloads++,
        onLater: () => later++,
      ),
      db: db,
    );
    expect(
      find.text('নতুন তথ্য পাওয়া যাচ্ছে (৩.১ এমবি)। এখন ডাউনলোড করবেন?'),
      findsOneWidget,
    );
    expect(find.text(notice.text.bn), findsOneWidget);
    await tester.tap(find.text('ডাউনলোড করুন'));
    await tester.tap(find.text('পরে'));
    await tester.tap(find.text('বুঝেছি'));
    expect((downloads, later, dismissed), (1, 1, 1));
  });

  testWidgets('English', (tester) async {
    await pumpComponent(tester, page(), db: db, language: AppLanguage.en);
    expect(
      find.text('New data is available (3.1 MB). Download now?'),
      findsOneWidget,
    );
    expect(find.text(notice.text.en), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });

  for (final language in AppLanguage.values) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'updates_${language.name}_${brightness.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await pumpComponent(
            tester,
            page(),
            db: db,
            language: language,
            brightness: brightness,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 900 : 520),
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
