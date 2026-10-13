import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/time/civil_date.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/city/city_picker_screen.dart';
import '../features/day/day_screen.dart';
import '../features/festivals/festivals_screen.dart';
import '../features/more/about_screen.dart';
import '../features/more/coming_soon_screen.dart';
import '../features/more/more_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/today/today_screen.dart';
import '../l10n/gen/app_localizations.dart';
import 'shell/app_shell.dart';

abstract final class Routes {
  static const today = '/today';
  static const calendar = '/calendar';
  static const festivals = '/festivals';
  static const more = '/more';

  /// Day detail for a date, e.g. `/day/2026-10-12` (also the share-link form, T-411).
  static String day(CivilDate date) => '/day/${date.toIso()}';

  static const city = '/city';
  static const settings = '/settings';

  // More destinations (spec §10).
  static const reminders = '/reminders';
  static const search = '/search';
  static const glossary = '/glossary';
  static const sources = '/sources';
  static const report = '/report';
  static const removeAds = '/remove-ads';
  static const about = '/about';
  static const privacy = '/privacy';
}

/// One router for the app's lifetime, so a language or theme change never resets
/// navigation (FR-SET-05).
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.today,
    routes: [
      // Above the tabs, so Back returns to whichever tab opened it.
      GoRoute(
        path: '/day/:date',
        builder: (_, state) {
          final date = CivilDate.tryParse(state.pathParameters['date']!);
          return date == null ? const TodayScreen() : DayScreen(date: date);
        },
      ),
      GoRoute(path: Routes.city, builder: (_, _) => const CityPickerScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: Routes.about, builder: (_, _) => const AboutScreen()),
      // Screens built by later tasks; until then each says "coming soon".
      _comingSoon(Routes.reminders, (l) => l.menuReminders), // TODO(T-512)
      _comingSoon(Routes.search, (l) => l.menuSearch), // TODO(T-611)
      _comingSoon(Routes.glossary, (l) => l.menuGlossary), // TODO(T-612)
      _comingSoon(Routes.sources, (l) => l.menuSources), // TODO(T-609)
      _comingSoon(Routes.report, (l) => l.menuReport), // TODO(T-610), TODO(Q6)
      _comingSoon(Routes.removeAds, (l) => l.menuRemoveAds), // TODO(T-705)
      // The policy depends on what the app collects. TODO(Q8), TODO(T-706)
      _comingSoon(Routes.privacy, (l) => l.menuPrivacy),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                builder: (_, _) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.calendar,
                builder: (_, _) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.festivals,
                builder: (_, _) => const FestivalsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.more, builder: (_, _) => const MoreScreen()),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

GoRoute _comingSoon(String path, String Function(AppLocalizations) title) =>
    GoRoute(
      path: path,
      builder: (context, _) =>
          ComingSoonScreen(title: title(AppLocalizations.of(context))),
    );
