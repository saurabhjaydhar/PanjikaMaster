import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/observance_widgets.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/settings/settings.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/pack_detail.dart';
import '../../domain/entities/panjika.dart';
import '../../l10n/gen/app_localizations.dart';

/// Every installed pack with its version, dates and validation state (FR-SET-02).
final packDetailsProvider = FutureProvider<List<PackDetail>>(
  (ref) => ref.watch(panjikaRepositoryProvider).packDetails(),
);

/// Sources & verification (তথ্যসূত্র ও যাচাই, spec §11.16, FR-SET-02): which tradition,
/// how the data is computed and checked, what the marks mean, and the version and
/// validation state of every pack on this phone.
class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final names = ref.watch(namesProvider).value;
    final tradition = ref.watch(traditionProvider);
    final packs = ref.watch(packDetailsProvider).value;
    final margin = contentInset(MediaQuery.sizeOf(context).width);
    final muted = t.bodyMedium?.copyWith(color: c.inkMuted);

    final steps = [
      (l.sourcesStep1Title, l.sourcesStep1Body),
      (l.sourcesStep2Title, l.sourcesStep2Body),
      (l.sourcesStep3Title, l.sourcesStep3Body),
      (l.sourcesStep4Title, l.sourcesStep4Body),
    ];

    String kind(String k) => switch (k) {
      'global' => l.packKindGlobal,
      'cities' => l.packKindCities,
      _ => l.packKindObservances,
    };

    Widget pack(PackDetail p) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.sourcesPackTitle(kind(p.kind), f.number(p.version)),
            style: t.bodyLarge,
          ),
          if (names != null)
            Text(
              l.sourcesPackScope(
                names.tradition(p.tradition).of(language),
                l.dataRange(f.gregorianDate(p.from), f.gregorianDate(p.to)),
              ),
              style: muted,
            ),
          Text(
            p.isSample
                ? l.verificationSample
                : p.validatedOn == null
                ? l.sourcesNotValidated
                : l.sourcesValidatedOn(f.gregorianDate(p.validatedOn!)),
            style: muted,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.menuSources)),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(margin, Space.s, margin, Space.xl),
            children: [
              SectionHeader(title: l.sourcesTraditionHeading),
              if (names != null)
                Text(
                  l.sourcesTraditionBody(
                    names.tradition(tradition).of(language),
                  ),
                  style: t.bodyLarge,
                ),
              const SizedBox(height: Space.l),
              SectionHeader(title: l.sourcesHowHeading),
              // A genuine sequence, so numbered (§11.16).
              for (final (i, (title, body)) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: Space.xxl,
                            minHeight: Space.xxl,
                          ),
                          padding: const EdgeInsets.all(Space.xs),
                          decoration: BoxDecoration(
                            color: c.haldiContainer,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            f.number(i + 1),
                            style: t.titleSmall?.copyWith(
                              color: c.onHaldiContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: t.titleSmall),
                            Text(body, style: muted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: Space.s),
                child: Text(l.sourcesStepsNote, style: t.bodyMedium),
              ),
              const SizedBox(height: Space.l),
              SectionHeader(title: l.sourcesMarksHeading),
              for (final status in const [
                VerificationStatus.expertReviewed,
                VerificationStatus.referenceMatched,
                VerificationStatus.computed,
              ])
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Space.minTouch),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _Mark(status),
                  ),
                ),
              const SizedBox(height: Space.l),
              SectionHeader(title: l.sourcesPhoneHeading),
              if (packs != null && packs.isEmpty)
                Text(l.sourcesNoPacks, style: t.bodyLarge),
              for (final p in packs ?? const <PackDetail>[]) pack(p),
              const SizedBox(height: Space.s),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.help_outline, color: c.inkMuted),
                title: Text(l.sourcesWhyLink, style: t.bodyLarge),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.schools),
              ),
              const SizedBox(height: Space.l),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.flag_outlined),
                  label: Text(l.menuReport),
                  onPressed: () => context.push(Routes.report),
                ),
              ),
            ],
          ),
          if (packs?.any((p) => p.isSample) ?? false) const SampleWatermark(),
        ],
      ),
    );
  }
}

/// A verification mark with its meaning, as in the legend of §11.16.
class _Mark extends StatelessWidget {
  const _Mark(this.status);

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        VerificationBadge(status),
        const SizedBox(width: Space.m),
        Expanded(
          child: ExcludeSemantics(
            child: Text(verificationLabel(l, status), style: t.bodyLarge),
          ),
        ),
      ],
    );
  }
}

/// "দুই মত কেন আলাদা?" — a plain-language explainer of Drik vs Surya Siddhanta
/// (spec §11.16, §5.2), about 150 words in each language.
class SchoolsExplainerScreen extends StatelessWidget {
  const SchoolsExplainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final margin = contentInset(MediaQuery.sizeOf(context).width);
    return Scaffold(
      appBar: AppBar(title: Text(l.sourcesWhyLink)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(margin, Space.l, margin, Space.xl),
        children: [
          for (final p in [l.schoolsPara1, l.schoolsPara2, l.schoolsPara3])
            Padding(
              padding: const EdgeInsets.only(bottom: Space.l),
              child: Text(p, style: t.bodyLarge),
            ),
        ],
      ),
    );
  }
}
