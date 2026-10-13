// T-109: golden images of the type scale and colour tokens, bn/en × light/dark.
// Update intentionally with: flutter test --update-goldens test/app/theme
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/theme/app_theme.dart';
import 'package:panjika/app/theme/tokens.dart';
import 'package:panjika/core/l10n/app_language.dart';

import '../../helpers/fonts.dart';

// Sample text only (test file, not app UI). Long conjunct-heavy names per spec §12.11.
const _samples = {
  AppLanguage.bn: (
    display: '২৫ আশ্বিন ১৪৩৩',
    headline: 'মহাষ্টমী',
    title: 'আজকের সময়',
    body: 'শুক্লা সপ্তমী, দুপুর ২:৩২ পর্যন্ত',
    label: 'নক্ষত্র · যোগ · করণ',
    caption: 'দৃক (বিশুদ্ধ) · কলকাতা · IST',
    stress: 'উত্তরভাদ্রপদ · কোজাগরী লক্ষ্মীপূজা · জগদ্ধাত্রী পূজা · ক্ষয় তিথি',
  ),
  AppLanguage.en: (
    display: '25 Ashwin 1433',
    headline: 'Maha Ashtami',
    title: "Today's periods",
    body: 'Shukla Saptami until 2:32 PM',
    label: 'Nakshatra · Yoga · Karana',
    caption: 'Drik (Bishuddha) · Kolkata · IST',
    stress: 'Uttara Bhadrapada · Kojagari Lakshmi Puja · Śukla Saptamī · উত্তরভাদ্রপদ',
  ),
};

class _Specimen extends StatelessWidget {
  const _Specimen(this.language);

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final s = _samples[language]!;
    Widget swatch(Color color) => Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(right: Space.s),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Radii.small),
        border: Border.all(color: c.rule),
      ),
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Space.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.display, style: t.displaySmall),
            Text(s.headline, style: t.headlineSmall),
            Text(s.title, style: t.titleLarge),
            Text(s.body, style: t.bodyLarge),
            Text(s.label, style: t.labelLarge),
            Text(s.caption, style: t.bodySmall?.copyWith(color: c.inkMuted)),
            const SizedBox(height: Space.m),
            Text(s.stress, style: t.bodyLarge),
            const SizedBox(height: Space.m),
            Container(
              padding: const EdgeInsets.all(Space.l),
              decoration: BoxDecoration(
                color: c.haldiContainer,
                borderRadius: BorderRadius.circular(Radii.large),
              ),
              child: Text(
                s.body,
                style: t.titleLarge?.copyWith(color: c.onHaldiContainer),
              ),
            ),
            const SizedBox(height: Space.m),
            Row(
              children: [
                for (final color in [
                  c.ink,
                  c.inkMuted,
                  c.alta,
                  c.haldiStrong,
                  c.durba,
                  c.neel,
                  c.padma,
                ])
                  swatch(color),
              ],
            ),
            const SizedBox(height: Space.s),
            Row(
              children: [
                for (final color in [
                  c.paperRaised,
                  c.altaContainer,
                  c.haldiContainer,
                  c.durbaContainer,
                ])
                  swatch(color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final language in AppLanguage.values) {
    for (final brightness in Brightness.values) {
      testWidgets('type specimen ${language.name} ${brightness.name}', (
        tester,
      ) async {
        tester.view
          ..physicalSize = const Size(400, 640) * 2
          ..devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildPanjikaTheme(brightness, language),
            home: _Specimen(language),
          ),
        );
        await expectLater(
          find.byType(_Specimen),
          matchesGoldenFile(
            'goldens/type_specimen_${language.name}_${brightness.name}.png',
          ),
        );
      });
    }
  }
}
