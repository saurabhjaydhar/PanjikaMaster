import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/observance_widgets.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/l10n/app_language.dart';
import '../../core/time/civil_date.dart';
import '../../domain/engine/day_assembler.dart';
import '../../domain/entities/name_ref.dart';
import '../../domain/entities/name_table.dart';
import '../../domain/entities/panjika.dart';
import '../../l10n/gen/app_localizations.dart';
import 'alpona_motif.dart';
import 'share_render.dart';
import 'share_text.dart';

/// What a festival card shows (spec §11.8): the name, the date in both calendars and
/// the provenance.
class FestivalShareData {
  const FestivalShareData({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.bengaliDate,
    required this.names,
    required this.tradition,
    required this.isSample,
  });

  final String id;
  final NameRef name;
  final ObservanceCategory category;
  final CivilDate date;
  final BengaliDate? bengaliDate;
  final NameTable names;
  final NameRef tradition;
  final bool isSample;

  String get path => '/festival/$id?date=${date.toIso()}';

  /// "রবিবার, ২১ কার্তিক ১৪৩৩"-style date in [a] (Bengali date where installed).
  String bengaliLine(AppLanguage a) {
    final f = formatterFor(a);
    final bn = bengaliDate;
    if (bn == null) return f.weekday(date);
    final l = lookupAppLocalizations(a.locale);
    return l.festivalRowDates(
      f.weekday(date),
      f.bengaliDate(
        bn.day,
        names.of('solar_month', bn.monthIdx).of(a),
        bn.year,
      ),
    );
  }

  String message(ShareLanguage share, {String? link}) => shareMessage(
    share,
    line: (l, f, a) => l.shareFestivalMessage(
      name.of(a),
      '${bengaliLine(a)}, ${f.gregorianDate(date)}',
    ),
    provenance: (l, a) => provenanceLine(l, a, tradition),
    link: link,
  );
}

/// What a day card shows: the date, the tithi with its end time, the first
/// observance, and provenance with the city and time zone.
class DayShareData {
  const DayShareData({required this.day, required this.names});

  final DayPanjika day;
  final NameTable names;

  String get path => '/day/${day.date.toIso()}';

  String dateLine(AppLanguage a) {
    final bn = day.bengaliDate;
    return formatterFor(a).bengaliDate(bn.day, day.bengaliMonth.of(a), bn.year);
  }

  String tithiLine(AppLanguage a) {
    final l = lookupAppLocalizations(a.locale);
    final f = formatterFor(a);
    return l.nameWithUntil(
      day.udayaTithi.name.of(a),
      l.untilTime(f.time(day.udayaTithi.endUtc)),
    );
  }

  String provenance(AppLocalizations l, AppLanguage a) =>
      l.shareProvenanceWithPlace(
        day.provenance.tradition.of(a),
        day.provenance.city.of(a),
        l.timeZoneLabel,
      );

  String message(ShareLanguage share, {String? link}) => shareMessage(
    share,
    line: (l, f, a) => l.shareDayMessage(
      '${dateLine(a)}, ${f.gregorianDate(day.date)}',
      tithiLine(a),
    ),
    provenance: provenance,
    link: link,
  );
}

/// Festival card: motif, the name as the hero (with the English name below for
/// "both"), the date in both calendars, provenance and the app name.
class FestivalShareCard extends StatelessWidget {
  const FestivalShareCard({super.key, required this.data, required this.share});

  final FestivalShareData data;
  final ShareLanguage share;

  @override
  Widget build(BuildContext context) {
    final a = share.primary;
    final l = lookupAppLocalizations(a.locale);
    final f = formatterFor(a);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    return _CardScaffold(
      isSample: data.isSample,
      footer: [
        if (share == ShareLanguage.both) ...[
          _locale(
            provenanceLine(
              lookupAppLocalizations(AppLanguage.bn.locale),
              AppLanguage.bn,
              data.tradition,
            ),
            AppLanguage.bn,
            t.bodyMedium,
          ),
          _locale(
            provenanceLine(
              lookupAppLocalizations(AppLanguage.en.locale),
              AppLanguage.en,
              data.tradition,
            ),
            AppLanguage.en,
            t.bodyMedium,
          ),
        ] else
          Text(provenanceLine(l, a, data.tradition), style: t.bodyMedium),
        Text(l.appTitle, style: t.labelLarge?.copyWith(color: c.inkMuted)),
      ],
      children: [
        const AlponaMotif(size: 112),
        const SizedBox(height: Space.l),
        Container(
          width: Space.xxxl,
          height: Space.xs,
          decoration: BoxDecoration(
            color: categoryColor(c, data.category),
            borderRadius: BorderRadius.circular(Space.xs),
          ),
        ),
        const SizedBox(height: Space.m),
        Text(
          data.name.of(a),
          style: t.displaySmall,
          textAlign: TextAlign.center,
        ),
        if (share == ShareLanguage.both)
          _locale(
            data.name.en,
            AppLanguage.en,
            t.titleLarge?.copyWith(color: c.inkMuted),
          ),
        const SizedBox(height: Space.l),
        Text(
          data.bengaliLine(a),
          style: t.titleMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          f.gregorianDate(data.date),
          style: t.bodyLarge?.copyWith(color: c.inkMuted),
          textAlign: TextAlign.center,
        ),
        if (share == ShareLanguage.both)
          _locale(
            formatterFor(AppLanguage.en).gregorianDate(data.date),
            AppLanguage.en,
            t.bodyLarge?.copyWith(color: c.inkMuted),
          ),
      ],
    );
  }
}

