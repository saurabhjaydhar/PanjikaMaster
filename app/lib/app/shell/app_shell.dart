import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';

/// The four-tab frame (spec §10): আজ · পঞ্জিকা · পার্বণ · আরও. Labels are always visible
/// and come from the UI language. Each tab keeps its own navigation stack.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _go(int index) => navigationShell.goBranch(
    index,
    // Tapping the current tab again returns to its first screen.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final onToday = navigationShell.currentIndex == 0;
    final destinations = [
      (
        icon: const Icon(Icons.brightness_5_outlined),
        selectedIcon: const Icon(Icons.brightness_5),
        label: l.navToday,
      ),
      (
        icon: const Icon(Icons.calendar_month_outlined),
        selectedIcon: const Icon(Icons.calendar_month),
        label: l.navCalendar,
      ),
      (
        icon: const Icon(Icons.local_florist_outlined),
        selectedIcon: const Icon(Icons.local_florist),
        label: l.navFestivals,
      ),
      (
        icon: const Icon(Icons.more_horiz),
        selectedIcon: const Icon(Icons.more_horiz),
        label: l.navMore,
      ),
    ];
    // Predictive back (spec §12.10): from another tab, back goes to Today; from Today it
    // leaves the app. The system shows the right back preview because canPop is accurate.
    return PopScope(
      canPop: onToday,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(0);
      },
      child: isShortLandscape(context)
          ? Scaffold(
              // A landscape phone is short: the tabs move to a rail at the side so
              // the content keeps its height (§12.10). Labels stay visible (§10).
              body: SafeArea(
                right: false,
                child: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: _go,
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final d in destinations)
                          NavigationRailDestination(
                            icon: d.icon,
                            selectedIcon: d.selectedIcon,
                            label: Text(d.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: navigationShell),
                  ],
                ),
              ),
            )
          : Scaffold(
              body: navigationShell,
              bottomNavigationBar: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _go,
                destinations: [
                  for (final d in destinations)
                    NavigationDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: d.label,
                    ),
                ],
              ),
            ),
    );
  }
}
