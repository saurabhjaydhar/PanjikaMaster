import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../router.dart';
import '../widgets/panjika_widgets.dart';

/// A link or address the app doesn't know: say so, and offer Today (T-411).
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.message});

  /// Defaults to "This page couldn't be found".
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: StateMessage(
        message: message ?? l.linkNotFound,
        actionLabel: l.goToToday,
        onAction: () => context.go(Routes.today),
      ),
    );
  }
}
