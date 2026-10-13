import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import 'app_version.dart';

/// About (সম্পর্কে): what the app is, its version, where the data comes from, and the
/// licences (spec §11.15, §19.1).
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final f = ref.watch(formatterProvider);
    final version = ref.watch(appVersionProvider).value;
    final margin = screenMargin(MediaQuery.sizeOf(context).width);

    Widget link(IconData icon, String title, VoidCallback onTap) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c.inkMuted),
      title: Text(title, style: t.bodyLarge),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.menuAbout)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(margin, Space.l, margin, Space.xl),
        children: [
          Text(l.appTitle, style: t.headlineMedium),
          if (version != null) ...[
            const SizedBox(height: Space.xs),
            Text(
              l.aboutVersion(f.digits(version)),
              style: t.bodyMedium?.copyWith(color: c.inkMuted),
            ),
          ],
          const SizedBox(height: Space.l),
          Text(l.aboutTagline, style: t.bodyLarge),
          const SizedBox(height: Space.xl),
          SectionHeader(title: l.aboutDataHeading),
          Text(l.aboutDataBody, style: t.bodyLarge),
          const SizedBox(height: Space.m),
          Text(l.aboutProvenance, style: t.bodyLarge),
          const SizedBox(height: Space.l),
          link(
            Icons.verified_outlined,
            l.menuSources,
            () => context.push(Routes.sources),
          ),
          link(
            Icons.privacy_tip_outlined,
            l.menuPrivacy,
            () => context.push(Routes.privacy),
          ),
          link(
            Icons.description_outlined,
            l.licences,
            () => showLicensePage(
              context: context,
              applicationName: l.appTitle,
              applicationVersion: version == null ? null : f.digits(version),
            ),
          ),
        ],
      ),
    );
  }
}
