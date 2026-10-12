import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../theme/tokens.dart';

/// Stand-in body for tabs whose screens arrive in later tasks (Phase 1 only).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.headlineSmall),
              const SizedBox(height: Space.s),
              Text(AppLocalizations.of(context).comingSoon, style: t.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
