// T-509: share rendering — the card renders to a 1080 × 1350 PNG whatever the screen
// or text size; the message is in the chosen language(s) with its provenance, and a
// link only when a share domain is configured.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/domain/entities/name_ref.dart';
import 'package:panjika/features/share/share_render.dart';
import 'package:panjika/features/share/share_text.dart';
import 'package:panjika/l10n/gen/app_localizations.dart';

import '../../helpers/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<GlobalKey> pumpCard(
    WidgetTester tester, {
    double textScale = 1,
  }) async {
    final key = GlobalKey();
    tester.view
      ..physicalSize = const Size(360, 640)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('bn'), Locale('en')],
        home: FittedBox(
          child: ShareCardFrame(
            language: AppLanguage.bn,
            boundaryKey: key,
            child: const Center(child: Text('কালীপূজা', key: Key('t'))),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key;
  }

  testWidgets('renders 1080 × 1350 on a 360 dp phone', (tester) async {
    final key = await pumpCard(tester);
    final size = await tester.runAsync(() async {
      final png = await renderSharePng(key);
      final codec = await ui.instantiateImageCodec(png);
      final frame = await codec.getNextFrame();
      return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
    });
    expect(size, shareCardSize);
  });

  testWidgets('the card ignores the device text size', (tester) async {
    await pumpCard(tester);
    final normal = tester.getSize(find.byKey(const Key('t')));
    await pumpCard(tester, textScale: 2);
    expect(tester.getSize(find.byKey(const Key('t'))), normal);
  });

  test('a link only with a share domain', () {
    expect(shareLink('/day/2026-10-12', base: ''), isNull);
    expect(
      shareLink('/day/2026-10-12', base: 'https://share.example/'),
      'https://share.example/day/2026-10-12',
    );
  });

  test(
    'the message follows the chosen language, provenance on every block',
    () {
      const tradition = NameRef('বিশুদ্ধ সিদ্ধান্ত', 'Bishuddha Siddhanta');
      const name = NameRef('কালীপূজা', 'Kali Puja');
      String build(ShareLanguage s, {String? link}) => shareMessage(
        s,
        line: (l, f, a) => l.shareFestivalMessage(name.of(a), f.digits('8')),
        provenance: (l, a) => provenanceLine(l, a, tradition),
        link: link,
      );
      expect(build(ShareLanguage.bn), 'কালীপূজা: ৮\nবিশুদ্ধ সিদ্ধান্ত মতে');
      expect(
        build(ShareLanguage.en),
        'Kali Puja: 8\nAs per Bishuddha Siddhanta',
      );
      expect(
        build(ShareLanguage.both, link: 'https://share.example/x'),
        'কালীপূজা: ৮\nবিশুদ্ধ সিদ্ধান্ত মতে\n\n'
        'Kali Puja: 8\nAs per Bishuddha Siddhanta\n\n'
        'https://share.example/x',
      );
    },
  );
}
