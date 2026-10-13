import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/settings.dart';
import '../core/time/civil_date.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/city/city_picker_screen.dart';
import '../features/day/day_screen.dart';
import '../features/festivals/festival_detail_screen.dart';
import '../features/festivals/festivals_screen.dart';
import '../features/more/about_screen.dart';
import '../features/more/coming_soon_screen.dart';
import '../features/more/more_screen.dart';
import '../features/glossary/glossary_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/reminders/reminders_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/sources/sources_screen.dart';
import '../features/today/today_screen.dart';
import '../l10n/gen/app_localizations.dart';
import 'shell/app_shell.dart';
import 'shell/not_found_screen.dart';

abstract final class Routes {
  static const today = '/today';
  static const calendar = '/calendar';
  static const festivals = '/festivals';
  static const more = '/more';

  /// Day detail for a date, e.g. `/day/2026-10-12` (also the share-link form, T-411).
  static String day(CivilDate date) => '/day/${date.toIso()}';

  /// A festival, e.g. `/festival/durga_puja` (share links, T-411).
  static String festival(String id, {CivilDate? date}) =>
      date == null ? '/festival/$id' : '/festival/$id?date=${date.toIso()}';

  /// Observance ids as the packs write them.
  static final festivalId = RegExp(r'^[a-z0-9_]{1,64}$');

  static const onboarding = '/onboarding';
  static const city = '/city';
  static const settings = '/settings';

  // More destinations (spec §10).
  static const reminders = '/reminders';
  static const search = '/search';
  static const glossary = '/glossary';
  static const sources = '/sources';
  static const schools = '/sources/schools';
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
    // An unknown address (a mistyped or newer link) says so instead of crashing.
    errorBuilder: (_, _) => const NotFoundScreen(),
    // First run goes through onboarding; a link that launched the app is kept and
    // opened afterwards (spec §10).
    redirect: (_, state) {
      final done = ref.read(onboardingDoneProvider);
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!done && !atOnboarding) {
        final next = state.uri.toString();
        return next == Routes.today
            ? Routes.onboarding
            : Uri(
                path: Routes.onboarding,
                queryParameters: {'next': next},
              ).toString();
      }
      if (done && atOnboarding) return Routes.today;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, state) {
          final next = state.uri.queryParameters['next'];
          // Only an in-app path, never a full URL.
          return OnboardingScreen(
            next: next != null && next.startsWith('/') && !next.startsWith('//')
                ? next
                : null,
          );
        },
      ),
      // Above the tabs, so Back returns to whichever tab opened it.
      GoRoute(
        path: '/day/:date',
        builder: (_, state) {
          final date = CivilDate.tryParse(state.pathParameters['date']!);
          return date == null ? const NotFoundScreen() : DayScreen(date: date);
        },
      ),
      GoRoute(
        path: '/festival/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final date = state.uri.queryParameters['date'];
          return Routes.festivalId.hasMatch(id)
              ? FestivalDetailScreen(
                  id: id,
                  date: date == null ? null : CivilDate.tryParse(date),
                )
              : const NotFoundScreen();
        },
      ),
      GoRoute(path: Routes.city, builder: (_, _) => const CityPickerScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: Routes.about, builder: (_, _) => const AboutScreen()),
      GoRoute(path: Routes.search, builder: (_, _) => const SearchScreen()),
      GoRoute(path: Routes.glossary, builder: (_, _) => const GlossaryScreen()),
      GoRoute(path: Routes.sources, builder: (_, _) => const SourcesScreen()),
      GoRoute(
        path: Routes.schools,
        builder: (_, _) => const SchoolsExplainerScreen(),
      ),
      GoRoute(
        path: Routes.reminders,
        builder: (_, _) => const RemindersScreen(),
      ),
      // Screens built by later tasks; until then each says "coming soon".
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
