import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/name_text.dart';
import '../../core/l10n/app_language.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/settings/settings.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/terms.dart';
import '../../l10n/gen/app_localizations.dart';
import '../city/city_providers.dart';
import '../city/use_location_button.dart';
import '../settings/tradition.dart';

/// First run (spec §10, §11.1): language → tradition → city → reminders (optional).
/// Each choice is saved as it is made; finishing marks onboarding done and opens
/// [next] (Today, or the link that launched the app).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.next});

  final String? next;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _steps = 4;
  int _step = 0;

  void _back() => setState(() => _step--);

  Future<void> _continue() async {
    if (_step == 0) {
      // Confirms the language even when the device default was kept (FR-L10N-02).
      await ref
          .read(appLanguageProvider.notifier)
          .select(ref.read(appLanguageProvider));
    }
    if (!mounted) return;
    setState(() => _step++);
  }

  Future<void> _finish({required bool reminders}) async {
    await ref.read(remindersOptInProvider.notifier).set(reminders);
    await ref.read(onboardingDoneProvider.notifier).set(true);
    if (!mounted) return;
    context.go(widget.next ?? Routes.today);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final margin = screenMargin(MediaQuery.sizeOf(context).width);
    final body = switch (_step) {
      0 => const _LanguageStep(),
      1 => const _TraditionStep(),
      2 => const _CityStep(),
      _ => const _RemindersStep(),
    };
    final actions = _step == _steps - 1
        ? [
            FilledButton(
              onPressed: () => _finish(reminders: true),
              child: Text(l.onboardingRemindersYes),
            ),
            const SizedBox(height: Space.s),
            TextButton(
              onPressed: () => _finish(reminders: false),
              child: Text(l.onboardingRemindersNo),
            ),
          ]
        : [
            FilledButton(
              onPressed: _continue,
              child: _step == 0
                  ? _bilingualText((l) => l.actionContinue)
                  : Text(l.actionContinue),
            ),
          ];

    return PopScope(
      // System Back walks back through the steps; on the first step it leaves the app.
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Space.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: Space.minTouch,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_step > 0)
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: BackButton(onPressed: _back),
                          ),
                        _ProgressDots(step: _step, total: _steps),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: context.motion(Motion.standard),
                      switchInCurve: Motion.emphasisedDecelerate,
                      child: KeyedSubtree(key: ValueKey(_step), child: body),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      margin,
                      Space.s,
                      margin,
                      Space.l,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: actions,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [message] in Bengali, then English, on one line (the first step's button): the user
/// hasn't chosen a language yet (spec §11.1). Each half is tagged with its locale so a
/// screen reader uses the right voice for it (FR-L10N-08).
Widget _bilingualText(String Function(AppLocalizations) message) {
  final bn = lookupAppLocalizations(AppLanguage.bn.locale);
  final en = lookupAppLocalizations(AppLanguage.en.locale);
  final first = message(bn), second = message(en);
  final whole = bn.bothLanguages(first, second);
  final i = whole.indexOf(first);
  final j = whole.indexOf(second, i + first.length);
  return Text.rich(
    TextSpan(
      children: [
        TextSpan(text: whole.substring(0, i)),
        TextSpan(text: first, locale: AppLanguage.bn.locale),
        TextSpan(text: whole.substring(i + first.length, j)),
        TextSpan(text: second, locale: AppLanguage.en.locale),
        TextSpan(text: whole.substring(j + second.length)),
      ],
    ),
  );
}

class _ProgressDots extends ConsumerWidget {
  const _ProgressDots({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(formatterProvider);
    final c = context.colors;
    return Semantics(
      label: AppLocalizations.of(context)
          .onboardingStep(f.number(step + 1), f.number(total)),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < total; i++)
              AnimatedContainer(
                duration: context.motion(Motion.micro),
                margin: const EdgeInsets.symmetric(horizontal: Space.xs),
                width: i == step ? Space.l : Space.s,
                height: Space.s,
                decoration: BoxDecoration(
                  color: i <= step ? c.haldiStrong : c.rule,
                  borderRadius: BorderRadius.circular(Space.xs),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

typedef _Message = String Function(AppLocalizations);

/// A step: heading, choices, and a note under them, scrolling as one. The first
/// step shows its heading and note in both languages, one line each, each tagged with
/// its locale so a screen reader uses the right voice (spec §11.1).
class _StepLayout extends StatelessWidget {
  const _StepLayout({
    required this.title,
    required this.children,
    this.note,
    this.header,
    this.bothLanguages = false,
  });

  final Widget? header;
  final _Message title;
  final List<Widget> children;
  final _Message? note;
  final bool bothLanguages;

  Widget _text(BuildContext context, _Message message, TextStyle? style) {
    if (!bothLanguages) {
      return Text(message(AppLocalizations.of(context)), style: style);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final language in AppLanguage.values)
          Text(
            message(lookupAppLocalizations(language.locale)),
            locale: language.locale,
            style: style,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final margin = screenMargin(MediaQuery.sizeOf(context).width);
    return ListView(
      padding: EdgeInsets.fromLTRB(margin, Space.l, margin, Space.l),
      children: [
        ?header,
        Semantics(header: true, child: _text(context, title, t.headlineSmall)),
        const SizedBox(height: Space.l),
        ...children,
        if (note != null) ...[
          const SizedBox(height: Space.l),
          _text(
            context,
            note!,
            t.bodyMedium?.copyWith(color: context.colors.inkMuted),
          ),
        ],
      ],
    );
  }
}

/// A selectable card: radio, title, optional lines below.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.selected,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final bool selected;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(Radii.medium);
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.m),
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: Material(
          color: selected ? c.haldiContainer : c.paperRaised,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: selected ? c.haldiStrong : c.rule,
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(Space.l),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected
                          ? c.haldiStrong
                          : (onTap == null ? c.rule : c.inkMuted),
                    ),
                  ),
                  const SizedBox(width: Space.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        if (subtitle != null) ...[
                          const SizedBox(height: Space.xs),
                          subtitle!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final current = ref.watch(appLanguageProvider);
    // How names look in each language: a name from the pack, not today's data
    // (a datum would need its provenance).
    final tithi = ref.watch(namesProvider).value?.of('tithi', 6);
    final bn = lookupAppLocalizations(AppLanguage.bn.locale);
    final en = lookupAppLocalizations(AppLanguage.en.locale);

    return _StepLayout(
      header: Padding(
        padding: const EdgeInsets.only(bottom: Space.xl),
        child: Column(
          children: [
            Text(
              bn.appTitle,
              locale: AppLanguage.bn.locale,
              style: t.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              en.appTitle,
              locale: AppLanguage.en.locale,
              style: t.titleMedium?.copyWith(color: c.inkMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bothLanguages: true,
      title: (l) => l.onboardingChooseLanguage,
      note: (l) => l.onboardingChangeLater,
      children: [
        for (final language in AppLanguage.values)
          _OptionCard(
            selected: language == current,
            onTap: () =>
                ref.read(appLanguageProvider.notifier).select(language),
            // Each option in its own script (spec §11.1).
            title: Text(
              language.endonym,
              locale: language.locale,
              style: t.titleMedium,
            ),
            subtitle: tithi == null
                ? null
                : Text(
                    lookupAppLocalizations(language.locale)
                        .onboardingLanguagePreview(tithi.of(language)),
                    locale: language.locale,
                    style: t.bodyMedium?.copyWith(color: c.inkMuted),
                  ),
          ),
      ],
    );
  }
}

/// The glossary entry that explains each tradition in two sentences (US-02).
const _traditionTerms = {
  'drik_bishuddha': Term.bishuddhaSiddhanta,
  'surya_siddhanta': Term.suryaSiddhanta,
};

class _TraditionStep extends ConsumerWidget {
  const _TraditionStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final language = ref.watch(appLanguageProvider);
    final names = ref.watch(namesProvider).value;
    final current = ref.watch(traditionProvider);
    final available = ref.watch(availableTraditionsProvider);
    return _StepLayout(
      title: (l) => l.onboardingTraditionTitle,
      note: (l) => l.onboardingTraditionNote,
      children: [
        if (names != null)
          for (final id in names.traditionIds)
            _OptionCard(
              selected: id == current,
              // Only traditions the app can compute; others say "coming soon" (T-410).
              onTap: available.contains(id)
                  ? () => ref.read(traditionChangerProvider)(id)
                  : null,
              title: Text(
                names.tradition(id).of(language),
                style: t.titleMedium?.copyWith(
                  color: available.contains(id) ? null : c.inkMuted,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!available.contains(id))
                    Text(
                      l.comingSoon,
                      style: t.labelLarge?.copyWith(color: c.alta),
                    ),
                  if (names.glossOf('term', _traditionTerms[id]?.index ?? -1)
                      case final gloss?)
                    Text(
                      gloss.of(language),
                      style: t.bodyMedium?.copyWith(color: c.inkMuted),
                    ),
                ],
              ),
            ),
      ],
    );
  }
}

class _CityStep extends ConsumerStatefulWidget {
  const _CityStep();

  @override
  ConsumerState<_CityStep> createState() => _CityStepState();
}

class _CityStepState extends ConsumerState<_CityStep> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final language = ref.watch(appLanguageProvider);
    final current = ref.watch(cityIdProvider);
    final rows = ref.watch(cityRowsProvider).value ?? const <CityRowData>[];
    final searching = _query.trim().isNotEmpty;
    // Popular cities first; a search looks through all of them.
    final shown = [
      for (final r in rows)
        if (searching
            ? r.matches(_query)
            : (r.city.popular || r.city.id == current))
          r,
    ];
    return _StepLayout(
      title: (l) => l.onboardingCityTitle,
      note: (l) => l.onboardingCityNote,
      children: [
        UseLocationButton(onChosen: (id) => chooseCity(ref, id)),
        const SizedBox(height: Space.m),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l.citySearchHint,
            border: const OutlineInputBorder(),
          ),
          onChanged: (q) => setState(() => _query = q),
        ),
        const SizedBox(height: Space.l),
        if (searching && shown.isEmpty)
          Text(l.noCityMatches, style: t.bodyLarge),
        for (final r in shown)
          _OptionCard(
            selected: r.city.id == current,
            onTap: () => chooseCity(ref, r.city.id),
            title: NameText(r.city.name, style: t.titleMedium),
            subtitle: Text(
              r.city.district.of(language),
              style: t.bodyMedium?.copyWith(color: c.inkMuted),
            ),
          ),
      ],
    );
  }
}

class _RemindersStep extends StatelessWidget {
  const _RemindersStep();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return _StepLayout(
      title: (l) => l.onboardingRemindersTitle,
      children: [
        Icon(
          Icons.notifications_active_outlined,
          size: Space.xxxl,
          color: context.colors.haldiStrong,
        ),
        const SizedBox(height: Space.l),
        Text(l.onboardingRemindersBody, style: t.bodyLarge),
      ],
    );
  }
}
