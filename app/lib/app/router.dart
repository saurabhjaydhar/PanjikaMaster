import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/time/civil_date.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/city/city_picker_screen.dart';
import '../features/day/day_screen.dart';
import '../features/festivals/festivals_screen.dart';
import '../features/more/more_screen.dart';
import '../features/today/today_screen.dart';
import 'shell/app_shell.dart';

abstract final class Routes {
  static const today = '/today';
  static const calendar = '/calendar';
  static const festivals = '/festivals';
  static const more = '/more';

  /// Day detail for a date, e.g. `/day/2026-10-12` (also the share-link form, T-411).
  static String day(CivilDate date) => '/day/${date.toIso()}';

  static const city = '/city';
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
