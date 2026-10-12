// T-107: PanjikaFormatter covers spec §13.3 for both languages × both numeral styles.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/core/l10n/panjika_formatter.dart';
import 'package:panjika/core/time/civil_date.dart';

/// UTC instant for an IST wall-clock time (IST = UTC+05:30).
DateTime ist(int y, int mo, int d, int h, int mi) =>
    DateTime.utc(y, mo, d, h, mi).subtract(Ist.offset);

const bnBn = PanjikaFormatter(
  language: AppLanguage.bn,
  numerals: NumeralStyle.bengali,
);
const bnLatn = PanjikaFormatter(
  language: AppLanguage.bn,
  numerals: NumeralStyle.latin,
);
const enLatn = PanjikaFormatter(
  language: AppLanguage.en,
  numerals: NumeralStyle.latin,
);
const enBn = PanjikaFormatter(
  language: AppLanguage.en,
  numerals: NumeralStyle.bengali,
);
const bn24 = PanjikaFormatter(
  language: AppLanguage.bn,
  numerals: NumeralStyle.bengali,
  timeFormat: TimeFormat.h24,
);
const en24 = PanjikaFormatter(
  language: AppLanguage.en,
  numerals: NumeralStyle.latin,
  timeFormat: TimeFormat.h24,
);