/// Day card: the Bengali date as the hero, the Gregorian date, the tithi with its
/// end time and the first observance.
class DayShareCard extends StatelessWidget {
  const DayShareCard({super.key, required this.data, required this.share});

  final DayShareData data;
  final ShareLanguage share;

  @override
  Widget build(BuildContext context) {
    final a = share.primary;
    final l = lookupAppLocalizations(a.locale);
    final f = formatterFor(a);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final day = data.day;
    final festival = day.observances.firstOrNull;
    return _CardScaffold(
      isSample: day.provenance.isSample,
      footer: [
        if (share == ShareLanguage.both) ...[
          _locale(
            data.provenance(
              lookupAppLocalizations(AppLanguage.bn.locale),
              AppLanguage.bn,
            ),
            AppLanguage.bn,
            t.bodyMedium,
          ),
          _locale(
            data.provenance(
              lookupAppLocalizations(AppLanguage.en.locale),
              AppLanguage.en,
            ),
            AppLanguage.en,
            t.bodyMedium,
          ),
        ] else
          Text(
            data.provenance(l, a),
            style: t.bodyMedium,
            textAlign: TextAlign.center,
          ),
        Text(l.appTitle, style: t.labelLarge?.copyWith(color: c.inkMuted)),
      ],
      children: [
        const AlponaMotif(size: 72),
        const SizedBox(height: Space.m),
        Text(
          f.weekday(day.date),
          style: t.titleMedium?.copyWith(color: c.inkMuted),
        ),
        Text(
          data.dateLine(a),
          style: t.displaySmall,
          textAlign: TextAlign.center,
        ),
        Text(
          f.gregorianDate(day.date),
          style: t.bodyLarge?.copyWith(color: c.inkMuted),
        ),
        if (share == ShareLanguage.both)
          _locale(
            data.dateLine(AppLanguage.en),
            AppLanguage.en,
            t.bodyLarge?.copyWith(color: c.inkMuted),
          ),
        const SizedBox(height: Space.l),
        Container(
          padding: const EdgeInsets.all(Space.m),
          decoration: BoxDecoration(
            color: c.haldiContainer,
            borderRadius: BorderRadius.circular(Radii.medium),
          ),
          child: Column(
            children: [
              Text(
                data.tithiLine(a),
                style: t.titleMedium?.copyWith(color: c.onHaldiContainer),
                textAlign: TextAlign.center,
              ),
              if (share == ShareLanguage.both)
                _locale(
                  data.tithiLine(AppLanguage.en),
                  AppLanguage.en,
                  t.bodyMedium?.copyWith(color: c.onHaldiContainer),
                ),
            ],
          ),
        ),
        if (festival != null) ...[
          const SizedBox(height: Space.m),
          Text(
            festival.observance.name.of(a),
            style: t.titleLarge?.copyWith(
              color: categoryColor(c, festival.observance.category),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// [text] tagged with [a]'s locale (a second-language line on a "both" card).
Widget _locale(String text, AppLanguage a, TextStyle? style) =>
    Text(text, locale: a.locale, style: style, textAlign: TextAlign.center);

class _CardScaffold extends StatelessWidget {
  const _CardScaffold({
    required this.children,
    required this.footer,
    required this.isSample,
  });

  final List<Widget> children;
  final List<Widget> footer;
  final bool isSample;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ColoredBox(
      color: c.paper,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(Space.xl),
              child: Column(
                children: [
                  // A fixed canvas: content that would not fit shrinks instead of
                  // overflowing (the longest names, the "both" layouts).
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: shareCardCanvas.width - 2 * Space.xl,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: children,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(color: c.rule),
                  const SizedBox(height: Space.s),
                  ...footer,
                ],
              ),
            ),
          ),
          if (isSample) const SampleWatermark(),
        ],
      ),
    );
  }
}
