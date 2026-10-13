import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'panjika_widgets.dart';

/// The data states of spec §11.9 and §16.
enum SystemState {
  notDownloaded,
  offline,
  stale,
  signatureFailed,
  unverified,
  checkClock,
}

/// A full-screen state with its copy, icon and (when a handler is given) its action.
class SystemStateMessage extends StatelessWidget {
  const SystemStateMessage(this.state, {super.key, this.onAction});

  final SystemState state;

  /// Download, update or try again, depending on [state]. Without it, no button.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (kind, message, action) = switch (state) {
      SystemState.notDownloaded => (
        StateKind.notDownloaded,
        l.stateNotDownloaded,
        l.actionDownload,
      ),
      SystemState.offline => (StateKind.offline, l.stateOffline, null),
      SystemState.stale => (StateKind.stale, l.stateStale, l.actionUpdate),
      SystemState.signatureFailed => (
        StateKind.signatureFailed,
        l.stateSignatureFailed,
        l.retry,
      ),
      SystemState.unverified => (StateKind.noData, l.stateUnverified, null),
      SystemState.checkClock => (StateKind.checkClock, l.stateCheckClock, null),
    };
    return StateMessage(
      kind: kind,
      message: message,
      actionLabel: onAction == null ? null : action,
      onAction: onAction,
    );
  }
}

/// Amber "this data needs an update" banner above content that is still shown
/// (spec §6.8 `stale`).
class StaleBanner extends StatelessWidget {
  const StaleBanner({super.key, this.onUpdate});

  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Space.l,
          vertical: Space.s,
        ),
        decoration: BoxDecoration(
          color: c.haldiContainer,
          borderRadius: BorderRadius.circular(Radii.medium),
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(StateKind.stale.icon, color: c.onHaldiContainer),
            ),
            const SizedBox(width: Space.s),
            Expanded(
              child: Text(
                l.stateStale,
                style: t.bodyMedium?.copyWith(color: c.onHaldiContainer),
              ),
            ),
            if (onUpdate != null) ...[
              const SizedBox(width: Space.s),
              TextButton(onPressed: onUpdate, child: Text(l.actionUpdate)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline note on a tier-2/3 festival not yet checked against the panjika (§11.9).
class UnverifiedNote extends StatelessWidget {
  const UnverifiedNote({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(Icons.info_outline, size: 18, color: c.inkMuted),
        ),
        const SizedBox(width: Space.s),
        Expanded(
          child: Text(
            l.stateUnverified,
            style: t.bodySmall?.copyWith(color: c.inkMuted),
          ),
        ),
      ],
    );
  }
}
