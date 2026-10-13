import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../data/notifications/notification_permission.dart';
import '../../l10n/gen/app_localizations.dart';

/// Shown when notifications are refused: why reminders won't appear and a way to the
/// app's settings (US-03, spec §11.13).
class NotificationsOffNote extends ConsumerWidget {
  const NotificationsOffNote({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(Space.l, Space.m, Space.l, Space.xs),
        decoration: BoxDecoration(
          color: c.altaContainer,
          borderRadius: BorderRadius.circular(Radii.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(Icons.notifications_off_outlined, color: c.ink),
                ),
                const SizedBox(width: Space.m),
                Expanded(child: Text(l.notificationsOff, style: t.bodyMedium)),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: ref
                    .read(notificationPermissionProvider)
                    .openSettings,
                child: Text(l.actionOpenSettings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
