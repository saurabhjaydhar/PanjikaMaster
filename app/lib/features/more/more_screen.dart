import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/language_switch.dart';
import '../../app/widgets/name_text.dart';
import '../../l10n/gen/app_localizations.dart';
import '../city/city_providers.dart';

/// More (আরও, spec §10): a quick language switch at the top, because a shared family
/// phone often changes hands, then every other destination.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final city = ref.watch(cityNameProvider).value;
    final margin = contentInset(MediaQuery.sizeOf(context).width);

    Widget entry(
      IconData icon,
      String title,
      String route, {
      Widget? subtitle,
    }) => ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: margin),
      leading: Icon(icon, color: c.inkMuted),
      title: Text(title, style: t.bodyLarge),
      subtitle: subtitle,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(margin, Space.l, margin, Space.m),
              child: Semantics(
                header: true,
                child: Text(l.moreTitle, style: t.headlineSmall),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: margin),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Space.m,
                runSpacing: Space.s,
                children: [
                  Text(l.languageSetting, style: t.bodyLarge),
                  const LanguageSwitch(),
                ],
              ),
            ),
            const SizedBox(height: Space.m),
            Divider(indent: margin, endIndent: margin),
            entry(
              Icons.notifications_outlined,
              l.menuReminders,
              Routes.reminders,
            ),
            entry(Icons.search, l.menuSearch, Routes.search),
            entry(
              Icons.location_city_outlined,
              l.menuCity,
              Routes.city,
              subtitle: city == null
                  ? null
                  : NameText(
                      city,
                      style: t.bodyMedium?.copyWith(color: c.inkMuted),
                    ),
            ),
            entry(Icons.menu_book_outlined, l.menuGlossary, Routes.glossary),
            entry(Icons.settings_outlined, l.menuSettings, Routes.settings),
            Divider(indent: margin, endIndent: margin),
            entry(Icons.verified_outlined, l.menuSources, Routes.sources),
            entry(Icons.flag_outlined, l.menuReport, Routes.report),
            entry(Icons.help_outline, l.menuHelp, Routes.help),
            Divider(indent: margin, endIndent: margin),
            entry(
              Icons.do_not_disturb_on_outlined,
              l.menuRemoveAds,
              Routes.removeAds,
            ),
            entry(Icons.info_outline, l.menuAbout, Routes.about),
            entry(Icons.privacy_tip_outlined, l.menuPrivacy, Routes.privacy),
            const SizedBox(height: Space.xl),
          ],
        ),
      ),
    );
  }
}
