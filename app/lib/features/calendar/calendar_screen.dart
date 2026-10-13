import 'package:flutter/material.dart';

import '../../app/shell/placeholder_screen.dart';
import '../../l10n/gen/app_localizations.dart';

/// Placeholder until its task builds the real screen (see docs/phases/).
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: AppLocalizations.of(context).navCalendar);
}
