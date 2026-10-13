import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_providers.dart';
import '../../data/packs/manifest.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// A notice from the data server, in the UI language (spec §15.3).
class NoticeBanner extends ConsumerWidget {
  const NoticeBanner(this.notice, {super.key, this.onDismiss});

  final ManifestNotice notice;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return _Card(
      color: c.paperRaised,
      icon: Icon(Icons.campaign_outlined, color: c.ink),
      text: Text(
        notice.text.of(ref.watch(appLanguageProvider)),
        style: t.bodyMedium,
      ),
      actions: [
        if (onDismiss != null)
          TextButton(onPressed: onDismiss, child: Text(l.noticeDismiss)),
      ],
    );
  }
}

/// Asks before downloading packs of 2 MB or more (spec §18).
class DownloadPrompt extends ConsumerWidget {
  const DownloadPrompt({
    super.key,
    required this.bytes,
    required this.onDownload,
    required this.onLater,
  });

  final int bytes;
  final VoidCallback onDownload;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return _Card(
      color: c.haldiContainer,
      icon: Icon(Icons.cloud_download_outlined, color: c.onHaldiContainer),
      text: Text(
        l.downloadPrompt(l.sizeMegabytes(f.megabytes(bytes))),
        style: t.bodyMedium?.copyWith(color: c.onHaldiContainer),
      ),
      actions: [
        TextButton(onPressed: onLater, child: Text(l.actionLater)),
        FilledButton(onPressed: onDownload, child: Text(l.actionDownload)),
      ],
    );
  }
}

/// A one-line problem with updates: failed download, or the app is too old.
class UpdateProblem extends StatelessWidget {
  const UpdateProblem(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _Card(
      color: c.paperRaised,
      icon: Icon(Icons.error_outline, color: c.inkMuted),
      text: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      actions: const [],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.color,
    required this.icon,
    required this.text,
    required this.actions,
  });

  final Color color;
  final Widget icon;
  final Widget text;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(Space.l, Space.m, Space.l, Space.s),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Radii.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(child: icon),
                const SizedBox(width: Space.m),
                Expanded(child: text),
              ],
            ),
            if (actions.isNotEmpty)
              Wrap(
                spacing: Space.s,
                alignment: WrapAlignment.end,
                children: actions,
              )
            else
              const SizedBox(height: Space.xs),
          ],
        ),
      ),
    );
  }
}