void main() {
  const sampleDay = CivilDate(2026, 10, 12); // a Monday (sample date)

  group('numbers', () {
    test('digit conversion follows the numeral style, not the language', () {
      expect(bnBn.digits('2026'), '২০২৬');
      expect(enBn.digits('2026'), '২০২৬');
      expect(bnLatn.digits('2026'), '2026');
      expect(enLatn.digits('2026'), '2026');
    });

    test('Indian digit grouping', () {
      expect(enLatn.number(0), '0');
      expect(enLatn.number(999), '999');
      expect(enLatn.number(1000), '1,000');
      expect(enLatn.number(108000), '1,08,000');
      expect(enLatn.number(12345678), '1,23,45,678');
      expect(enLatn.number(-108000), '-1,08,000');
      expect(bnBn.number(108000), '১,০৮,০০০');
    });
  });

  group('times (IST, 12-hour)', () {
    test('Bengali uses day-part words', () {
      expect(bnBn.time(ist(2026, 10, 12, 14, 32)), 'দুপুর ২:৩২');
      expect(bnLatn.time(ist(2026, 10, 12, 14, 32)), 'দুপুর 2:32');
    });

    test('English uses AM/PM, in either numeral style', () {
      expect(enLatn.time(ist(2026, 10, 12, 14, 32)), '2:32 PM');
      expect(enLatn.time(ist(2026, 10, 12, 0, 5)), '12:05 AM');
      expect(enLatn.time(ist(2026, 10, 12, 12, 0)), '12:00 PM');
      expect(enBn.time(ist(2026, 10, 12, 14, 32)), '২:৩২ PM');
    });

    test('day-part boundaries (spec §12.4)', () {
      String part(int h, int m) =>
          bnLatn.time(ist(2026, 10, 12, h, m)).split(' ').first;
      expect(part(0, 0), 'রাত');
      expect(part(3, 59), 'রাত');
      expect(part(4, 0), 'ভোর');
      expect(part(5, 59), 'ভোর');
      expect(part(6, 0), 'সকাল');
      expect(part(11, 59), 'সকাল');
      expect(part(12, 0), 'দুপুর');
      expect(part(14, 59), 'দুপুর');
      expect(part(15, 0), 'বিকেল');
      expect(part(17, 29), 'বিকেল');
      expect(part(17, 30), 'সন্ধ্যা');
      expect(part(19, 29), 'সন্ধ্যা');
      expect(part(19, 30), 'রাত');
      expect(part(23, 59), 'রাত');
    });

    test('24-hour clock is zero-padded and has no day part', () {
      expect(bn24.time(ist(2026, 10, 12, 14, 32)), '১৪:৩২');
      expect(en24.time(ist(2026, 10, 12, 9, 5)), '09:05');
    });

    test(
      'IST is used whatever the instant, e.g. UTC late evening is next IST day',
      () {
        final instant = DateTime.utc(
          2026,
          10,
          12,
          20,
          0,
        ); // 01:30 IST on 13 Oct
        expect(enLatn.time(instant), '1:30 AM');
        expect(CivilDate.ofInstant(instant), const CivilDate(2026, 10, 13));
      },
    );
  });

  group('time ranges', () {
    test('shared day part / AM-PM appears once', () {
      final a = ist(2026, 10, 12, 7, 32);
      final b = ist(2026, 10, 12, 9, 0);
      expect(bnBn.timeRange(a, b), 'সকাল ৭:৩২–৯:০০');
      expect(enLatn.timeRange(a, b), '7:32–9:00 AM');
    });

    test('different day parts / AM-PM are both shown', () {
      final a = ist(2026, 10, 12, 11, 30);
      final b = ist(2026, 10, 12, 12, 15);
      expect(bnBn.timeRange(a, b), 'সকাল ১১:৩০–দুপুর ১২:১৫');
      expect(enLatn.timeRange(a, b), '11:30 AM–12:15 PM');
    });

    test('24-hour ranges', () {
      expect(
        en24.timeRange(ist(2026, 10, 12, 7, 32), ist(2026, 10, 12, 9, 0)),
        '07:32–09:00',
      );
    });
  });

  test('isNextDay flags times after midnight in a panjika day', () {
    expect(enLatn.isNextDay(ist(2026, 10, 13, 1, 10), sampleDay), isTrue);
    expect(enLatn.isNextDay(ist(2026, 10, 12, 23, 59), sampleDay), isFalse);
  });

  group('dates', () {
    test('long Gregorian date, day-month-year', () {
      expect(bnBn.gregorianDate(sampleDay), '১২ অক্টোবর ২০২৬');
      expect(enLatn.gregorianDate(sampleDay), '12 October 2026');
      expect(enBn.gregorianDate(sampleDay), '১২ October ২০২৬');
    });

    test('short date with weekday', () {
      expect(bnBn.gregorianDateShort(sampleDay), 'সোম, ১২ অক্টো');
      expect(enLatn.gregorianDateShort(sampleDay), 'Mon, 12 Oct');
      expect(enBn.gregorianDateShort(sampleDay), 'Mon, ১২ Oct');
    });

    test('numeric dates are dd/mm/yyyy', () {
      expect(
        enLatn.gregorianDateNumeric(const CivilDate(2026, 4, 5)),
        '05/04/2026',
      );
      expect(bnBn.gregorianDateNumeric(sampleDay), '১২/১০/২০২৬');
    });

    test('weekday names', () {
      expect(bnBn.weekday(sampleDay), 'সোমবার');
      expect(enLatn.weekday(sampleDay), 'Monday');
      expect(enLatn.weekday(const CivilDate(2026, 10, 18)), 'Sunday');
    });

    test('Bengali date: year is never digit-grouped', () {
      expect(bnBn.bengaliDate(25, 'আশ্বিন', 1433), '২৫ আশ্বিন ১৪৩৩');
      expect(enLatn.bengaliDate(25, 'Ashwin', 1433), '25 Ashwin 1433');
    });

    test('ordinal dates only when enabled and only in Bengali (Q5 flag)', () {
      const bnOrd = PanjikaFormatter(
        language: AppLanguage.bn,
        numerals: NumeralStyle.bengali,
        bnOrdinalDates: true,
      );
      const enOrd = PanjikaFormatter(
        language: AppLanguage.en,
        numerals: NumeralStyle.latin,
        bnOrdinalDates: true,
      );
      expect(bnOrd.bengaliDate(1, 'বৈশাখ', 1433), '১লা বৈশাখ ১৪৩৩');
      expect(bnOrd.bengaliDate(25, 'আশ্বিন', 1433), '২৫শে আশ্বিন ১৪৩৩');
      expect(enOrd.bengaliDate(25, 'Ashwin', 1433), '25 Ashwin 1433');
    });
  });

  test('Bengali ordinal suffixes', () {
    final expected = {
      1: 'লা',
      2: 'রা',
      3: 'রা',
      4: 'ঠা',
      5: 'ই',
      18: 'ই',
      19: 'শে',
      31: 'শে',
      32: 'শে', //
    };
    expected.forEach(
      (day, suffix) => expect(bengaliOrdinalSuffix(day), suffix),
    );
    expect(() => bengaliOrdinalSuffix(0), throwsRangeError);
    expect(() => bengaliOrdinalSuffix(33), throwsRangeError);
  });

  test('count text uses the numeral style', () {
    expect(bnBn.countText(3), '৩');
    expect(enLatn.countText(3), '3');
  });

  group('language resolution (FR-L10N-02, Q15)', () {
    test('saved choice wins', () {
      expect(
        resolveLanguage(
          saved: AppLanguage.en,
          deviceLocales: const [Locale('bn')],
        ),
        AppLanguage.en,
      );
    });

    test('Bengali or English device locale is used', () {
      expect(
        resolveLanguage(deviceLocales: const [Locale('bn', 'IN')]),
        AppLanguage.bn,
      );
      expect(
        resolveLanguage(deviceLocales: const [Locale('en', 'US')]),
        AppLanguage.en,
      );
    });

    test(
      'other primary locales use the Q15 fallback, even with English as backup',
      () {
        expect(
          resolveLanguage(deviceLocales: const [Locale('hi'), Locale('en')]),
          fallbackLanguage,
        );
        expect(resolveLanguage(deviceLocales: const []), fallbackLanguage);
      },
    );

    test('default numerals per language (FR-L10N-04)', () {
      expect(AppLanguage.bn.defaultNumerals, NumeralStyle.bengali);
      expect(AppLanguage.en.defaultNumerals, NumeralStyle.latin);
    });
  });
}
